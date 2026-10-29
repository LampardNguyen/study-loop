import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/features/dialogue_lesson/dialogue_lesson_service.dart';
import 'package:echo_loop/features/dialogue_lesson/dialogue_parser.dart';
import 'package:echo_loop/models/audio_item.dart';
import 'package:echo_loop/services/openai/openai_audio_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_io/io.dart';

/// 每次返回 4800 字节（100ms）PCM；可指定前若干次失败的状态码。
class _FakeSpeech extends OpenAiAudioClient {
  _FakeSpeech({List<int>? failStatuses}) : _failStatuses = [...?failStatuses];

  final List<int> _failStatuses;
  final calls = <({String input, String voice, String format})>[];

  @override
  Future<List<int>> synthesizeSpeech(
    AiProviderConfig config, {
    required String input,
    required String voice,
    String model = defaultSpeechModel,
    String? instructions,
    String responseFormat = 'mp3',
    CancelToken? cancelToken,
  }) async {
    calls.add((input: input, voice: voice, format: responseFormat));
    if (_failStatuses.isNotEmpty) {
      final status = _failStatuses.removeAt(0);
      final req = RequestOptions(path: '/audio/speech');
      throw DioException(
        requestOptions: req,
        response: Response(requestOptions: req, statusCode: status),
        type: DioExceptionType.badResponse,
      );
    }
    return List.filled(4800, 1);
  }
}

const _config = AiProviderConfig(
  apiKey: 'sk-test',
  baseUrl: 'https://api.test/v1',
  model: 'm1',
);

void main() {
  group('parseDialogue', () {
    test('解析说话人与台词，续行并入上一句，忽略空行', () {
      final lines = parseDialogue('''
Mark: Hi Anna, come in.

Anna: Hi, Doctor.
My head hurts.
Mark：Okay.
''');
      expect(lines, const [
        DialogueLine(speaker: 'Mark', text: 'Hi Anna, come in.'),
        DialogueLine(speaker: 'Anna', text: 'Hi, Doctor. My head hurts.'),
        DialogueLine(speaker: 'Mark', text: 'Okay.'),
      ]);
      expect(dialogueSpeakers(lines), ['Mark', 'Anna']);
    });

    test('首句前的无说话人行被忽略', () {
      expect(parseDialogue('intro text\nA: hi'), const [
        DialogueLine(speaker: 'A', text: 'hi'),
      ]);
    });
  });

  group('字幕时间轴', () {
    test('按字节换算时长并插入句间静音', () {
      const lines = [
        DialogueLine(speaker: 'A', text: 'one'),
        DialogueLine(speaker: 'B', text: 'two'),
      ];
      // 48 字节 = 1ms（24kHz PCM16 单声道）。
      final cues = buildDialogueCues(lines, [48000, 24000]);
      expect(cues[0].start, Duration.zero);
      expect(cues[0].end, const Duration(seconds: 1));
      expect(cues[1].start, const Duration(milliseconds: 1300));
      expect(cues[1].end, const Duration(milliseconds: 1800));

      expect(
        dialogueCuesToSrt(cues),
        '1\n00:00:00,000 --> 00:00:01,000\none\n\n'
        '2\n00:00:01,300 --> 00:00:01,800\ntwo\n\n',
      );
    });

    test('pcm16ToWav 写入正确头部', () {
      final wav = pcm16ToWav(Uint8List(10));
      final data = ByteData.sublistView(wav);
      expect(wav.length, 54);
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(data.getUint32(24, Endian.little), 24000);
      expect(data.getUint32(40, Endian.little), 10);
    });
  });

  group('synthesizeToWav', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('dialogue_test'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('逐句用 pcm 合成、按说话人分配声音并输出 WAV + SRT', () async {
      final fake = _FakeSpeech();
      final service = DialogueLessonService(client: fake);
      final progress = <int>[];

      final result = await service.synthesizeToWav(
        config: _config,
        lines: parseDialogue('Mark: a\nAnna: b\nMark: c'),
        outputWav: File('${tmp.path}/out.wav'),
        voices: const {'Anna': 'coral'},
        onProgress: (done, _) => progress.add(done),
      );

      expect(fake.calls.map((c) => c.voice), ['ash', 'coral', 'ash']);
      expect(fake.calls.every((c) => c.format == 'pcm'), isTrue);
      expect(progress, [0, 1, 2, 3]);
      // 3 句 × 4800 字节 + 2 段静音 × 14400 字节 + 44 字节头。
      expect(result.wavFile.lengthSync(), 3 * 4800 + 2 * 14400 + 44);
      expect(result.srt, contains('00:00:00,400 --> 00:00:00,500\nb'));
    });

    test('429 重试一次后成功', () async {
      final fake = _FakeSpeech(failStatuses: [429]);
      await DialogueLessonService(client: fake).synthesizeToWav(
        config: _config,
        lines: parseDialogue('A: x'),
        outputWav: File('${tmp.path}/out.wav'),
      );
      expect(fake.calls, hasLength(2));
    });

    test('401 不重试直接抛出', () async {
      final fake = _FakeSpeech(failStatuses: [401]);
      await expectLater(
        DialogueLessonService(client: fake).synthesizeToWav(
          config: _config,
          lines: parseDialogue('A: x'),
          outputWav: File('${tmp.path}/out.wav'),
        ),
        throwsA(isA<DioException>()),
      );
      expect(fake.calls, hasLength(1));
    });

    test('空对话抛 DialogueLessonException', () {
      expect(
        DialogueLessonService(client: _FakeSpeech()).synthesizeToWav(
          config: _config,
          lines: const [],
          outputWav: File('${tmp.path}/out.wav'),
        ),
        throwsA(isA<DialogueLessonException>()),
      );
    });
  });

  test('AudioImportSourceType.tts 存储值往返', () {
    expect(AudioImportSourceType.tts.storageValue, 'tts');
    expect(
      AudioImportSourceType.fromStorageValue('tts'),
      AudioImportSourceType.tts,
    );
  });
}
