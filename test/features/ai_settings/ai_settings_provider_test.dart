import 'package:echo_loop/features/ai_settings/data/ai_settings_repository.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/features/ai_settings/providers/ai_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('首次读取为默认配置（未配置 Key）', () async {
    final container = createContainer();
    final config = await container.read(aiSettingsProvider.future);
    expect(config, const AiProviderConfig());
  });

  test('保存后规范化，并能被新的容器（模拟重启）读回', () async {
    final container = createContainer();
    await container.read(aiSettingsProvider.future);
    await container
        .read(aiSettingsProvider.notifier)
        .save(
          const AiProviderConfig(
            apiKey: '  sk-abc  ',
            baseUrl: 'https://api.openai.com/v1/',
            model: '  ',
          ),
        );

    const expected = AiProviderConfig(apiKey: 'sk-abc');
    expect(container.read(aiSettingsProvider).valueOrNull, expected);

    final restarted = createContainer();
    expect(await restarted.read(aiSettingsProvider.future), expected);
  });

  test('删除 Key 保留 Base URL 与模型', () async {
    final container = createContainer();
    await container.read(aiSettingsProvider.future);
    final notifier = container.read(aiSettingsProvider.notifier);
    await notifier.save(
      const AiProviderConfig(
        apiKey: 'sk-abc',
        baseUrl: 'https://openrouter.ai/api/v1',
        model: 'm1',
      ),
    );

    await notifier.removeApiKey();

    expect(
      container.read(aiSettingsProvider).valueOrNull,
      const AiProviderConfig(
        baseUrl: 'https://openrouter.ai/api/v1',
        model: 'm1',
      ),
    );
  });

  test('Key 只写入安全存储，不写入 SharedPreferences', () async {
    final container = createContainer();
    await container.read(aiSettingsProvider.future);
    await container
        .read(aiSettingsProvider.notifier)
        .save(const AiProviderConfig(apiKey: 'sk-only-secure'));

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      expect('${prefs.get(key)}', isNot(contains('sk-only-secure')));
    }
    final raw = await const FlutterSecureStorage().read(
      key: aiProviderConfigStorageKey,
    );
    expect(raw, contains('sk-only-secure'));
  });

  test('存储内容损坏时回退默认配置而不是报错', () async {
    FlutterSecureStorage.setMockInitialValues({
      aiProviderConfigStorageKey: '{not json',
    });
    final container = createContainer();
    expect(
      await container.read(aiSettingsProvider.future),
      const AiProviderConfig(),
    );
  });
}
