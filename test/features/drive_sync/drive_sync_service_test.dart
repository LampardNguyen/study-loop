import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:echo_loop/database/app_database.dart';
import 'package:echo_loop/features/drive_sync/drive_api.dart';
import 'package:echo_loop/features/drive_sync/drive_sync_service.dart';
import 'package:echo_loop/services/app_logger.dart';
import 'package:echo_loop/services/backup/backup_service.dart';
import 'package:echo_loop/utils/app_data_dir.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.rootPath);

  final String rootPath;

  @override
  Future<String?> getApplicationSupportPath() async => rootPath;

  @override
  Future<String?> getTemporaryPath() async => rootPath;
}

/// 内存版 Drive appDataFolder。
class _FakeDriveApi implements DriveApi {
  final files = <String, ({String name, List<int> bytes})>{};
  final uploadedNames = <String>[];
  var _nextId = 0;

  @override
  Future<List<DriveFile>> listFiles({CancelToken? cancelToken}) async => [
    for (final entry in files.entries)
      DriveFile(
        id: entry.key,
        name: entry.value.name,
        size: entry.value.bytes.length,
      ),
  ];

  @override
  Future<void> upload(
    String name,
    File file, {
    String? existingId,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onProgress,
  }) async {
    uploadedNames.add(name);
    files[existingId ?? 'id${_nextId++}'] = (
      name: name,
      bytes: await file.readAsBytes(),
    );
  }

  @override
  Future<void> download(
    String id,
    String targetPath, {
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  }) => File(targetPath).writeAsBytes(files[id]!.bytes);

  @override
  Future<void> delete(String id) async => files.remove(id);

  Iterable<String> get names => files.values.map((file) => file.name);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late Directory dataDir;
  late Directory workDir;
  late AppDatabase database;
  late BackupService backup;
  late _FakeDriveApi api;
  late DriveSyncService drive;
  var databaseClosed = false;

