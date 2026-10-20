/// 自托管版聊天实现：直接用用户的 OpenAI 兼容接口完成「句子 AI 助手」对话。
///
/// 保持 [ChatApi] 契约：逐帧 yield 累计全文，正常结束的末帧 `isFinal=true`；
/// 401（Key 无效 / 未配置）→ [ChatAuthRequiredException]，其余 HTTP 错误抛带
/// 状态码的 [DioException]，由 controller 原有分支处理。
library;

import 'package:dio/dio.dart';

import '../../../services/openai/ai_prompts.dart';
import '../../../services/openai/openai_chat_client.dart';
import '../../../services/openai/openai_sentence_ai_api_client.dart'
    show AiConfigReader;
import '../models/chat_message.dart';
import 'chat_api_client.dart';
import 'ndjson_text_stream.dart';

/// 基于 OpenAI 兼容接口的 [ChatApi]。
class OpenAiChatApi implements ChatApi {
  /// 构造；[chat] 可注入以便测试。
  OpenAiChatApi({required AiConfigReader readConfig, OpenAiChatClient? chat})
    : _readConfig = readConfig,
      _chat = chat ?? OpenAiChatClient();

  final AiConfigReader _readConfig;
  final OpenAiChatClient _chat;

  @override
  Stream<ChatTextFrame> streamChat({
    required String endpoint,
    required List<ChatMessage> history,
    required Map<String, Object?> context,
    required String followUpInstruction,
    String? targetLanguage,
    required String accessToken,
    CancelToken? cancelToken,
  }) async* {
    final config = await _readConfig();
    if (!config.hasApiKey) throw const ChatAuthRequiredException();

    final messages = [
      OpenAiMessage.system(_systemPrompt(context, targetLanguage)),
      for (final m in history)
        OpenAiMessage(
          m.role.name,
          '${m.toWire(instruction: followUpInstruction)['content'] ?? ''}',
        ),
    ];

    final buffer = StringBuffer();
    try {
      await for (final delta in _chat.streamCompletion(
        config,
        messages,
        temperature: 0.7,
        cancelToken: cancelToken,
      )) {
        buffer.write(delta);
        yield ChatTextFrame(text: buffer.toString(), isFinal: false);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ChatAuthRequiredException();
      }
      rethrow;
    }
    if (cancelToken?.isCancelled ?? false) return; // 取消：不发末帧
    yield ChatTextFrame(text: buffer.toString(), isFinal: true);
  }

  /// 句子助手的 system prompt：围绕当前句子答疑，使用学习者母语回答。
  String _systemPrompt(Map<String, Object?> context, String? targetLanguage) {
    final lang = aiLanguageName(targetLanguage);
    final sentence = context['sentence'];
    return [
      'You are a friendly, concise English tutor inside a listening-practice '
          'app. Answer in $lang unless the learner writes in another language. '
          'Quote English words and example sentences in English. Use short '
          'paragraphs or bullet lists; Markdown is allowed.',
      if (sentence is String && sentence.isNotEmpty)
        'The learner is studying this sentence: "$sentence". Questions refer '
            'to it unless stated otherwise.',
    ].join('\n');
  }

  @override
  void dispose() => _chat.dispose();
}
