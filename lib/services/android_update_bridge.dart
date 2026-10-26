/// Android 更新原生桥接。
///
/// 只在 Android 平台调用：读取安装来源，用于区分应用商店安装和 APK 直装；
/// APK 直装渠道还负责「安装未知应用」授权检查与调起系统安装器。
library;

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/services.dart';

import 'app_logger.dart';

/// Android 更新桥接接口，便于单测注入 fake。
abstract interface class AndroidUpdateBridge {
  Future<String?> installerPackageName();

  /// 是否已允许本应用「安装未知应用」。
  Future<bool> canInstallPackages();

  /// 打开「安装未知应用」授权页。
  Future<void> openInstallPermissionSettings();

  /// 调起系统安装器安装 [path] 处的 APK（须位于缓存目录 `updates/` 下）。
  Future<void> installApk(String path);
}

/// MethodChannel 实现。
class MethodChannelAndroidUpdateBridge implements AndroidUpdateBridge {
  const MethodChannelAndroidUpdateBridge();

  @visibleForTesting
  static const channel = MethodChannel('top.echo-loop/app_update');

  @override
  Future<String?> installerPackageName() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      return await channel.invokeMethod<String>('getInstallerPackageName');
    } catch (e) {
      AppLogger.log('AppUpdateBridge', 'installer source failed: $e');
      return null;
    }
  }

  @override
  Future<bool> canInstallPackages() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return await channel.invokeMethod<bool>('canInstallPackages') ?? false;
  }

  @override
  Future<void> openInstallPermissionSettings() =>
      channel.invokeMethod<void>('openInstallPermissionSettings');

  @override
  Future<void> installApk(String path) =>
      channel.invokeMethod<void>('installApk', {'path': path});
}
