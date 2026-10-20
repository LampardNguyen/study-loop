/// 分析系统 Riverpod Provider 注册
///
/// 参考 [appDatabaseProvider] 的模式：在 `main()` 中提前初始化，
/// Provider 同步暴露。业务代码通过 `ref.read(analyticsServiceProvider)`
/// 获取 [AnalyticsService] 实例。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_channel.dart';
import 'analytics_service.dart';
import 'channels/log_only_channel.dart';
import 'consent_manager.dart';
import '../services/app_logger.dart';

/// 分析服务 Provider。
///
/// 生产环境必须由根 [ProviderScope] 在 `runApp()` 前 override 为已初始化的
/// 最终实例。这样 Riverpod 首次缓存的对象不会在后台初始化完成后被替换。
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  throw StateError(
    'analyticsServiceProvider must be overridden at app startup',
  );
});

/// 初始化分析服务
///
/// 通道选择策略（自托管版）：所有模式都只用 LogOnly，
/// 埋点仅写本地日志，不发送到任何第三方（已移除 Firebase / PostHog / 友盟）。
Future<AnalyticsService> initAnalyticsService(
  SharedPreferences prefs, {
  AnalyticsChannel Function()? channelFactory,
}) async {
  final consent = ConsentManager(prefs);
  final channel = (channelFactory ?? _createChannel)();

  await channel.initialize();

  return AnalyticsService(channel: channel, consent: consent);
}

/// 初始化最终 analytics service；SDK 失败只降级埋点，绝不阻断应用启动。
Future<AnalyticsService> initializeAnalyticsWithFallback(
  SharedPreferences prefs, {
  AnalyticsChannel Function()? channelFactory,
}) async {
  try {
    return await initAnalyticsService(prefs, channelFactory: channelFactory);
  } catch (error, stackTrace) {
    AppLogger.log(
      'Analytics',
      'Analytics initialization failed; using LogOnly: $error',
    );
    AppLogger.log('Analytics', stackTrace.toString());
    final fallback = LogOnlyChannel();
    await fallback.initialize();
    return AnalyticsService(channel: fallback, consent: ConsentManager(prefs));
  }
}

/// 根据配置选择分析通道：自托管版固定为本地日志通道。
AnalyticsChannel _createChannel() => LogOnlyChannel();
