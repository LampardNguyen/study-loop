import 'dart:async';

import 'package:echo_loop/features/audio_trim/audio_trim_screen.dart';
import 'package:echo_loop/l10n/app_localizations.dart';
import 'package:echo_loop/models/audio_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/shared/test_fixtures.dart';

/// 试听播放器桩：记录 seek/play/pause，位置由测试经 [emitPosition] 推送。
class _FakePlayer implements TrimPreviewPlayer {
  final _position = StreamController<Duration>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  final log = <String>[];

  void emitPosition(Duration d) => _position.add(d);

  @override
  Future<Duration?> load(String path) async => const Duration(seconds: 100);
  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<bool> get playingStream => _playing.stream;
  @override
  Future<void> seek(Duration position) async =>
      log.add('seek ${position.inSeconds}');
  @override
  void play() {
    log.add('play');
    _playing.add(true);
  }

  @override
  Future<void> pause() async {
    log.add('pause');
    _playing.add(false);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late _FakePlayer player;
  final saved = <(Duration, Duration)>[];

  setUp(() {
    player = _FakePlayer();
    saved.clear();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    // audioPath 置空：不触发数据目录解析，时长取 totalDuration。
    final item = createTestAudioItem(
      totalDuration: 100,
    ).copyWith(audioPath: null);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AudioTrimScreen(
            audioItem: item,
            player: player,
            waveformLoader: (_) async => null,
            saver: (ref, AudioItem i, start, end) async {
              saved.add((start, end));
              return i;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inCard(String cardKey, String text) => find.descendant(
    of: find.byKey(ValueKey(cardKey)),
    matching: find.text(text),
  );

  FilledButton saveButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));

  testWidgets('未改动时保存按钮禁用；调整起点后可保存', (tester) async {
    await pumpScreen(tester);
    expect(saveButton(tester).onPressed, isNull);

    await tester.tap(inCard('audioTrimStartCard', '+1s'));
    await tester.pump();
    expect(inCard('audioTrimStartCard', '00:01.0'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(saved, [(const Duration(seconds: 1), const Duration(seconds: 100))]);
  });

  testWidgets('起点不能小于 0、终点不能超过时长', (tester) async {
    await pumpScreen(tester);
    await tester.tap(inCard('audioTrimStartCard', '−1s'));
    await tester.tap(inCard('audioTrimEndCard', '+1s'));
    await tester.pump();
    expect(inCard('audioTrimStartCard', '00:00.0'), findsOneWidget);
    expect(inCard('audioTrimEndCard', '01:40.0'), findsOneWidget);
  });

  testWidgets('起止至少保留 1 秒', (tester) async {
    await pumpScreen(tester);
    // 播放到 50s，把起点和终点都设到这里 → 终点被钳到 51s。
    player.emitPosition(const Duration(seconds: 50));
    await tester.pump();
    await tester.tap(inCard('audioTrimStartCard', 'Set here'));
    await tester.tap(inCard('audioTrimEndCard', 'Set here'));
    await tester.pump();
    expect(inCard('audioTrimStartCard', '00:50.0'), findsOneWidget);
    expect(inCard('audioTrimEndCard', '00:51.0'), findsOneWidget);
  });

  testWidgets('试听按钮：从起点播 5 秒、播到终点、播放整段并在终点自动暂停', (tester) async {
    await pumpScreen(tester);
    await tester.tap(inCard('audioTrimStartCard', '+1s'));
    await tester.tap(inCard('audioTrimEndCard', '−1s'));
    await tester.pump();

    await tester.tap(inCard('audioTrimStartCard', 'Play from here'));
    await tester.pump();
    expect(player.log, ['seek 1', 'play']);
    player.emitPosition(const Duration(seconds: 6));
    await tester.pump();
    expect(player.log.last, 'pause');

    player.log.clear();
    await tester.tap(inCard('audioTrimEndCard', 'Play up to here'));
    await tester.pump();
    expect(player.log, ['seek 94', 'play']);
    player.emitPosition(const Duration(seconds: 99));
    await tester.pump();
    expect(player.log.last, 'pause');

    player.log.clear();
    await tester.scrollUntilVisible(find.text('Play trimmed audio'), 100);
    await tester.tap(find.text('Play trimmed audio'));
    await tester.pump();
    expect(player.log, ['seek 1', 'play']);
    player.emitPosition(const Duration(seconds: 50));
    await tester.pump();
    expect(player.log.last, 'play');
    player.emitPosition(const Duration(seconds: 99));
    await tester.pump();
    expect(player.log.last, 'pause');
  });
}
