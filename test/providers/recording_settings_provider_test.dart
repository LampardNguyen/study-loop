import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:echo_loop/models/recording_settings.dart';
import 'package:echo_loop/providers/recording_settings_provider.dart';
import 'package:echo_loop/services/speech_practice_platform.dart';

/// 等待 Notifier 的异步加载落定（SharedPreferences mock 为同步完成的 Future）。
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecordingSettingsNotifier', () {
    test('无持久化值时为默认：标准音量 + 16kHz', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(recordingSettingsNotifierProvider);
      await _settle();

      expect(
        container.read(recordingSettingsNotifierProvider),
        const RecordingSettings(),
      );
    });

    test('修改后持久化，新容器能读回', () async {
      SharedPreferences.setMockInitialValues({});
      final first = ProviderContainer();
      final notifier = first.read(recordingSettingsNotifierProvider.notifier);
      await notifier.setGainLevel(RecordingGainLevel.extraLoud);
      await notifier.setQuality(RecordingQuality.good);
      first.dispose();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      second.read(recordingSettingsNotifierProvider);
      await _settle();

      expect(
        second.read(recordingSettingsNotifierProvider),
        const RecordingSettings(
          gainLevel: RecordingGainLevel.extraLoud,
          quality: RecordingQuality.good,
        ),
      );
    });

    test('持久化值无法识别时回退默认', () async {
      SharedPreferences.setMockInitialValues({
        'recording_gain_level': 'bogus',
        'recording_quality': 'high',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(recordingSettingsNotifierProvider);
      await _settle();

      expect(
        container.read(recordingSettingsNotifierProvider),
        const RecordingSettings(quality: RecordingQuality.high),
      );
    });
  });

  test('startSession 把音量档与采样率传给原生', () async {
    const channel = MethodChannel('top.echo-loop/speech_practice');
    Map<Object?, Object?>? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'startSession') {
            captured = call.arguments as Map<Object?, Object?>;
            return {'filePath': '/tmp/a.wav'};
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final platform = SpeechPracticePlatform()
      ..recordingSettings = () => const RecordingSettings(
        gainLevel: RecordingGainLevel.loud,
        quality: RecordingQuality.high,
      );
    await platform.startSession(promptId: 'p1');

    expect(captured?['gain'], 3.5);
    expect(captured?['sampleRate'], 44100);
  });
}
