import 'package:dio/dio.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/models/dictionary/dictionary_entry.dart';
import 'package:echo_loop/models/retell_review_evaluation.dart';
import 'package:echo_loop/services/dictionary/dictionary_source.dart';
import 'package:echo_loop/services/openai/openai_audio_client.dart';
import 'package:echo_loop/services/openai/openai_chat_client.dart';
import 'package:echo_loop/services/openai/openai_sentence_ai_api_client.dart';
import 'package:echo_loop/services/sentence_ai_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_io/io.dart';

/// 按 8 字符切块回放预设 JSON 的假 Chat 客户端，并记录收到的 prompt。
class _FakeChat extends OpenAiChatClient {
  _FakeChat(this.reply);

  String reply;
  List<OpenAiMessage>? lastMessages;
  bool? lastJsonMode;

  @override
  Stream<String> streamCompletion(
    AiProviderConfig config,
    List<OpenAiMessage> messages, {
    bool jsonMode = false,
    double? temperature,
    CancelToken? cancelToken,
  }) async* {
    lastMessages = messages;
    lastJsonMode = jsonMode;
    for (var i = 0; i < reply.length; i += 8) {
      yield reply.substring(i, (i + 8).clamp(0, reply.length));
    }
  }
}

class _FakeAudio extends OpenAiAudioClient {
  _FakeAudio(this.text);

  final String text;
  int calls = 0;

  @override
  Future<String> transcribe(
    AiProviderConfig config,
    File audioFile, {
    String language = 'en',
    String model = defaultTranscriptionModel,
    CancelToken? cancelToken,
  }) async {
    calls++;
    return text;
  }
}

void main() {
  const configured = AiProviderConfig(apiKey: 'sk-test');

  OpenAiSentenceAiApiClient clientWith(
    _FakeChat chat, {
    AiProviderConfig config = configured,
    _FakeAudio? audio,
  }) => OpenAiSentenceAiApiClient(
    readConfig: () async => config,
    chat: chat,
    audio: audio ?? _FakeAudio(''),
  );

  test('翻译：JSON 模式、prompt 带目标语言与上下文，末帧为完整译文', () async {
    final chat = _FakeChat(
      '{"translation":"Xin chào thế giới, đây là câu thử."}',
    );
    final frames = await clientWith(chat)
        .translateStream(
          'Hello world, this is a test.',
          accessToken: '',
          previousText: 'Before.',
          targetLanguage: 'vi',
        )
        .toList();

    expect(chat.lastJsonMode, isTrue);
    final prompt = chat.lastMessages!.map((m) => m.content).join('\n');
    expect(prompt, contains('Vietnamese'));
    expect(prompt, contains('Previous sentence (context): Before.'));
    expect(frames.last.isFinal, isTrue);
    expect(
      frames.last.translation.translation,
      'Xin chào thế giới, đây là câu thử.',
    );
  });

  test('单词词典：解析为 DictionaryEntry', () async {
    final chat = _FakeChat(
      '{"headword":"run","pronunciation":{"uk":"/rʌn/","us":"/rʌn/"},'
      '"meanings":[{"partOfSpeech":"verb","translation":["chạy"],'
      '"definition":"move fast on foot","usageNote":"","examples":[],'
      '"synonyms":["sprint"],"antonyms":[]}],"commonExpressions":[],'
      '"wordFamily":[],"forms":[],"etymology":"","learnerTips":[]}',
    );
    final frames = await clientWith(
      chat,
    ).lookupWordStreamFrames('run', accessToken: '').toList();

    final entry = frames.last.entry;
    expect(frames.last.isFinal, isTrue);
    expect(entry, isA<DictionaryEntry>());
    expect((entry as DictionaryEntry).meanings.single.translation, ['chạy']);
  });

  test('未配置 Key：词典抛 DictionaryAuthRequiredException，翻译抛 401', () async {
    final client = clientWith(
      _FakeChat('{}'),
      config: const AiProviderConfig(),
    );

    expect(
      client.lookupWordStreamFrames('run', accessToken: '').toList(),
      throwsA(isA<DictionaryAuthRequiredException>()),
    );
    expect(
      client.translateStream('Hi', accessToken: '').toList(),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
  });

  test('模型输出非法 JSON → 领域流异常（不产出 final）', () async {
    expect(
      clientWith(
        _FakeChat('{"translation":"cut'),
      ).translateStream('Hi', accessToken: '').toList(),
      throwsA(isA<SentenceTranslationStreamException>()),
    );
  });

  test('意群：medium / fine 两种粒度', () async {
    final frames = await clientWith(
      _FakeChat(
        '{"medium":["I think ","it works."],"fine":["I ","think ","it works."]}',
      ),
    ).senseGroupsStream('I think it works.', accessToken: '').toList();

    expect(frames.last.isFinal, isTrue);
    expect(frames.last.result.medium, ['I think ', 'it works.']);
    expect(frames.last.result.fine, hasLength(3));
  });

  test('复述评估：先推转写帧，最终 transcript 以真实转写为准', () async {
    final audio = _FakeAudio('i went to the shop');
    final chat = _FakeChat(
      '{"transcript":"MODEL REWROTE THIS","summary":"Tốt","rating":"good",'
      '"keyPoints":[],"suggestion":"","corrections":[]}',
    );
    final frames = await clientWith(chat, audio: audio)
        .evaluateReviewStream(
          audioFile: File('unused.m4a'),
          originalText: 'I went to the shop.',
          targetLanguage: 'vi',
          accessToken: '',
        )
        .toList();

    expect(audio.calls, 1);
    expect(frames.first.evaluation.transcript, 'i went to the shop');
    expect(frames.first.isFinal, isFalse);
    expect(frames.last.isFinal, isTrue);
    expect(frames.last.evaluation.transcript, 'i went to the shop');
    expect(frames.last.evaluation.rating, RetellReviewRating.good);
    expect(
      chat.lastMessages!.last.content,
      contains('Learner transcript:\ni went to the shop'),
    );
  });
}
