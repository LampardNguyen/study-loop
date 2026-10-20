/// OpenAI 兼容接口的流式 Chat Completions 客户端（自托管版）。
///
/// 只负责 HTTP 与 SSE 解析：`POST {baseUrl}/chat/completions`（`stream: true`），
/// 逐个产出 `choices[0].delta.content` 文本增量。业务 prompt 与结果结构由上层决定。
///
/// 错误约定：非 200 抛带状态码的 [DioException]（`badResponse`），让现有 provider
/// 的 401 / 402 等映射逻辑原样生效；API Key 不会出现在日志里。
library;

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../features/ai_settings/models/ai_provider_config.dart';
import '../app_logger.dart';

/// Chat 消息。
class OpenAiMessage {
  /// 构造消息。
  const OpenAiMessage(this.role, this.content);

  /// system 消息。
  const OpenAiMessage.system(String content) : this('system', content);

  /// user 消息。
  const OpenAiMessage.user(String content) : this('user', content);

  /// assistant 消息。
  const OpenAiMessage.assistant(String content) : this('assistant', content);

  /// 角色：system / user / assistant。
  final String role;

  /// 文本内容。
  final String content;

  /// 序列化为请求体。
  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// OpenAI 兼容 Chat 客户端。
class OpenAiChatClient {
  /// 构造客户端；[dio] 可注入以便测试。
  OpenAiChatClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              // 只约束到首个响应头；帧间停顿由 [idleTimeout] 兜底。
              receiveTimeout: const Duration(seconds: 60),
            ),
          );

  final Dio _dio;

  /// 两个 SSE 数据块之间允许的最长停顿。
  static const idleTimeout = Duration(seconds: 45);

  /// 流式请求，逐个产出文本增量。
  ///
  /// [jsonMode] 为 true 时要求模型输出 JSON 对象（`response_format: json_object`）。
  Stream<String> streamCompletion(
    AiProviderConfig config,
    List<OpenAiMessage> messages, {
    bool jsonMode = false,
    double? temperature,
    CancelToken? cancelToken,
  }) async* {
    final url = '${normalizeAiBaseUrl(config.baseUrl)}/chat/completions';
    AppLogger.log(
      'OpenAI',
      'chat stream start ${config.logSummary} json=$jsonMode '
          'messages=${messages.length}',
    );
    final response = await _dio.post<ResponseBody>(
      url,
      data: {
        'model': config.model,
        'stream': true,
        'messages': [for (final m in messages) m.toJson()],
        if (jsonMode) 'response_format': {'type': 'json_object'},
        'temperature': ?temperature,
      },
      options: Options(
        responseType: ResponseType.stream,
        validateStatus: (_) => true,
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Accept': 'text/event-stream',
        },
      ),
      cancelToken: cancelToken,
    );

    final body = response.data;
    final status = response.statusCode ?? 0;
    if (body == null || status != 200) {
      final error = body == null ? null : await _readErrorBody(body);
      AppLogger.log(
        'OpenAI',
        'chat stream failed status=$status error=${_errorCode(error)}',
      );
      throw DioException(
        requestOptions: response.requestOptions,
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: status,
          data: error,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    var chunks = 0;
    await for (final line
        in body.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .timeout(idleTimeout)) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('data:')) continue;
      final payload = trimmed.substring(5).trim();
      if (payload == '[DONE]') break;
      final Object? decoded;
      try {
        decoded = jsonDecode(payload);
      } on FormatException {
        continue; // 单个损坏块忽略，最终结果由上层严格校验
      }
      final delta = _deltaContent(decoded);
      if (delta != null && delta.isNotEmpty) {
        chunks++;
        yield delta;
      }
    }
    AppLogger.log('OpenAI', 'chat stream done chunks=$chunks');
  }

  /// 释放资源。
  void dispose() => _dio.close();

  /// 取 OpenAI 错误体里的 `error.code` / `error.type`（只记录错误码，不记录正文）。
  static String _errorCode(Map<String, dynamic>? body) {
    final error = body?['error'];
    if (error is! Map) return '(空)';
    return '${error['code'] ?? error['type'] ?? '(空)'}';
  }

  /// 取 `choices[0].delta.content`。
  static String? _deltaContent(Object? decoded) {
    if (decoded is! Map) return null;
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map) return null;
    final delta = first['delta'];
    if (delta is! Map) return null;
    final content = delta['content'];
    return content is String ? content : null;
  }

  Future<Map<String, dynamic>?> _readErrorBody(ResponseBody body) async {
    try {
      final text = await utf8.decodeStream(body.stream);
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
