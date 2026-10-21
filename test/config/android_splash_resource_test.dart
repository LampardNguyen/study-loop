/// Android 12+ 系统 SplashScreen 资源回归测试。
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 12+ splash icon uses the adaptive launcher icon', () {
    final styles = File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsStringSync();
    // 位图放进 layer-list 会被系统 SplashScreen 错误缩放（只剩一个色块），
    // 因此直接复用自适应图标，由系统按标准规则缩放与裁剪。
    expect(styles, contains('@mipmap/ic_launcher'));
    expect(styles, isNot(contains('@drawable/startup_logo')));
    expect(
      File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      ).existsSync(),
      isTrue,
    );
  });
}
