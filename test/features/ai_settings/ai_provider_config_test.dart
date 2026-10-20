import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiProviderConfig', () {
    test('默认无 Key，使用 OpenAI 官方地址与默认模型', () {
      const config = AiProviderConfig();
      expect(config.hasApiKey, isFalse);
      expect(config.maskedApiKey, isEmpty);
      expect(config.baseUrl, defaultAiBaseUrl);
      expect(config.model, defaultAiModel);
    });

    test('脱敏只保留 sk- 前缀与末 4 位', () {
      const config = AiProviderConfig(apiKey: 'sk-proj-abcdefgh1234');
      expect(config.maskedApiKey, 'sk-••••1234');
      expect(config.maskedApiKey, isNot(contains('abcdefgh')));
    });

    test('日志摘要不包含 Key', () {
      const config = AiProviderConfig(apiKey: 'sk-secret-value-9999');
      expect(config.logSummary, contains('hasKey=true'));
      expect(config.logSummary, contains('baseUrlHost=api.openai.com'));
      expect(config.logSummary, isNot(contains('secret')));
    });

    test('JSON 往返；缺失/空白字段回退默认，Base URL 规范化', () {
      const original = AiProviderConfig(
        apiKey: 'sk-1',
        baseUrl: 'https://openrouter.ai/api/v1',
        model: 'gpt-x',
      );
      expect(AiProviderConfig.fromJson(original.toJson()), original);
      expect(
        AiProviderConfig.fromJson({
          'apiKey': ' ',
          'baseUrl': 'https://a.test/v1//',
        }),
        const AiProviderConfig(baseUrl: 'https://a.test/v1'),
      );
    });
  });

  group('validateAiBaseUrl', () {
    test('https 合法', () {
      expect(validateAiBaseUrl('https://api.openai.com/v1/'), isNull);
    });

    test('http 仅放行本机与局域网', () {
      expect(validateAiBaseUrl('http://localhost:11434/v1'), isNull);
      expect(validateAiBaseUrl('http://192.168.1.20:8080/v1'), isNull);
      expect(validateAiBaseUrl('http://10.0.0.2/v1'), isNull);
      expect(
        validateAiBaseUrl('http://api.example.com/v1'),
        AiBaseUrlError.insecure,
      );
      expect(
        validateAiBaseUrl('http://172.32.0.1/v1'),
        AiBaseUrlError.insecure,
      );
    });

    test('空串 / 无协议 / 其他协议非法', () {
      expect(validateAiBaseUrl(''), AiBaseUrlError.invalid);
      expect(validateAiBaseUrl('api.openai.com'), AiBaseUrlError.invalid);
      expect(validateAiBaseUrl('ftp://x.test'), AiBaseUrlError.invalid);
    });
  });
}
