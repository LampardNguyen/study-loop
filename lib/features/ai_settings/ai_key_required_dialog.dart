/// 自托管版「AI 未配置」引导（替代原「需要登录」弹窗，设计稿见
/// `docs/selfhost/design-ai-key-required.md`）。
///
/// 自托管版不需要登录；使用 AI 的唯一前提是用户已在「AI 设置」中填写 API Key。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'providers/ai_settings_provider.dart';
import 'screens/ai_settings_screen.dart';

/// 打开「AI 设置」页，返回时页面已关闭。
Future<void> openAiSettings(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(builder: (_) => const AiSettingsScreen()),
  );
}

/// 执行 AI 操作前确认已配置 Key。
///
/// 已配置直接返回 true；否则弹窗引导去「AI 设置」，用户配置好返回后返回 true
/// （调用方可直接继续原操作），取消或仍未配置返回 false。
Future<bool> ensureAiConfiguredForAction({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  if (ref.read(aiAccessTokenProvider) != null) return true;

  final l10n = AppLocalizations.of(context);
  final shouldOpen = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n?.aiKeyRequiredTitle ?? 'AI is not set up'),
      content: Text(
        l10n?.aiKeyRequiredMessage ??
            'Add your own OpenAI-compatible API key in AI Settings to use AI '
                'features.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n?.aiOpenSettings ?? 'Open AI Settings'),
        ),
      ],
    ),
  );
  if (!context.mounted || shouldOpen != true) return false;

  await openAiSettings(context);
  return context.mounted && ref.read(aiAccessTokenProvider) != null;
}