  setUp(() async {
    AppLogger.instance.clear();
    root = await Directory.systemTemp.createTemp('drive_sync_test_');
    dataDir = Directory(p.join(root.path, 'data'))..createSync();
    workDir = Directory(p.join(root.path, 'work'))..createSync();
    PathProviderPlatform.instance = _FakePathProvider(root.path);
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      // 兜底：即使误存进 SharedPreferences，也不能进入备份。
      'selfhost.ai_provider_config': '{"apiKey":"sk-secret"}',
      'drive_sync_signed_in': true,
    });
    appDataDirectoryOverride = dataDir;
    databaseClosed = false;
    database = AppDatabase(
      NativeDatabase(File(p.join(dataDir.path, 'echo_loop.db'))),
    );
    backup = BackupService(
      database,
      restoredAppUpdateMigrator: (_, _) async {},
    );
    api = _FakeDriveApi();
    drive = DriveSyncService(api);
  });

  tearDown(() async {
    if (!databaseClosed) await database.close();
    appDataDirectoryOverride = null;
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<File> addAudio(String id, String path, List<int> bytes) async {
    final now = DateTime.utc(2026, 10, 28);
    await database
        .into(database.audioItems)
        .insert(
          AudioItemsCompanion.insert(
            id: id,
            name: id,
            addedDate: now,
            updatedAt: now,
            audioPath: Value(path),
          ),
        );
    final file = File(p.join(dataDir.path, path));
    await file.parent.create(recursive: true);
    return file.writeAsBytes(bytes);
  }

  Future<void> backupToDrive() async {
    final zip = await backup.exportData(
      outputDir: workDir.path,
      appVersion: '1.0.0',
      platform: 'android',
      includeMedia: false,
    );
    await drive.upload(
      zipPath: zip,
      manifest: await backup.readManifest(zip),
      mediaFiles: await backup.listMediaFiles(),
      tempDir: workDir.path,
    );
    await File(zip).delete();
  }

  test('备份 zip 不含媒体，也不含 OpenAI key 与本机同步状态', () async {
    await addAudio('a', 'audios/a.m4a', [1, 2, 3]);
    await backupToDrive();

    final zipBytes = api.files.values
        .firstWhere((file) => file.name == driveBackupFileName)
        .bytes;
    final archive = ZipDecoder().decodeBytes(zipBytes);
    expect(
      archive.files.where((f) => f.isFile && f.name.startsWith('media/')),
      isEmpty,
    );
    final settings = utf8.decode(archive.findFile('settings.json')!.content);
    expect(settings, contains('theme_mode'));
    expect(settings, isNot(contains('selfhost.ai_provider_config')));
    expect(settings, isNot(contains('sk-secret')));
    expect(settings, isNot(contains('drive_sync_signed_in')));
    for (final file in api.files.values) {
      expect(
        utf8.decode(file.bytes, allowMalformed: true),
        isNot(contains('sk-secret')),
      );
    }
  });

  test('媒体按 sha256 去重，已上传的不再上传，未引用的被删除', () async {
    await addAudio('a', 'audios/a.m4a', [1, 2, 3]);
    await addAudio('b', 'audios/b.m4a', [1, 2, 3]);
    await addAudio('c', 'audios/c.m4a', [4, 5, 6]);
    await backupToDrive();
    expect(
      api.names.where((n) => n.startsWith(driveMediaPrefix)),
      hasLength(2),
    );

    api.uploadedNames.clear();
    await database.customStatement("DELETE FROM audio_items WHERE id = 'c'");
    await backupToDrive();

    expect(
      api.uploadedNames,
      unorderedEquals([driveBackupFileName, driveMediaIndexFileName]),
    );
    expect(
      api.names.where((n) => n.startsWith(driveMediaPrefix)),
      hasLength(1),
    );
    expect(api.names.where((n) => n == driveBackupFileName), hasLength(1));
  });

  test('恢复：本地相同内容原地保留，缺失或不同的从 Drive 下载', () async {
    final a = await addAudio('a', 'audios/a.m4a', [1, 1, 1]);
    final b = await addAudio('b', 'audios/b.m4a', [2, 2, 2]);
    final c = await addAudio('c', 'audios/c.m4a', [3, 3, 3]);
    await backupToDrive();

    await b.writeAsBytes([9, 9, 9]);
    await c.delete();

    final restoreDir = Directory(p.join(workDir.path, 'restore'))..createSync();
    final package = await drive.download(tempDir: restoreDir.path);
    final prepared = await backup.prepareImport(zipPath: package.zipPath);
    addTearDown(prepared.dispose);
    final stagingDir = Directory(p.join(restoreDir.path, 'media'))
      ..createSync();
    final media = await drive.stageMedia(
      prepared,
      package,
      stagingDir: stagingDir.path,
    );
    expect(media.kept, {'audios/a.m4a'});
    expect(
      media.staged.keys,
      unorderedEquals(['audios/b.m4a', 'audios/c.m4a']),
    );

    await database.close();
    databaseClosed = true;
    final applied = await backup.applyPreparedImport(
      prepared,
      stagedMedia: media.staged,
      keptMediaPaths: media.kept,
    );
    await applied.commit();

    expect(await a.readAsBytes(), [1, 1, 1]);
    expect(await b.readAsBytes(), [2, 2, 2]);
    expect(await c.readAsBytes(), [3, 3, 3]);
  });

  test('索引与 backup.zip 不匹配时拒绝恢复', () async {
    await addAudio('a', 'audios/a.m4a', [1]);
    await backupToDrive();
    final indexId = api.files.entries
        .firstWhere((e) => e.value.name == driveMediaIndexFileName)
        .key;
    final json =
        jsonDecode(utf8.decode(api.files[indexId]!.bytes))
            as Map<String, dynamic>;
    json['dbSha256'] = 'other';
    api.files[indexId] = (
      name: driveMediaIndexFileName,
      bytes: utf8.encode(jsonEncode(json)),
    );

    final package = await drive.download(tempDir: workDir.path);
    final prepared = await backup.prepareImport(zipPath: package.zipPath);
    addTearDown(prepared.dispose);
    expect(
      () => drive.stageMedia(prepared, package, stagingDir: workDir.path),
      throwsA(isA<DriveBackupMismatchException>()),
    );
  });
}
