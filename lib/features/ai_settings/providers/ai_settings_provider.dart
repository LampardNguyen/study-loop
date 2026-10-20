/// AI 配置状态（单一来源）。
///
/// UI 与 AI 客户端都只通过 [aiSettingsProvider] 读取配置；
/// 修改统一走 [AiSettingsNotifier.save] / [AiSettingsNotifier.removeApiKey]。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/app_logger.dart';
import '../data/ai_settings_repository.dart';
import '../models/ai_provider_config.dart';

/// AI 配置 Notifier。
class AiSettingsNotifier extends AsyncNotifier<AiProviderConfig> {
  AiSettingsRepository get _repository =>
      ref.read(aiSettingsRepositoryProvider);

  @override
  Future<AiProviderConfig> build() async {
    final config = await _repository.load();
    AppLogger.log('AiSettings', 'loaded ${config.logSummary}');
    return config;
  }

  /// 保存配置（Base URL 自动规范化）。失败向上抛出，由 UI 提示。
  Future<void> save(AiProviderConfig config) async {
    final normalized = config.copyWith(
      apiKey: config.apiKey.trim(),
      baseUrl: normalizeAiBaseUrl(config.baseUrl),
      model: config.model.trim().isEmpty ? defaultAiModel : config.model.trim(),
    );
    await _repository.save(normalized);
    state = AsyncData(normalized);
  }

  /// 删除 API Key，保留 Base URL 与模型。
  Future<void> removeApiKey() async {
    final current = state.valueOrNull ?? const AiProviderConfig();
    await save(current.copyWith(apiKey: ''));
  }
}

/// AI 配置 Provider。
final aiSettingsProvider =
    AsyncNotifierProvider<AiSettingsNotifier, AiProviderConfig>(
      AiSettingsNotifier.new,
    );

/// 自托管版 AI「凭证」占位 token。
///
/// 原业务代码在调用 AI 前检查 Supabase access token；自托管版改为检查用户是否
/// 已在「AI 设置」里配置 API Key。已配置时返回占位 token（真实 Key 由 AI 客户端
/// 从安全存储读取，不经由这里传递），未配置返回 null，复用原有「需要登录」分支
/// 引导用户去配置 Key。
const selfHostedAiAccessToken = 'self-hosted-openai';

/// 当前是否可调用 AI：已配置 API Key → [selfHostedAiAccessToken]，否则 null。
final aiAccessTokenProvider = Provider<String?>((ref) {
  final configured =
      ref.watch(aiSettingsProvider).valueOrNull?.hasApiKey ?? false;
  return configured ? selfHostedAiAccessToken : null;
});
