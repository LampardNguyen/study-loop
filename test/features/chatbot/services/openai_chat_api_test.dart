import 'package:dio/dio.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/features/chatbot/models/chat_message.dart';
import 'package:echo_loop/features/chatbot/services/chat_api_client.dart';
import 'package:echo_loop/features/chatbot/services/ndjson_text_stream.dart';
import 'package:echo_loop/features/chatbot/services/openai_chat_api.dart';
import 'package:echo_loop/services/openai/openai_chat_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeChat extends OpenAiChatClient {
  _FakeChat({this.deltas = const [], this.error});

  final List<String> deltas;
  final Object? error;
  List<OpenAiMessage>? lastMessages;

  @override
  Stream<String> streamCompletion(
    AiProviderConfig config,
    List<OpenAiMessage> messages, {
    bool jsonMode = false,
    double? temperature,
    CancelToken? cancelToken,
  }) async* {
    lastMessages = messages;
    yield* Stream.fromIterable(deltas);
    final e = error;
    if (e != null) throw e;
  }
}

void main() {
  const configured = AiProviderConfig(apiKey: 'sk-test');
  final history = [
    ChatMessage.user(
      id: '1',
      content: 'Why "gonna"?',
      createdAt: DateTime(2026),
    ),
  ];

  Stream<ChatTextFrame> run(
    _FakeChat chat, {
    AiProviderConfig config = configured,
  }) => OpenAiChatApi(readConfig: () async => config, chat: chat).streamChat(
    endpoint: '/unused',
    history: history,
    context: const {'sentence': "I'm gonna go."},
    followUpInstruction: 'Follow up:',
    targetLanguage: 'vi',
    accessToken: '',
  );

  test('逐帧累计全文，末帧 isFinal；system prompt 含句子与目标语言', () async {
    final chat = _FakeChat(deltas: ['"Gonna" ', 'là cách nói ', 'tắt.']);
    final frames = await run(chat).toList();

    expect(frames.map((f) => f.text), [
      '"Gonna" ',
      '"Gonna" là cách nói ',
      '"Gonna" là cách nói tắt.',
      '"Gonna" là cách nói tắt.',
    ]);
    expect(frames.last.isFinal, isTrue);
    expect(frames.where((f) => f.isFinal), hasLength(1));
    final system = chat.lastMessages!.first;
    expect(system.role, 'system');
    expect(system.content, contains("I'm gonna go."));
    expect(system.content, contains('Vietnamese'));
    expect(chat.lastMessages!.last.content, 'Why "gonna"?');
  });

  test('未配置 Key / 401 → ChatAuthRequiredException', () async {
    expect(
      run(_FakeChat(), config: const AiProviderConfig()).toList(),
      throwsA(isA<ChatAuthRequiredException>()),
    );
    final request = RequestOptions(path: '/chat/completions');
    expect(
      run(
        _FakeChat(
          error: DioException(
            requestOptions: request,
            response: Response(requestOptions: request, statusCode: 401),
          ),
        ),
      ).toList(),
      throwsA(isA<ChatAuthRequiredException>()),
    );
  });

  test('其它 HTTP 错误原样抛出（不发末帧）', () async {
    final request = RequestOptions(path: '/chat/completions');
    expect(
      run(
        _FakeChat(
          deltas: ['partial'],
          error: DioException(
            requestOptions: request,
            response: Response(requestOptions: request, statusCode: 429),
          ),
        ),
      ).toList(),
      throwsA(isA<DioException>()),
    );
  });
}
