import 'dart:async';

import 'package:echo_loop/features/ai_settings/data/ai_settings_repository.dart';
import 'package:echo_loop/features/ai_settings/models/ai_provider_config.dart';
import 'package:echo_loop/features/ai_settings/providers/ai_settings_provider.dart';
import 'package:echo_loop/features/ai_settings/screens/ai_settings_screen.dart';
import 'package:echo_loop/features/ai_settings/services/ai_connection_tester.dart';
import 'package:echo_loop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// 记录收到的配置并返回可控结果的测试器。
class _FakeTester extends AiConnectionTester {
  _FakeTester(this.result);

  final Completer<AiConnectionResult> result;
  AiProviderConfig? lastConfig;

  @override
  Future<AiConnectionResult> test(AiProviderConfig config) {
    lastConfig = config;
    return result.future;
  }
}

/// 读取即失败的仓库，用于验证错误态。
class _FailingRepository extends AiSettingsRepository {
  @override
  Future<AiProviderConfig> load() async =>
      throw const AiSettingsStorageException('boom');
}

void main() {
  late ProviderContainer container;
  late _FakeTester tester;

  Future<void> pumpScreen(
    WidgetTester widgetTester, {
    List<Override> overrides = const [],
  }) async {
    // 表单较长：放大测试画布，避免按钮落在视口外导致点击失效。
    widgetTester.view.physicalSize = const Size(1080, 2400);
    widgetTester.view.devicePixelRatio = 1.0;
    addTearDown(widgetTester.view.reset);
    tester = _FakeTester(Completer<AiConnectionResult>());
    container = ProviderContainer(
      overrides: [
        aiConnectionTesterProvider.overrideWithValue(tester),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    await widgetTester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('en'), Locale('zh')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AiSettingsScreen(),
        ),
      ),
    );
    await widgetTester.pumpAndSettle();
  }

  Finder field(String key) => find.byKey(ValueKey(key));

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('未配置：保存与测试不可用，提示先输入 Key', (t) async {
    await pumpScreen(t);

    expect(find.text('Enter an API key first'), findsOneWidget);
    expect(
      t
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .onPressed,
      isNull,
    );
    expect(find.text('Remove API key'), findsNothing);
  });

  testWidgets('输入 Key 后保存：写入配置，输入框清空并显示脱敏提示', (t) async {
    await pumpScreen(t);

    await t.enterText(field('aiSettingsApiKeyField'), 'sk-test-abcd1234');
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, 'Save'));
    await t.pumpAndSettle();

    expect(
      container.read(aiSettingsProvider).valueOrNull?.apiKey,
      'sk-test-abcd1234',
    );
    expect(find.text('AI settings saved'), findsOneWidget);
    expect(find.text('Saved: sk-••••1234 — type to replace'), findsOneWidget);
    // 已保存的 Key 不回填进输入框。
    expect(
      t.widget<TextField>(field('aiSettingsApiKeyField')).controller?.text,
      isEmpty,
    );
    expect(find.text('Remove API key'), findsOneWidget);
  });

  testWidgets('非 https 地址显示错误并禁用保存', (t) async {
    await pumpScreen(t);

    await t.enterText(field('aiSettingsApiKeyField'), 'sk-1');
    await t.enterText(
      field('aiSettingsBaseUrlField'),
      'http://api.evil.com/v1',
    );
    await t.pump();

    expect(
      find.text('Use https (http is only allowed for localhost / LAN)'),
      findsOneWidget,
    );
    expect(
      t
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('测试连接使用正在编辑的值，并展示结果', (t) async {
    await pumpScreen(t);

    await t.enterText(field('aiSettingsApiKeyField'), 'sk-draft');
    await t.pump();
    await t.tap(find.text('Test connection'));
    await t.pump();
    expect(tester.lastConfig?.apiKey, 'sk-draft');

    tester.result.complete(const AiConnectionUnauthorized(401));
    await t.pumpAndSettle();

    expect(find.text('Invalid API key (401)'), findsOneWidget);
    // 测试不会保存。
    expect(container.read(aiSettingsProvider).valueOrNull?.hasApiKey, isFalse);
  });

  testWidgets('删除 Key 需确认，确认后清除', (t) async {
    FlutterSecureStorage.setMockInitialValues({});
    await pumpScreen(t);
    await container
        .read(aiSettingsProvider.notifier)
        .save(const AiProviderConfig(apiKey: 'sk-old'));
    await t.pumpAndSettle();

    await t.tap(find.text('Remove API key'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Remove API key').last);
    await t.pumpAndSettle();

    expect(container.read(aiSettingsProvider).valueOrNull?.hasApiKey, isFalse);
    expect(find.text('API key removed'), findsOneWidget);
  });

  testWidgets('读取失败：显示错误横幅且仍可重新输入', (t) async {
    await pumpScreen(
      t,
      overrides: [
        aiSettingsRepositoryProvider.overrideWithValue(_FailingRepository()),
      ],
    );

    expect(
      find.text('Could not read saved AI settings. You can enter them again.'),
      findsOneWidget,
    );
    expect(field('aiSettingsApiKeyField'), findsOneWidget);
  });
}
