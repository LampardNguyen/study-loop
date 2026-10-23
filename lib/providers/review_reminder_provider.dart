import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_tap_router_bridge.dart';
import '../services/review_reminder_service.dart';
import '../services/review_reminder_time_calculator.dart';
import 'reminder_settings_provider.dart';
import 'settings_provider.dart';

/// 通知点击桥接 Provider
final notificationTapRouterBridgeProvider =
    Provider<NotificationTapRouterBridge>((ref) {
      final bridge = NotificationTapRouterBridge();
      ref.onDispose(bridge.dispose);
      return bridge;
    });

/// 提醒时间计算策略 Provider
///
/// 从 [reminderSettingsNotifierProvider] 读取用户设置的 hour/minute，
/// 设置变更时自动重建。
final reviewReminderTimeCalculatorProvider =
    Provider<ReviewReminderTimeCalculator>((ref) {
      final settings = ref.watch(reminderSettingsNotifierProvider);
      return FixedTimeReminderCalculator(
        hour: settings.savedReviewReminderHour,
        minute: settings.savedReviewReminderMinute,
      );
    });

/// 复习提醒服务 Provider
///
/// 不 watch timeCalculator（避免 service 实例重建丢失 _initialized），
/// 改用 setter 在设置变更时更新。
final reviewReminderServiceProvider = Provider<ReviewReminderService>((ref) {
  final service = ReviewReminderService(
    plugin: FlutterLocalNotificationsPlugin(),
    bridge: ref.watch(notificationTapRouterBridgeProvider),
    timeCalculator: ref.read(reviewReminderTimeCalculatorProvider),
    // 通知文案跟随界面语言；未显式设置时按系统 locale 匹配
    localizations: () => lookupAppLocalizations(
      ref.read(appSettingsProvider).locale ??
          matchUiLocale(WidgetsBinding.instance.platformDispatcher.locale),
    ),
  );

  // 监听 timeCalculator 变更，通过 setter 更新（不重建 service）
  ref.listen<ReviewReminderTimeCalculator>(
    reviewReminderTimeCalculatorProvider,
    (_, next) => service.updateTimeCalculator(next),
  );

  return service;
});
