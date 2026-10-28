import 'package:echo_loop/features/drive_sync/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

Material _material(WidgetTester tester) => tester.widget<Material>(
  find.descendant(
    of: find.byType(GoogleSignInButton),
    matching: find.byType(Material),
  ),
);

void main() {
  testWidgets('浅色主题：白底、规范描边、显示 G 标志与文字，可点击', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        GoogleSignInButton(
          label: 'Sign in with Google',
          onPressed: () => taps++,
        ),
      ),
    );
    final material = _material(tester);
    expect(material.color, Colors.white);
    expect(
      (material.shape! as StadiumBorder).side.color,
      const Color(0xFF747775),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    await tester.tap(find.byType(GoogleSignInButton));
    expect(taps, 1);
  });

  testWidgets('深色主题使用 #131314 底色与 #8E918F 描边', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GoogleSignInButton(label: 'x', onPressed: () {}),
        brightness: Brightness.dark,
      ),
    );
    final material = _material(tester);
    expect(material.color, const Color(0xFF131314));
    expect(
      (material.shape! as StadiumBorder).side.color,
      const Color(0xFF8E918F),
    );
  });

  testWidgets('加载中：标志换成进度圈且不可点击', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        GoogleSignInButton(label: 'x', loading: true, onPressed: () => taps++),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
    await tester.tap(find.byType(GoogleSignInButton));
    expect(taps, 0);
  });
}
