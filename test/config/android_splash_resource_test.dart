/// Android 12+ 系统 SplashScreen 资源回归测试。
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 12+ splash icon blends into the splash background', () {
    final styles = File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsStringSync();
    // 位图放进 layer-list 会被系统 SplashScreen 错误缩放（只剩一个色块），
    // 因此用自适应图标（背景取启动页底色，避免出现白色圆底）。
    expect(styles, contains('@drawable/startup_splash_icon'));
    final icon = File(
      'android/app/src/main/res/drawable-v26/startup_splash_icon.xml',
    ).readAsStringSync();
    expect(icon, contains('<adaptive-icon'));
    expect(icon, contains('@color/startup_splash_background'));
    expect(styles, isNot(contains('@drawable/startup_logo')));
    expect(
      File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      ).existsSync(),
      isTrue,
    );
  });
}
