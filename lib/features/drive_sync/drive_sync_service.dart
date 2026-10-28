import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../providers/backup_provider.dart';
import '../../services/app_logger.dart';
import '../../services/backup/backup_manifest.dart';
import '../../services/backup/backup_progress.dart';
import '../../services/backup/backup_service.dart';
import '../../utils/app_data_dir.dart';
import 'drive_api.dart';

const driveBackupFileName = 'backup.zip';
const driveMediaIndexFileName = 'backup-index.json';
const driveMediaPrefix = 'media-';

/// Drive 上的备份与本地数据库不匹配（例如上传中断）。
class DriveBackupMismatchException implements Exception {
  const DriveBackupMismatchException();

  @override
  String toString() => 'DriveBackupMismatchException';
}

/// 媒体索引：相对路径 → 内容 sha256。媒体按 sha256 单独存放，跨备份去重。
class DriveMediaIndex {
  const DriveMediaIndex({
    required this.dbSha256,
    required this.createdAt,
    required this.appVersion,
    required this.files,
  });

  final String dbSha256;
  final DateTime createdAt;
  final String appVersion;
  final Map<String, ({String sha256, int size})> files;

  int get totalBytes => files.values.fold(0, (sum, file) => sum + file.size);

  Map<String, Object?> toJson() => {
    'version': 1,
    'dbSha256': dbSha256,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'appVersion': appVersion,
    'files': {
      for (final entry in files.entries)
        entry.key: {'sha256': entry.value.sha256, 'size': entry.value.size},
    },
  };

  factory DriveMediaIndex.fromJson(Map<String, dynamic> json) {
    final files = json['files'] as Map<String, dynamic>;
    return DriveMediaIndex(
      dbSha256: json['dbSha256'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      appVersion: json['appVersion'] as String,
      files: {
        for (final entry in files.entries)
          entry.key: (
            sha256: (entry.value as Map)['sha256'] as String,
            size: (entry.value as Map)['size'] as int,
          ),
      },
    );
  }
}

/// 下载到本地、等待恢复的 Drive 备份。
class DriveRestorePackage {
  const DriveRestorePackage({
    required this.zipPath,
    required this.index,
    required this.remoteFiles,
  });

  final String zipPath;
  final DriveMediaIndex index;
  final List<DriveFile> remoteFiles;
}

/// Google Drive 同步：数据库与设置打包为 `backup.zip`（不含媒体），
/// 媒体按 sha256 单独上传，已存在则跳过。OpenAI key 只在安全存储中，
/// 不经过 [BackupService]，因此不会被上传。
class DriveSyncService {
  DriveSyncService(this._api);

  final DriveApi _api;

  /// 读取 Drive 上最近一次备份的索引，没有备份时返回 null。
  Future<DriveMediaIndex?> fetchIndex({String? tempDir}) async {
    final files = await _api.listFiles();
    final indexFile = _find(files, driveMediaIndexFileName);
    if (indexFile == null || _find(files, driveBackupFileName) == null) {
      return null;
    }
    final dir = tempDir ?? Directory.systemTemp.path;
    final target = p.join(
      dir,
      'drive_index_${DateTime.now().microsecondsSinceEpoch}.json',
    );
    try {
      await _api.download(indexFile.id, target);
      return _readIndex(target);
    } finally {
      await _deleteIfExists(target);
    }
  }

