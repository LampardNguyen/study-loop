import 'package:echo_loop/l10n/app_localizations.dart';
import 'package:echo_loop/services/playback_volume_settings.dart';
import 'package:echo_loop/widgets/playback_volume_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(
    () => PlaybackVolumeSettings.notifier.value = const PlaybackVolume(),
  );

  testWidgets('mở sheet, bật chuẩn hoá, đặt lại', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(appBar: AppBar(actions: const [PlaybackVolumeButton()])),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('playback-volume-button')));
    await tester.pumpAndSettle();
    expect(find.text('Âm lượng phát'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('playback-volume-normalize')));
    await tester.pump();
    expect(PlaybackVolumeSettings.value.normalize, isTrue);

    PlaybackVolumeSettings.notifier.value = const PlaybackVolume(
      percent: 150,
      normalize: true,
    );
    await tester.pump();
    expect(find.text('150%'), findsOneWidget);
    expect(
      find.text('Mức trên 100% có thể bị rè với file vốn đã to.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Đặt lại (100%)'));
    await tester.pump();
    expect(PlaybackVolumeSettings.value, const PlaybackVolume());
  });
}
