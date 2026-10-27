import 'dart:io';

import 'package:echo_loop/features/audio_import/audio_finalization_service.dart';
import 'package:echo_loop/features/audio_import/audio_import_models.dart';
import 'package:echo_loop/features/audio_import/audio_transcode_service.dart';
import 'package:echo_loop/features/audio_trim/audio_trim_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// 裁剪桩：按调用记录参数；[copyOk]/[reencodeOk] 控制流复制与重编码是否成功。
class _FakeTranscodeService extends AudioTranscodeService {
  _FakeTranscodeService({this.copyOk = true, this.reencodeOk = true});

  final bool copyOk;
  final bool reencodeOk;
  final calls =
      <({String output, Duration start, Duration end, bool reencode})>[];

  @override
  Future<bool> trimToFile({
    required File source,
    required File output,
    required Duration start,
    required Duration end,
    bool reencode = false,
  }) async {
    calls.add((
      output: output.path,
      start: start,
      end: end,
      reencode: reencode,
    ));
    if (reencode ? !reencodeOk : !copyOk) return false;
    await output.parent.create(recursive: true);
    await output.writeAsBytes([0x01, 0x02]);
    return true;
  }
}

void main() {
  late Directory dataDir;
  const sourceRel = 'audios/imported/old.mp3';

  setUp(() async {
    dataDir = await Directory.systemTemp.createTemp('audio_trim_test_');
    final source = File(p.join(dataDir.path, sourceRel));
    await source.parent.create(recursive: true);
    await source.writeAsBytes([9, 9, 9]);
  });

  tearDown(() async {
    if (await dataDir.exists()) await dataDir.delete(recursive: true);
  });

  AudioTrimService buildService(_FakeTranscodeService fake) => AudioTrimService(
    transcodeService: fake,
    finalizationService: AudioFinalizationService(
      computeSha256: (_) async => 'sha-trimmed',
    ),
  );

  test('流复制成功：保留扩展名、按新指纹落到原目录，原文件不动', () async {
    final fake = _FakeTranscodeService();
    final result = await buildService(fake).trim(
      dataDir: dataDir,
      relativePath: sourceRel,
      start: const Duration(seconds: 30),
      end: const Duration(minutes: 5),
    );

    expect(fake.calls, hasLength(1));
    expect(fake.calls.single.reencode, isFalse);
    expect(fake.calls.single.start, const Duration(seconds: 30));
    expect(fake.calls.single.end, const Duration(minutes: 5));
    expect(result.relativePath, p.join('audios/imported', 'sha-trimmed.mp3'));
    expect(result.sha256, 'sha-trimmed');
    expect(result.originalSha256, 'sha-trimmed');
    expect(
      File(p.join(dataDir.path, result.relativePath)).existsSync(),
      isTrue,
    );
    expect(File(p.join(dataDir.path, sourceRel)).existsSync(), isTrue);
  });

  test('流复制失败：回退重编码为 m4a', () async {
    final fake = _FakeTranscodeService(copyOk: false);
    final result = await buildService(fake).trim(
      dataDir: dataDir,
      relativePath: sourceRel,
      start: Duration.zero,
      end: const Duration(seconds: 10),
    );

    expect(fake.calls.map((c) => c.reencode), [false, true]);
    expect(p.extension(fake.calls.last.output), '.m4a');
    expect(result.relativePath, p.join('audios/imported', 'sha-trimmed.m4a'));
  });

  test('两次都失败：抛 AudioImportException，不产生新文件', () async {
    final fake = _FakeTranscodeService(copyOk: false, reencodeOk: false);
    await expectLater(
      buildService(fake).trim(
        dataDir: dataDir,
        relativePath: sourceRel,
        start: Duration.zero,
        end: const Duration(seconds: 10),
      ),
      throwsA(isA<AudioImportException>()),
    );
    final files = Directory(
      p.join(dataDir.path, 'audios/imported'),
    ).listSync().map((f) => p.basename(f.path));
    expect(files, ['old.mp3']);
  });
}
