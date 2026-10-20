import 'package:dio/dio.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/services/openai/openai_audio_client.dart';
import 'package:echo_loop/services/openai/openai_transcription_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_io/io.dart';

class _FakeAudio extends OpenAiAudioClient {
  _FakeAudio(this.response);

  final Map<String, dynamic> response;
  String? lastPath;
  String? lastLanguage;

  @override
  Future<Map<String, dynamic>> transcribeVerbose(
    AiProviderConfig config,
    File audioFile, {
    String? language,
    String model = defaultTranscriptionModel,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    lastPath = audioFile.path;
    lastLanguage = language;
    return response;
  }
}

Map<String, dynamic> _word(String w, double s, double e) => {
  'word': w,
  'start': s,
  'end': e,
};

void main() {
  final verbose = <String, dynamic>{
    'text': 'Hello there. How are you? Fine.',
    'duration': 3.0,
    'segments': [
      {'start': 0.0, 'end': 2.0, 'text': ' Hello there. How are you?'},
      {'start': 2.0, 'end': 3.0, 'text': ' Fine.'},
    ],
    'words': [
      _word('Hello', 0.0, 0.4),
      _word('there', 0.4, 0.8),
      _word('How', 1.0, 1.2),
      _word('are', 1.2, 1.4),
      _word('you', 1.4, 1.9),
      _word('Fine', 2.1, 2.6),
    ],
  };

  group('transcriptFromWhisperVerbose', () {
    test('段内按标点切句，并按词分配精确时间与词下标', () {
      final result = transcriptFromWhisperVerbose(verbose);

      expect(result.sentences.map((s) => s.text), [
        'Hello there.',
        'How are you?',
        'Fine.',
      ]);
      final second = result.sentences[1];
      expect(second.startTime, const Duration(milliseconds: 1000));
      expect(second.endTime, const Duration(milliseconds: 1900));
      expect(second.startWordIndex, 2);
      expect(second.endWordIndex, 4);
      expect(result.sentences.last.startWordIndex, 5);
      expect(result.words, hasLength(6));
      expect(result.fullText, 'Hello there. How are you? Fine.');
    });

    test('词数对不上时退化为整段一句（时间取段起止）', () {
      final result = transcriptFromWhisperVerbose({
        'text': "It's fine.",
        'segments': [
          {'start': 0.0, 'end': 1.0, 'text': " It's fine."},
        ],
        'words': [
          _word('It', 0, 0.2),
          _word('is', 0.2, 0.4),
          _word('fine', 0.5, 0.9),
        ],
      });
      expect(result.sentences.single.text, "It's fine.");
      expect(result.sentences.single.endTime, const Duration(seconds: 1));
      expect(result.sentences.single.startWordIndex, 0);
      expect(result.sentences.single.endWordIndex, 2);
    });

    test('无 segments 时用全文兜底', () {
      final result = transcriptFromWhisperVerbose({
        'text': 'Only text',
        'duration': 4.5,
      });
      expect(result.sentences.single.text, 'Only text');
      expect(
        result.sentences.single.endTime,
        const Duration(milliseconds: 4500),
      );
      expect(result.words, isNull);
    });
  });

  group('OpenAiTranscriptionApiClient', () {
    test('伪上传记住本地文件，submit 同步转录并以 cached 返回', () async {
      final audio = _FakeAudio(verbose);
      final client = OpenAiTranscriptionApiClient(
        readConfig: () async => const AiProviderConfig(apiKey: 'sk-1'),
        audio: audio,
      );

      final upload = await client.getUploadUrl(
        sha256: 'abc',
        mimeType: 'audio/mp4',
        fileSize: 10,
        accessToken: '',
      );
      expect(upload.audioExists, isFalse);
      await client.uploadToR2(
        uploadUrl: upload.uploadUrl!,
        filePath: '/data/audio.m4a',
        contentType: 'audio/mp4',
      );
      final submit = await client.submitTranscription(
        sha256: 'abc',
        language: 'en-US',
        accessToken: '',
      );

      expect(audio.lastPath, '/data/audio.m4a');
      expect(audio.lastLanguage, 'en');
      expect(submit.cached, isTrue);
      expect(submit.transcript?.sentences, hasLength(3));
    });

    test('未配置 Key → 401；不接受外部上传地址', () async {
      final client = OpenAiTranscriptionApiClient(
        readConfig: () async => const AiProviderConfig(),
        audio: _FakeAudio(verbose),
      );
      await client.uploadToR2(
        uploadUrl: 'selfhost://abc',
        filePath: '/x.m4a',
        contentType: 'audio/mp4',
      );
      expect(
        client.submitTranscription(
          sha256: 'abc',
          language: 'en',
          accessToken: '',
        ),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 's', 401),
        ),
      );
      expect(
        client.uploadToR2(
          uploadUrl: 'https://r2.example.com/put',
          filePath: '/x.m4a',
          contentType: 'audio/mp4',
        ),
        throwsStateError,
      );
    });
  });
}
