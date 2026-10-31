import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:echo_loop/features/drive_sync/drive_sync_screen.dart';
import 'package:echo_loop/l10n/app_localizations.dart';

void main() {
  testWidgets('恢复完成对话框：点击外部不关闭，点击重新启动调用 restart', (tester) async {
    var restarts = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showRestoreDoneDialog(context, () async => restarts++),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Khôi phục xong'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Khôi phục xong'), findsOneWidget);

    await tester.tap(find.text('Khởi động lại'));
    await tester.pump();
    expect(restarts, 1);
  });
}