  /// 上传本地导出的 [zipPath] 与 [mediaFiles]（相对路径 → 绝对路径）。
  Future<DriveMediaIndex> upload({
    required String zipPath,
    required BackupManifest manifest,
    required Map<String, String> mediaFiles,
    required String tempDir,
    void Function(BackupProgress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final remote = await _api.listFiles(cancelToken: cancelToken);
    final remoteNames = {for (final file in remote) file.name};

    final entries = mediaFiles.entries.toList();
    final files = <String, ({String sha256, int size})>{};
    for (var i = 0; i < entries.length; i++) {
      _throwIfCancelled(cancelToken);
      onProgress?.call(
        BackupProgress(stage: 'driveHashing', progress: i / entries.length),
      );
      final file = File(entries[i].value);
      files[entries[i].key] = (
        sha256: await _sha256(file),
        size: await file.length(),
      );
    }

    final missing = <String, String>{};
    for (final entry in entries) {
      final name = _mediaName(files[entry.key]!.sha256);
      if (!remoteNames.contains(name)) missing[name] = entry.value;
    }
    var uploaded = 0;
    for (final entry in missing.entries) {
      onProgress?.call(
        BackupProgress(
          stage: 'driveUploadingMedia:${uploaded + 1}/${missing.length}',
          progress: uploaded / missing.length,
        ),
      );
      await _api.upload(entry.key, File(entry.value), cancelToken: cancelToken);
      uploaded++;
      remoteNames.add(entry.key);
    }

    onProgress?.call(const BackupProgress(stage: 'driveUploadingBackup'));
    final index = DriveMediaIndex(
      dbSha256: manifest.dbSha256,
      createdAt: DateTime.now().toUtc(),
      appVersion: manifest.appVersion,
      files: files,
    );
    final indexPath = p.join(tempDir, driveMediaIndexFileName);
    await File(indexPath).writeAsString(jsonEncode(index.toJson()));
    try {
      // 先传 backup.zip 再传索引：中断时旧索引的 dbSha256 与新 zip 不符，恢复会拒绝。
      await _api.upload(
        driveBackupFileName,
        File(zipPath),
        existingId: _find(remote, driveBackupFileName)?.id,
        cancelToken: cancelToken,
      );
      await _api.upload(
        driveMediaIndexFileName,
        File(indexPath),
        existingId: _find(remote, driveMediaIndexFileName)?.id,
        cancelToken: cancelToken,
      );
    } finally {
      await _deleteIfExists(indexPath);
    }

    // 删除不再被引用的旧媒体，失败不影响本次备份。
    final referenced = {
      for (final file in files.values) _mediaName(file.sha256),
    };
    for (final file in remote) {
      if (file.name.startsWith(driveMediaPrefix) &&
          !referenced.contains(file.name)) {
        try {
          await _api.delete(file.id);
        } catch (error) {
          AppLogger.log('DriveSync', 'delete_stale_failed error=$error');
        }
      }
    }
    AppLogger.log(
      'DriveSync',
      'upload_done media=${files.length} uploaded=$uploaded',
    );
    return index;
  }

  /// 下载 `backup.zip` 与索引到 [tempDir]。
  Future<DriveRestorePackage> download({
    required String tempDir,
    void Function(BackupProgress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final remote = await _api.listFiles(cancelToken: cancelToken);
    final zip = _find(remote, driveBackupFileName);
    final indexFile = _find(remote, driveMediaIndexFileName);
    if (zip == null || indexFile == null) {
      throw const DriveBackupMismatchException();
    }
    final indexPath = p.join(tempDir, driveMediaIndexFileName);
    await _api.download(indexFile.id, indexPath, cancelToken: cancelToken);
    final zipPath = p.join(tempDir, driveBackupFileName);
    await _api.download(
      zip.id,
      zipPath,
      cancelToken: cancelToken,
      onProgress: (received, total) => onProgress?.call(
        BackupProgress(
          stage: 'driveDownloadingBackup',
          progress: total > 0 ? received / total : -1,
        ),
      ),
    );
    return DriveRestorePackage(
      zipPath: zipPath,
      index: await _readIndex(indexPath),
      remoteFiles: remote,
    );
  }

  /// 为恢复准备媒体：本地已有相同内容的原地保留，其余从 Drive 下载到 [stagingDir]。
  Future<StagedBackupMedia> stageMedia(
    PreparedBackupImport prepared,
    DriveRestorePackage package, {
    required String stagingDir,
    void Function(BackupProgress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (package.index.dbSha256 != prepared.manifest.dbSha256) {
      throw const DriveBackupMismatchException();
    }
    final dataDir = await getAppDataDirectory();
    final kept = <String>{};
    final toDownload = <String, ({String sha256, int size})>{};
    for (final relativePath in prepared.importedMediaPaths) {
      final entry = package.index.files[relativePath];
      if (entry == null) continue;
      final local = File(p.join(dataDir.path, relativePath));
      if (await local.exists() &&
          await local.length() == entry.size &&
          await _sha256(local) == entry.sha256) {
        kept.add(relativePath);
      } else {
        toDownload[relativePath] = entry;
      }
    }

    final staged = <String, String>{};
    var done = 0;
    for (final entry in toDownload.entries) {
      _throwIfCancelled(cancelToken);
      onProgress?.call(
        BackupProgress(
          stage: 'driveDownloadingMedia:${done + 1}/${toDownload.length}',
          progress: done / toDownload.length,
        ),
      );
      final remote = _find(package.remoteFiles, _mediaName(entry.value.sha256));
      if (remote == null) {
        AppLogger.log('DriveSync', 'media_missing path=${entry.key}');
        continue;
      }
      final target = p.join(stagingDir, entry.value.sha256);
      if (!await File(target).exists()) {
        await _api.download(remote.id, target, cancelToken: cancelToken);
      }
      staged[entry.key] = target;
      done++;
    }
    // 多条记录引用同一内容时共用一个临时文件；移动前复制出独立副本。
    final seen = <String>{};
    for (final entry in staged.entries.toList()) {
      if (seen.add(entry.value)) continue;
      final copy = '${entry.value}-${seen.length}-${entry.key.hashCode}';
      await File(entry.value).copy(copy);
      staged[entry.key] = copy;
    }
    AppLogger.log(
      'DriveSync',
      'stage_done kept=${kept.length} downloaded=${staged.length}',
    );
    return (staged: staged, kept: kept);
  }
}

String _mediaName(String sha256) => '$driveMediaPrefix$sha256';

DriveFile? _find(List<DriveFile> files, String name) {
  for (final file in files) {
    if (file.name == name) return file;
  }
  return null;
}

Future<String> _sha256(File file) async =>
    (await sha256.bind(file.openRead()).first).toString();

Future<DriveMediaIndex> _readIndex(String path) async =>
    DriveMediaIndex.fromJson(
      jsonDecode(await File(path).readAsString()) as Map<String, dynamic>,
    );

void _throwIfCancelled(CancelToken? token) {
  if (token?.isCancelled ?? false) {
    throw DioException.requestCancelled(
      requestOptions: RequestOptions(),
      reason: 'cancelled',
    );
  }
}

Future<void> _deleteIfExists(String path) async {
  final file = File(path);
  if (await file.exists()) await file.delete();
}
