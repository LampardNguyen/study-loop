/// 原作者后端 API 是否已配置（自托管版默认未配置）。
///
/// 默认取编译期常量 [isBackendApiConfigured]；做成 provider 是为了让依赖后端的
/// 原有 UI 测试（精选 Podcast、社区资源等）可以 override 为 true 继续验证。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';

/// 原作者后端 API 是否已配置。
final backendApiConfiguredProvider = Provider<bool>(
  (ref) => isBackendApiConfigured,
);
