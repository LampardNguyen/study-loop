import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:echo_loop/l10n/app_localizations.dart';
import 'package:echo_loop/models/recording_settings.dart';
import 'package:echo_loop/models/speech_practice_models.dart';
import 'package:echo_loop/providers/recording_settings_provider.dart';
import 'package:echo_loop/screens/recording_settings_screen.dart';
import 'package:echo_loop/services/recording_trial.dart';
import 'package:echo_loop/services/speech_practice_platform.dart';

/// 最小假后端：权限可控，录音立即成功
class _Backend implements SpeechPracticeBackend {
  _Backend({required this.micGranted});
  final bool micGranted;

  SpeechPracticePermissionState get _perm => SpeechPracticePermissionState(
    microphone: micGranted
        ? SpeechPracticePermissionStatus.granted
        : SpeechPracticePermissionStatus.denied,
  );

  @override
  bool get isSupported => true;
  @override
  Future<SpeechPracticePermissionState> getPermissionStatus() async => _perm;
  @override
  Future<SpeechPracticePermissionState> requestPermissions({
    bool onlyMic = false,
  }) async => _perm;
  @override
  Stream<SpeechPracticeEvent> get events => const Stream.empty();
  @override
  Future<int> getDeviceRamBytes() async => 0;
  @override
  Future<void> setRecognitionEnabled(bool enabled) async {}
  @override
  Future<void> warmup({String locale = 'en-US'}) async {}
  @override
  Future<String> startSession({
    required String promptId,
    String locale = 'en-US',
  }) async => '/tmp/t.wav';
  @override
  Future<SpeechPracticeStopResult> stopSession() async =>
      const SpeechPracticeStopResult(filePath: '/tmp/t.wav');
  @override
  Future<void> cancelSession() async {}
  @override
  Future<void> deleteRecording(String filePath) async {}
  @override
  Future<void> shutdown() async {}
}

Widget _app(ProviderContainer container, RecordingTrial Function() trial) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: RecordingSettingsScreen(trialBuilder: trial),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('选择音量档和音质档写入设置', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      _app(
        container,
        () => RecordingTrial(
          backend: _Backend(micGranted: true),
          play: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rất to'));
    await tester.scrollUntilVisible(find.text('Cao'), 100);
    await tester.tap(find.text('Cao'));
    await tester.pumpAndSettle();

    expect(
      container.read(recordingSettingsNotifierProvider),
      const RecordingSettings(
        gainLevel: RecordingGainLevel.extraLoud,
        quality: RecordingQuality.high,
      ),
    );
  });

  testWidgets('试录：显示倒计时与回放，结束后恢复按钮', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    Completer<void>? pendingTick;
    final playDone = Completer<void>();
    var waits = 0;
    await tester.pumpWidget(
      _app(
        container,
        () => RecordingTrial(
          backend: _Backend(micGranted: true),
          seconds: 2,
          wait: (_) {
            waits++;
            return (pendingTick = Completer<void>()).future;
          },
          play: (_) => playDone.future,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Ghi thử 5 giây'), 100);
    await tester.tap(find.text('Ghi thử 5 giây'));
    await tester.pump();
    expect(find.text('Đang ghi… 2s'), findsOneWidget);

    pendingTick!.complete();
    await tester.pump();
    expect(find.text('Đang ghi… 1s'), findsOneWidget);

    pendingTick!.complete();
    await tester.pump();
    await tester.pump();
    expect(find.text('Đang phát lại…'), findsOneWidget);

    playDone.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ghi thử 5 giây'), findsOneWidget);
    expect(waits, 2);
  });

  testWidgets('试录无麦克风权限时提示', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      _app(
        container,
        () => RecordingTrial(
          backend: _Backend(micGranted: false),
          play: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Ghi thử 5 giây'), 100);
    await tester.tap(find.text('Ghi thử 5 giây'));
    await tester.pumpAndSettle();

    expect(
      find.text('Chưa cấp quyền micro. Hãy bật trong cài đặt hệ thống.'),
      findsOneWidget,
    );
  });
}
