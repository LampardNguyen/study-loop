import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/services/openai/openai_audio_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _BytesAdapter implements HttpClientAdapter {
  _BytesAdapter(this.body, {this.status = 200});

  final List<int> body;
  final int status;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromBytes(body, status);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const config = AiProviderConfig(
    apiKey: 'sk-test',
    baseUrl: 'https://api.test/v1/',
    model: 'm1',
  );

  test('synthesizeSpeech 返回字节并发送正确请求', () async {
    final adapter = _BytesAdapter([1, 2, 3]);
    final client = OpenAiAudioClient(dio: Dio()..httpClientAdapter = adapter);

    final bytes = await client.synthesizeSpeech(
      config,
      input: 'Hi Anna.',
      voice: 'ash',
      instructions: 'friendly',
    );

    expect(bytes, [1, 2, 3]);
    final req = adapter.lastRequest!;
    expect(req.uri.toString(), 'https://api.test/v1/audio/speech');
    expect(req.headers['Authorization'], 'Bearer sk-test');
    expect(req.data, {
      'model': defaultSpeechModel,
      'input': 'Hi Anna.',
      'voice': 'ash',
      'response_format': 'mp3',
      'instructions': 'friendly',
    });
  });

  test('synthesizeSpeech 未传 instructions 时不发送该字段', () async {
    final adapter = _BytesAdapter([9]);
    final client = OpenAiAudioClient(dio: Dio()..httpClientAdapter = adapter);

    await client.synthesizeSpeech(config, input: 'x', voice: 'nova');

    expect(
      (adapter.lastRequest!.data as Map).containsKey('instructions'),
      isFalse,
    );
  });

  test('synthesizeSpeech 非 200 抛 DioException', () async {
    final client = OpenAiAudioClient(
      dio: Dio()..httpClientAdapter = _BytesAdapter([0], status: 401),
    );

    expect(
      client.synthesizeSpeech(config, input: 'x', voice: 'ash'),
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
