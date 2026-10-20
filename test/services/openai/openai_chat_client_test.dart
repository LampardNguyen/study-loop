import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/services/openai/openai_chat_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// 回放预设 SSE 文本 / 错误体的 adapter。
class _SseAdapter implements HttpClientAdapter {
  _SseAdapter(this.body, {this.status = 200});

  final String body;
  final int status;
  RequestOptions? lastRequest;
  Object? lastData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    lastData = options.data;
    // 分两段发送，验证跨块拼行。
    final bytes = utf8.encode(body);
    final mid = bytes.length ~/ 2;
    return ResponseBody(
      Stream.fromIterable([
        Uint8List.fromList(bytes.sublist(0, mid)),
        Uint8List.fromList(bytes.sublist(mid)),
      ]),
      status,
    );
  }

  @override
  void close({bool force = false}) {}
}

String _chunk(String content) =>
    'data: ${jsonEncode({
      'choices': [
        {
          'delta': {'content': content},
        },
      ],
    })}\n\n';

void main() {
  const config = AiProviderConfig(
    apiKey: 'sk-test',
    baseUrl: 'https://api.test/v1/',
    model: 'm1',
  );

  test('解析 SSE 增量，忽略空行 / 非 data 行，遇 [DONE] 结束', () async {
    final adapter = _SseAdapter(
      ': keep-alive\n\n${_chunk('Hel')}${_chunk('lo')}'
      'data: {"choices":[{"delta":{}}]}\n\ndata: [DONE]\n\n${_chunk('ignored')}',
    );
    final client = OpenAiChatClient(dio: Dio()..httpClientAdapter = adapter);

    final deltas = await client.streamCompletion(config, const [
      OpenAiMessage.user('hi'),
    ], jsonMode: true).toList();

    expect(deltas.join(), 'Hello');
    expect(
      adapter.lastRequest?.uri.toString(),
      'https://api.test/v1/chat/completions',
    );
    expect(adapter.lastRequest?.headers['Authorization'], 'Bearer sk-test');
    final data = adapter.lastData as Map;
    expect(data['model'], 'm1');
    expect(data['stream'], isTrue);
    expect(data['response_format'], {'type': 'json_object'});
  });

  test('非 200 → 带状态码的 DioException', () async {
    final client = OpenAiChatClient(
      dio: Dio()
        ..httpClientAdapter = _SseAdapter(
          '{"error":{"code":"invalid_api_key"}}',
          status: 401,
        ),
    );

    expect(
      client.streamCompletion(config, const [
        OpenAiMessage.user('hi'),
      ]).toList(),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
  });
}
