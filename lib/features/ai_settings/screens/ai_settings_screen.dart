/// AI 设置页面（自托管版）：用户自行输入 OpenAI 兼容接口的 API Key / 地址 / 模型。
///
/// 设计稿：`docs/selfhost/design-ai-settings.md`。
/// 页面只负责表单与展示；持久化走 [aiSettingsProvider]，连接测试走
/// [aiConnectionTesterProvider]。已保存的 Key 不会回填进输入框，只显示脱敏提示。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/app_logger.dart';
import '../../../theme/app_theme.dart';
import '../models/ai_provider_config.dart';
import '../providers/ai_settings_provider.dart';
import '../services/ai_connection_tester.dart';

/// AI 设置页面。
class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(aiSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiSettingsTitle)),
      body: switch (settings) {
        AsyncData(:final value) => _AiSettingsForm(saved: value),
        AsyncError() => _AiSettingsForm(
          saved: const AiProviderConfig(),
          loadFailed: true,
        ),
        _ => const LinearProgressIndicator(),
      },
    );
  }
}

/// 表单本体：局部 state 只保存「正在编辑」的输入与测试结果。
class _AiSettingsForm extends ConsumerStatefulWidget {
  const _AiSettingsForm({required this.saved, this.loadFailed = false});

  /// 已保存的配置。
  final AiProviderConfig saved;

  /// 读取安全存储是否失败。
  final bool loadFailed;

  @override
  ConsumerState<_AiSettingsForm> createState() => _AiSettingsFormState();
}

class _AiSettingsFormState extends ConsumerState<_AiSettingsForm> {
  late final TextEditingController _keyController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  bool _obscureKey = true;
  bool _testing = false;
  bool _saving = false;
  AiConnectionResult? _testResult;

  /// 测试请求标识：只有最新一次测试的结果才会落到界面上。
  int _testToken = 0;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController();
    _baseUrlController = TextEditingController(text: widget.saved.baseUrl);
    _modelController = TextEditingController(text: widget.saved.model);
    for (final c in [_keyController, _baseUrlController, _modelController]) {
      c.addListener(_onEdited);
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _onEdited() => setState(() {});

  /// 由输入框组装出的待保存配置；Key 输入为空时沿用已保存的 Key。
  AiProviderConfig get _draft => AiProviderConfig(
    apiKey: _keyController.text.trim().isEmpty
        ? widget.saved.apiKey
        : _keyController.text.trim(),
    baseUrl: normalizeAiBaseUrl(_baseUrlController.text),
    model: _modelController.text.trim().isEmpty
        ? defaultAiModel
        : _modelController.text.trim(),
  );

  AiBaseUrlError? get _baseUrlError =>
      validateAiBaseUrl(_baseUrlController.text);

  bool get _hasChanges => _draft != widget.saved;

  String? _baseUrlErrorText(AppLocalizations l10n) {
    return switch (_baseUrlError) {
      AiBaseUrlError.invalid => l10n.aiSettingsBaseUrlInvalid,
      AiBaseUrlError.insecure => l10n.aiSettingsBaseUrlInsecure,
      null => null,
    };
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(aiSettingsProvider.notifier).save(_draft);
      _keyController.clear();
      messenger.showSnackBar(SnackBar(content: Text(l10n.aiSettingsSaved)));
    } catch (error) {
      AppLogger.log('AiSettings', 'save failed: ${error.runtimeType}');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.aiSettingsSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _testConnection() async {
    final token = ++_testToken;
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final result = await ref.read(aiConnectionTesterProvider).test(_draft);
    if (!mounted || token != _testToken) return;
    setState(() {
      _testing = false;
      _testResult = result;
    });
  }

  Future<void> _confirmRemoveKey() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.aiSettingsRemoveKey),
        content: Text(l10n.aiSettingsRemoveKeyConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.aiSettingsRemoveKey),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(aiSettingsProvider.notifier).removeApiKey();
      _keyController.clear();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.aiSettingsRemoveKeyDone)),
      );
    } catch (error) {
      AppLogger.log('AiSettings', 'remove key failed: ${error.runtimeType}');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.aiSettingsSaveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasKey = _draft.hasApiKey;
    final urlValid = _baseUrlError == null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        if (widget.loadFailed) ...[
          _ErrorBanner(message: l10n.aiSettingsLoadFailed),
          const SizedBox(height: AppSpacing.m),
        ],
        Text(
          l10n.aiSettingsIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              children: [
                TextField(
                  key: const ValueKey('aiSettingsApiKeyField'),
                  controller: _keyController,
                  obscureText: _obscureKey,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.aiSettingsApiKeyLabel,
                    hintText: 'sk-...',
                    helperText: widget.saved.hasApiKey
                        ? l10n.aiSettingsApiKeySavedHint(
                            widget.saved.maskedApiKey,
                          )
                        : null,
                    suffixIcon: IconButton(
                      tooltip: _obscureKey
                          ? l10n.aiSettingsShowKey
                          : l10n.aiSettingsHideKey,
                      icon: Icon(
                        _obscureKey ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  key: const ValueKey('aiSettingsBaseUrlField'),
                  controller: _baseUrlController,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.aiSettingsBaseUrlLabel,
                    helperText: l10n.aiSettingsBaseUrlHelper,
                    helperMaxLines: 2,
                    errorText: _baseUrlErrorText(l10n),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  key: const ValueKey('aiSettingsModelField'),
                  controller: _modelController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.aiSettingsModelLabel,
                    hintText: defaultAiModel,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _testing || !hasKey || !urlValid
                  ? null
                  : _testConnection,
              icon: _testing
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(l10n.aiSettingsTestConnection),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saving || !_hasChanges || !urlValid ? null : _save,
              child: Text(l10n.aiSettingsSave),
            ),
          ],
        ),
        if (!hasKey) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            l10n.aiSettingsKeyRequired,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (_testResult case final result?) ...[
          const SizedBox(height: AppSpacing.m),
          _TestResultLine(result: result),
        ],
        if (widget.saved.hasApiKey) ...[
          const SizedBox(height: AppSpacing.l),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: _confirmRemoveKey,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.aiSettingsRemoveKey),
            ),
          ),
        ],
      ],
    );
  }
}

/// 连接测试结果行。
class _TestResultLine extends StatelessWidget {
  const _TestResultLine({required this.result});

  final AiConnectionResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final (ok, text) = switch (result) {
      AiConnectionOk(:final modelCount) => (
        true,
        modelCount == null
            ? l10n.aiSettingsTestOkUnknown
            : l10n.aiSettingsTestOk(modelCount),
      ),
      AiConnectionUnauthorized(:final statusCode) => (
        false,
        l10n.aiSettingsTestUnauthorized(statusCode),
      ),
      AiConnectionHttpError(:final statusCode) => (
        false,
        l10n.aiSettingsTestHttpError(statusCode),
      ),
      AiConnectionNetworkError(:final message) => (
        false,
        l10n.aiSettingsTestNetworkError(message),
      ),
    };
    final color = ok ? colors.primary : colors.error;
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.error_outline, color: color),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(text, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}

/// 读取失败提示横幅。
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}
