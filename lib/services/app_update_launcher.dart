/// App 更新启动器。
///
/// Google Play 渠道打开应用商店；APK 渠道在 Android 上优先应用内下载并调起
/// 系统安装器（传入 `context` 时），下载失败再回退为外部打开 APK 直链。
library;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/app_update_info.dart';
import '../widgets/apk_download_dialog.dart';
import 'apk_update_installer.dart';

class AppUpdateLauncher {
  final ApkUpdateInstaller? _installer;

  /// 测试用：强制走 Android 应用内安装分支（host 测试机 Platform.isAndroid=false）。
  final bool _forceAndroid;

  const AppUpdateLauncher({
    ApkUpdateInstaller? installer,
    bool forceAndroid = false,
  }) : _installer = installer,
       _forceAndroid = forceAndroid;

  Future<void> launch({
    required AppUpdateInfo info,
    required String? primaryUrl,
    BuildContext? context,
  }) async {
    if (primaryUrl == null || primaryUrl.isEmpty) return;
    if (context != null &&
        info.channel == AppUpdateChannel.androidApk &&
        (_forceAndroid || (!kIsWeb && Platform.isAndroid))) {
      final handled = await _installInApp(context, primaryUrl);
      if (handled) return;
    }
    final opened = await _tryLaunch(primaryUrl);
    if (!opened && info.channel == AppUpdateChannel.androidGooglePlay) {
      // 商店链接（market://）打不开时回退到 https 商店页：优先渠道配置，
      // 缺失则用顶层 fallback（_googlePlayDownloadUrl 写入的默认 Play 网页链接）。
      final fallback =
          info.platforms.android.googlePlay.fallbackUrl ??
          info.downloadUrl['fallback'];
      await _tryLaunch(fallback);
    }
  }

  /// 应用内下载并安装。返回 false 表示下载失败，由调用方回退到浏览器。
  Future<bool> _installInApp(BuildContext context, String url) async {
    final installer = _installer ?? ApkUpdateInstaller();
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (!await installer.canInstall()) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.updateInstallPermissionHint)),
      );
      final resumed = _waitForResume();
      await installer.openInstallPermissionSettings();
      await resumed;
      // 用户未授权：不下载，也不回退浏览器（浏览器下载后同样需要授权）。
      if (!await installer.canInstall()) return true;
    }
    if (!context.mounted) return true;

    final result = await showApkDownloadDialog(
      context: context,
      url: url,
      installer: installer,
    );
    if (result != ApkDownloadResult.failed) return true;

    messenger?.showSnackBar(SnackBar(content: Text(l10n.updateDownloadFailed)));
    return false;
  }

  /// 等待应用从授权页返回前台。
  Future<void> _waitForResume() {
    final completer = Completer<void>();
    late final AppLifecycleListener listener;
    listener = AppLifecycleListener(
      onResume: () {
        listener.dispose();
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  Future<bool> _tryLaunch(String? url) async {
    if (url == null || url.isEmpty) return false;
    try {
      return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
