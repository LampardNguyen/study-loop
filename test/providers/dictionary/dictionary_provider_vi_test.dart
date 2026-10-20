/// 越南语母语没有内置离线词典：词典 provider 必须进入 unavailable，
/// 且不发起下载（dictionarySpecOf('vi') 会抛 ArgumentError）。
library;

import 'package:echo_loop/features/onboarding_survey/providers/onboarding_survey_provider.dart';
import 'package:echo_loop/providers/dictionary_provider.dart';
import 'package:echo_loop/providers/settings_provider.dart';
import 'package:echo_loop/services/dictionary/dictionary_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('hasOfflineDictionary：中文有、越南语没有', () {
    expect(hasOfflineDictionary('zh-CN'), isTrue);
    expect(hasOfflineDictionary('zh-TW'), isTrue);
    expect(hasOfflineDictionary('vi'), isFalse);
  });

  test('母语为越南语 → unavailable，重试下载不改变状态', () async {
    SharedPreferences.setMockInitialValues({'native_language': 'vi'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await container.read(appSettingsProvider.notifier).setNativeLanguage('vi');
    container.read(dictionaryProvider);
    await pumpEventQueue();

    expect(container.read(dictionaryProvider).nativeLanguage, 'vi');
    expect(
      container.read(dictionaryProvider).status,
      DictionaryStatus.unavailable,
    );

    await container.read(dictionaryProvider.notifier).retryDownload();
    expect(
      container.read(dictionaryProvider).status,
      DictionaryStatus.unavailable,
    );
  });
}
