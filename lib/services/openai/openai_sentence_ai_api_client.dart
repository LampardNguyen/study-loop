/// 自托管版 AI 客户端：保持 [SentenceAiApiClient] 的全部公开签名，
/// 但不再请求原作者后端，而是用用户自己的 OpenAI 兼容接口完成同样的功能。
///
/// 做法：模型以 JSON 流式输出 → [openAiJsonToNdjsonEvents] 转成原后端同款
/// NDJSON 事件 → 交给同一个 `accumulateNdjsonObject` 累积。因此上层 provider、
/// 缓存、渐显 UI 全部无需改动。`accessToken` 参数保留但不再使用。
library;

import 'package:dio/dio.dart';
import 'package:universal_io/io.dart';

import '../../features/ai_settings/models/ai_provider_config.dart';
import '../../models/dictionary/dictionary_entry.dart';
import '../../models/retell_review_evaluation.dart';
import '../../models/sense_group_result.dart';
import '../../models/sentence_ai_result.dart';
import '../dictionary/dictionary_source.dart';
import '../ndjson_object_stream.dart';
import '../sentence_ai_api_client.dart';
import 'ai_prompts.dart';
import 'openai_audio_client.dart';
import 'openai_chat_client.dart';
import 'openai_ndjson_bridge.dart';

/// 读取当前 AI 配置（来自 App 内「AI 设置」）。
typedef AiConfigReader = Future<AiProviderConfig> Function();

/// 基于 OpenAI 兼容接口的 [SentenceAiApiClient] 实现。
class OpenAiSentenceAiApiClient extends SentenceAiApiClient {
  /// 构造客户端；[chat] / [audio] 可注入以便测试。
  OpenAiSentenceAiApiClient({
    required AiConfigReader readConfig,
    OpenAiChatClient? chat,
    OpenAiAudioClient? audio,
  }) : _readConfig = readConfig,
       _chat = chat ?? OpenAiChatClient(),
       _audio = audio ?? OpenAiAudioClient(),
       super.withDio(Dio());

  final AiConfigReader _readConfig;
  final OpenAiChatClient _chat;
  final OpenAiAudioClient _audio;

