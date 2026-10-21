/// 启动数据 gate 等待期间的品牌过渡页。
///
/// 此组件只依赖系统明暗模式，不读取业务 Provider，确保数据库尚未安全可读时
/// 不会提前创建业务导航树或触发数据查询。
library;

import 'package:flutter/material.dart';

/// 原生与 Flutter 启动页共用的 Logo 源资源。
const _startupLogoAsset = 'assets/icon/app-icon-1024-alpha.png';

/// 保持与 Android/iOS 原生启动页一致的视觉尺寸。
const _startupLogoSize = 96.0;

/// 简洁的 Flutter 品牌启动页。
class StartupSplashScreen extends StatelessWidget {
  const StartupSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 启动页需与原生 Launch Screen 一致；自托管版深浅色模式都用浅色背景
    // （彩色猫图标在浅底上显示最佳）。应用主题在 MaterialApp 创建后照常生效。
    const backgroundColor = Color(0xFFF5F6FA);

    return ColoredBox(
      key: const ValueKey('startup-splash-background'),
      color: backgroundColor,
      child: Center(
        child: Image.asset(
          _startupLogoAsset,
          key: const ValueKey('startup-splash-logo'),
          width: _startupLogoSize,
          height: _startupLogoSize,
          semanticLabel: 'Study Loop',
        ),
      ),
    );
  }
}
