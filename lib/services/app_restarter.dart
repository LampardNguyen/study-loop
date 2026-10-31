/// 应用重启（self-host 新增，仅 Android）。
///
/// 恢复备份后多数设置 Notifier 仍持有启动时的快照，重启进程让其全部
/// 从 SharedPreferences 重新加载。
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';

const _channel = MethodChannel('top.echo-loop/app_update');

/// 重启应用的函数；测试可 override。
final appRestarterProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    AppLogger.log('AppRestarter', 'restart requested');
    await _channel.invokeMethod<void>('restartApp');
  },
);