  /// 读取配置；未配置 Key 时按 401 处理（上层统一映射为「需要配置 / 登录」）。
  Future<AiProviderConfig> _requireConfig() async {
    final config = await _readConfig();
    if (!config.hasApiKey) {
      final request = RequestOptions(path: '/chat/completions');
      throw DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 401),
        type: DioExceptionType.badResponse,
      );
    }
    return config;
  }

  /// 发起 JSON 流式对话并转成 NDJSON 事件。
  Stream<Map<String, dynamic>> _jsonEvents(
    List<OpenAiMessage> messages, {
    CancelToken? cancelToken,
    Map<String, dynamic> Function(Map<String, dynamic>)? transform,
  }) async* {
    final config = await _requireConfig();
    yield* openAiJsonToNdjsonEvents(
      _chat.streamCompletion(
        config,
        messages,
        jsonMode: true,
        temperature: 0.3,
        cancelToken: cancelToken,
      ),
      transform: transform,
    );
  }

  @override
  Stream<SentenceTranslationStreamFrame> translateStream(
    String text, {
    required String accessToken,
    String? previousText,
    String? nextText,
    String? targetLanguage,
    CancelToken? cancelToken,
  }) async* {
    final events = _jsonEvents(
      translationPrompt(
        text,
        previous: previousText,
        next: nextText,
        targetLanguage: targetLanguage,
      ),
      cancelToken: cancelToken,
    );
    try {
      await for (final f in accumulateNdjsonObject(
        events,
        fromJson: SentenceTranslation.fromJson,
      )) {
        yield SentenceTranslationStreamFrame(
          translation: f.value,
          isFinal: f.isFinal,
        );
      }
    } on NdjsonStreamException {
      throw const SentenceTranslationStreamException();
    }
  }

  @override
  Stream<SentenceAnalysisStreamFrame> analyzeStream(
    String text, {
    required String accessToken,
    String? targetLanguage,
    CancelToken? cancelToken,
  }) async* {
    final events = _jsonEvents(
      analysisPrompt(text, targetLanguage: targetLanguage),
      cancelToken: cancelToken,
    );
    try {
      await for (final f in accumulateNdjsonObject(
        events,
        fromJson: SentenceAnalysis.fromJson,
      )) {
        yield SentenceAnalysisStreamFrame(
          analysis: f.value,
          isFinal: f.isFinal,
        );
      }
    } on NdjsonStreamException {
      throw const SentenceAnalysisStreamException();
    }
  }

  @override
  Stream<AiDictionaryStreamFrame> lookupWordStreamFrames(
    String word, {
    required String accessToken,
    String? targetLanguage,
    CancelToken? cancelToken,
  }) => _dictionaryFrames(
    wordLookupPrompt(word, targetLanguage: targetLanguage),
    fromJson: DictionaryEntry.fromJson,
    cancelToken: cancelToken,
  );

  @override
  Stream<AiDictionaryStreamFrame> lookupPhraseStreamFrames(
    String phrase, {
    required String accessToken,
    String? targetLanguage,
    CancelToken? cancelToken,
  }) => _dictionaryFrames(
    phraseLookupPrompt(phrase, targetLanguage: targetLanguage),
    fromJson: MultiWordDictionaryEntry.fromJson,
    cancelToken: cancelToken,
  );

  /// 词典流：401 映射为 [DictionaryAuthRequiredException]（与原后端一致）。
  Stream<AiDictionaryStreamFrame> _dictionaryFrames(
    List<OpenAiMessage> messages, {
    required AiDictionaryEntry Function(Map<String, dynamic>) fromJson,
    CancelToken? cancelToken,
  }) async* {
    try {
      await for (final f in accumulateNdjsonObject(
        _jsonEvents(messages, cancelToken: cancelToken),
        fromJson: fromJson,
      )) {
        yield AiDictionaryStreamFrame(entry: f.value, isFinal: f.isFinal);
      }
    } on NdjsonStreamException {
      throw const DictionaryStreamException();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const DictionaryAuthRequiredException();
      }
      rethrow;
    }
  }

  @override
  Stream<SenseGroupsStreamFrame> senseGroupsStream(
    String text, {
    required String accessToken,
    CancelToken? cancelToken,
  }) async* {
    try {
      await for (final f in accumulateNdjsonObject(
        _jsonEvents(senseGroupsPrompt(text), cancelToken: cancelToken),
        fromJson: SenseGroupResult.fromJson,
      )) {
        yield SenseGroupsStreamFrame(result: f.value, isFinal: f.isFinal);
      }
    } on NdjsonStreamException {
      throw const SenseGroupsStreamException();
    }
  }

  @override
  Stream<RetellReviewStreamFrame> evaluateReviewStream({
    required File audioFile,
    required String originalText,
    required String targetLanguage,
    required String accessToken,
    CancelToken? cancelToken,
  }) async* {
    final config = await _requireConfig();
    final transcript = await _audio.transcribe(
      config,
      audioFile,
      cancelToken: cancelToken,
    );
    // 转写完成先推一帧 transcript，让 UI 在等待评估期间就能显示转写文本；
    // 最终结果的 transcript 以真实转写为准，不信任模型的复述。
    Stream<Map<String, dynamic>> events() async* {
      yield {
        'ops': [
          {
            'p': ['transcript'],
            'v': transcript,
          },
        ],
      };
      yield* _jsonEvents(
        retellReviewPrompt(
          originalText: originalText,
          transcript: transcript,
          targetLanguage: targetLanguage,
        ),
        cancelToken: cancelToken,
        transform: (m) => {...m, 'transcript': transcript},
      );
    }

    try {
      await for (final f in accumulateNdjsonObject(
        events(),
        fromJson: RetellReviewEvaluation.fromJson,
      )) {
        yield RetellReviewStreamFrame(evaluation: f.value, isFinal: f.isFinal);
      }
    } on NdjsonStreamException {
      throw const RetellReviewStreamException();
    }
  }

  @override
  void dispose() {
    _chat.dispose();
    _audio.dispose();
    super.dispose();
  }
}
