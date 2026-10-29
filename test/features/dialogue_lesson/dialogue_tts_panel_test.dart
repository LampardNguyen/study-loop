import 'package:echo_loop/features/dialogue_lesson/dialogue_tts_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> pumpPanel(WidgetTester tester) async {
    await tester.pumpWidget(
      createTestApp(
        Scaffold(
          body: SingleChildScrollView(
            child: DialogueTtsPanel(
              collectionId: null,
              onBusyChanged: (_) {},
              onCompleted: (_) {},
              onBack: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  FilledButton createButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.byKey(const ValueKey('dialogue-tts-create')),
  );

  testWidgets('空对话时禁用创建按钮并提示格式', (tester) async {
    await pumpPanel(tester);

    expect(createButton(tester).onPressed, isNull);
    expect(
      find.text('Needs at least one line like “Name: sentence”.'),
      findsOneWidget,
    );
  });

  testWidgets('输入对话后显示统计、说话人声音并启用按钮', (tester) async {
    await pumpPanel(tester);

    await tester.enterText(
      find.byKey(const ValueKey('dialogue-tts-input')),
      'Mark: Hi Anna.\nAnna: Hi, Doctor.\nMark: Come in.',
    );
    await tester.pumpAndSettle();

    expect(find.text('3 lines · 2 speakers · 27 characters'), findsOneWidget);
    expect(find.text('Mark'), findsOneWidget);
    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('ash'), findsOneWidget);
    expect(find.text('nova'), findsOneWidget);
    expect(createButton(tester).onPressed, isNotNull);
  });

  testWidgets('单句超长时显示错误并禁用按钮', (tester) async {
    await pumpPanel(tester);

    await tester.enterText(
      find.byKey(const ValueKey('dialogue-tts-input')),
      'A: ${'x' * (dialogueMaxLineChars + 1)}',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Line 1 is too long (max 4,000 characters).'),
      findsOneWidget,
    );
    expect(createButton(tester).onPressed, isNull);
  });
}
