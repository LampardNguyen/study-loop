import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../providers/backup_provider.dart';
import '../../services/backup/backup_manifest.dart';
import '../../services/backup/backup_progress.dart';
import 'drive_api.dart';
import 'drive_sync_service.dart';
import 'google_drive_auth.dart';

DriveSyncService _serviceFor(WidgetRef ref, GoogleSignInAccount account) {
  final auth = ref.read(googleDriveAuthProvider);
  return DriveSyncService(DioDriveApi(() => auth.accessToken(account)));
}

/// Drive 上最近一次备份的索引（null 表示没有备份）。
final driveBackupIndexProvider = FutureProvider.autoDispose
    .family<DriveMediaIndex?, GoogleSignInAccount>((ref, account) {
      final auth = ref.read(googleDriveAuthProvider);
      return DriveSyncService(
        DioDriveApi(() => auth.accessToken(account)),
      ).fetchIndex();
    });

Future<Directory> _createWorkDir(String prefix) async {
  final temp = await getTemporaryDirectory();
  return Directory(
    p.join(temp.path, '${prefix}_${DateTime.now().microsecondsSinceEpoch}'),
  ).create(recursive: true);
}

/// 导出（不含媒体）并上传到 Drive。
Future<DriveMediaIndex> performDriveBackup(
  WidgetRef ref,
  GoogleSignInAccount account, {
  void Function(BackupProgress)? onProgress,
  CancelToken? cancelToken,
}) async {
  final workDir = await _createWorkDir('drive_backup');
  try {
    final zipPath = await performExport(
      ref,
      includeMedia: false,
      onProgress: onProgress,
    );
    try {
      final BackupManifest manifest = await readBackupManifest(ref, zipPath);
      final mediaFiles = await ref.read(backupServiceProvider).listMediaFiles();
      return await _serviceFor(ref, account).upload(
        zipPath: zipPath,
        manifest: manifest,
        mediaFiles: mediaFiles,
        tempDir: workDir.path,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
    } finally {
      final zip = File(zipPath);
      if (await zip.exists()) await zip.delete();
    }
  } finally {
    await workDir.delete(recursive: true);
  }
}

/// 从 Drive 下载备份与缺失的媒体，再走本地恢复流程。
Future<BackupManifest> performDriveRestore(
  WidgetRef ref,
  GoogleSignInAccount account, {
  void Function(BackupProgress)? onProgress,
  CancelToken? cancelToken,
}) async {
  final service = _serviceFor(ref, account);
  final workDir = await _createWorkDir('drive_restore');
  try {
    final package = await service.download(
      tempDir: workDir.path,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
    final stagingDir = await Directory(p.join(workDir.path, 'media')).create();
    return await performImport(
      ref,
      package.zipPath,
      stageMedia: (prepared) => service.stageMedia(
        prepared,
        package,
        stagingDir: stagingDir.path,
        onProgress: onProgress,
        cancelToken: cancelToken,
      ),
      onProgress: onProgress,
    );
  } finally {
    await workDir.delete(recursive: true);
  }
}
