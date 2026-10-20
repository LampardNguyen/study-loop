import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/features/ai_settings/services/ai_connection_tester.dart';
import 'package:flutter_test/flutter_test.dart';

/// 记录请求并返回预设响应的 adapter；[error] 非空时模拟网络错误。
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.status = 200, this.body = '{}', this.error});

  final int status;
  final String body;
  final DioExceptionType? error;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final type = error;
    if (type != null) {
      throw DioException(requestOptions: options, type: type);
    }
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const config = AiProviderConfig(
    apiKey: 'sk-test',
    baseUrl: 'https://api.test/v1/',
  );

  AiConnectionTester testerWith(_FakeAdapter adapter) =>
      AiConnectionTester(dio: Dio()..httpClientAdapter = adapter);

  test('200 → 成功并返回模型数量；请求 /models 且带 Bearer', () async {
    final adapter = _FakeAdapter(
      body: jsonEncode({
        'data': [
          {'id': 'a'},
          {'id': 'b'},
        ],
      }),
    );

    final result = await testerWith(adapter).test(config);

    expect(result, isA<AiConnectionOk>());
    expect((result as AiConnectionOk).modelCount, 2);
    expect(adapter.lastRequest?.uri.toString(), 'https://api.test/v1/models');
    expect(adapter.lastRequest?.headers['Authorization'], 'Bearer sk-test');
  });

  test('401 → Key 无效', () async {
    final result = await testerWith(_FakeAdapter(status: 401)).test(config);
    expect(result, isA<AiConnectionUnauthorized>());
  });

  test('500 → HTTP 错误', () async {
    final result = await testerWith(_FakeAdapter(status: 500)).test(config);
    expect(result, isA<AiConnectionHttpError>());
    expect((result as AiConnectionHttpError).statusCode, 500);
  });

  test('连接失败 → 网络错误', () async {
    final result = await testerWith(
      _FakeAdapter(error: DioExceptionType.connectionError),
    ).test(config);
    expect(result, isA<AiConnectionNetworkError>());
    expect(
      (result as AiConnectionNetworkError).message,
      'api.test (connectionError)',
    );
  });
}
