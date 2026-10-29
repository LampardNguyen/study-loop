/// 导入面板「对话转语音」步骤：输入对话 → 选择声音 → 逐句 TTS 生成课程。
///
/// 设计稿见 `docs/selfhost/design-dialogue-tts.md`。
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/audio_item.dart';
import '../../providers/audio_library_provider.dart';
import '../../providers/collection_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/transcript_picker.dart';
import '../../widgets/common/form_input_style.dart';
import '../../widgets/common/secondary_action_button.dart';
import '../ai_settings/ai_key_required_dialog.dart';
import '../ai_settings/providers/ai_settings_provider.dart';
import 'dialogue_lesson_service.dart';
import 'dialogue_parser.dart';

/// OpenAI 可选声音。
const dialogueVoiceOptions = [
  'alloy',
  'ash',
  'ballad',
  'coral',
  'echo',
  'fable',
  'nova',
  'onyx',
  'sage',
  'shimmer',
];

/// 单句最大字符数（OpenAI speech 接口上限 4096）。
const dialogueMaxLineChars = 4000;

enum _Quality {
  natural('gpt-4o-mini-tts', 15),
  standard('tts-1', 15),
  high('tts-1-hd', 30);

  const _Quality(this.model, this.usdPerMillionChars);

  final String model;
  final double usdPerMillionChars;
}

class DialogueTtsPanel extends ConsumerStatefulWidget {
  const DialogueTtsPanel({
    super.key,
    required this.collectionId,
    required this.onBusyChanged,
    required this.onCompleted,
    required this.onBack,
  });

  final String? collectionId;
  final ValueChanged<bool> onBusyChanged;
  final ValueChanged<AudioItem> onCompleted;
  final VoidCallback onBack;

  @override
  ConsumerState<DialogueTtsPanel> createState() => _DialogueTtsPanelState();
}

class _DialogueTtsPanelState extends ConsumerState<DialogueTtsPanel> {
  final _nameController = TextEditingController();
  final _dialogueController = TextEditingController();
  final _voices = <String, String>{};
  _Quality _quality = _Quality.natural;
  List<DialogueLine> _lines = const [];
  CancelToken? _cancelToken;
  bool _busy = false;
  int _done = 0;
  String? _error;

  @override
  void dispose() {
    _cancelToken?.cancel();
    _nameController.dispose();
    _dialogueController.dispose();
    super.dispose();
  }

  List<String> get _speakers => dialogueSpeakers(_lines);

  int? get _tooLongIndex {
    final i = _lines.indexWhere((l) => l.text.length > dialogueMaxLineChars);
    return i < 0 ? null : i + 1;
  }

  void _onDialogueChanged(String text) {
    setState(() {
      _lines = parseDialogue(text);
      final speakers = _speakers;
      for (var i = 0; i < speakers.length; i++) {
        _voices.putIfAbsent(
          speakers[i],
          () => defaultDialogueVoices[i % defaultDialogueVoices.length],
        );
      }
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (!mounted || text.trim().isEmpty) return;
    _dialogueController.text = text;
    _onDialogueChanged(text);
  }

  void _setBusy(bool busy) {
    setState(() => _busy = busy);
    widget.onBusyChanged(busy);
  }

  Future<void> _create() async {
    // 冷启动后 AI 设置异步加载，先等加载完，避免误判为未配置 Key。
    await ref.read(aiSettingsProvider.future);
    if (!mounted) return;
    final ok = await ensureAiConfiguredForAction(context: context, ref: ref);
    if (!ok || !mounted) return;
    final config = await ref.read(aiSettingsProvider.future);
    if (!mounted) return;

    final lines = _lines;
    final typedName = _nameController.text.trim();
    final name = typedName.isNotEmpty
        ? typedName
        : (lines.first.text.length > 40
              ? lines.first.text.substring(0, 40)
              : lines.first.text);
    final collectionId = widget.collectionId;
    _cancelToken = CancelToken();
    _done = 0;
    _error = null;
    _setBusy(true);
    try {
      final item = await ref
          .read(dialogueLessonServiceProvider)
          .createLesson(
            config: config,
            name: name,
            lines: lines,
            voices: Map.of(_voices),
            model: _quality.model,
            audioLibrary: ref.read(audioLibraryProvider.notifier),
            audioLibraryState: ref.read(audioLibraryProvider),
            collectionList: collectionId == null
                ? null
                : ref.read(collectionListProvider.notifier),
            collectionState: collectionId == null
                ? null
                : ref.read(collectionListProvider),
            collectionId: collectionId,
            cancelToken: _cancelToken,
            onProgress: (done, _) {
              if (mounted) setState(() => _done = done);
            },
            attachSubtitle: (item, srt) =>
                importLocalSubtitle(ref, item, text: srt, ext: 'srt'),
          );
      if (!mounted) return;
      // 字幕挂载后库里的条目已更新（含字幕），完成页据此统计「有字幕」数量。
      final updated =
          ref
              .read(audioLibraryProvider)
              .audioItems
              .where((a) => a.id == item.id)
              .firstOrNull ??
          item;
      _setBusy(false);
      widget.onCompleted(updated);
    } catch (e) {
      if (!mounted) return;
      final canceled = e is DioException && e.type == DioExceptionType.cancel;
      setState(() => _error = canceled ? null : _errorText(e));
      _setBusy(false);
    }
  }

  String _errorText(Object e) {
    final l10n = AppLocalizations.of(context)!;
    if (e is DialogueLessonException) {
      return switch (e.failure) {
        DialogueLessonFailure.encode => l10n.dialogueTtsErrorEncode,
        DialogueLessonFailure.duplicate => l10n.dialogueTtsErrorDuplicate,
        DialogueLessonFailure.empty => l10n.dialogueTtsEmptyHint,
      };
    }
    if (e is DioException) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) return l10n.dialogueTtsErrorAuth;
      if (status == 429) return l10n.dialogueTtsErrorRateLimit;
      if (e.response == null) return l10n.dialogueTtsErrorNetwork;
      return l10n.dialogueTtsErrorGeneric('HTTP $status');
    }
    return l10n.dialogueTtsErrorGeneric(e.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final chars = _lines.fold<int>(0, (sum, l) => sum + l.text.length);
    final tooLong = _tooLongIndex;
    final canCreate = _lines.isNotEmpty && tooLong == null && !_busy;

    if (_busy) {
      final total = _lines.length;
      final merging = _done >= total;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: merging || total == 0 ? null : _done / total,
          ),
          const SizedBox(height: 8),
          Text(
            merging
                ? l10n.dialogueTtsMerging
                : l10n.dialogueTtsProgress(_done, total),
            style: small,
          ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _cancelToken?.cancel(),
              child: Text(l10n.cancelImport),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          style: compactFormTextStyle(context),
          decoration: compactFormInputDecoration(
            context,
            labelText: l10n.dialogueTtsNameLabel,
            hintText: l10n.dialogueTtsNameHint,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('dialogue-tts-input'),
          controller: _dialogueController,
          style: compactFormTextStyle(context),
          minLines: 8,
          maxLines: 14,
          keyboardType: TextInputType.multiline,
          decoration: compactFormInputDecoration(
            context,
            labelText: l10n.dialogueTtsDialogueLabel,
            hintText: l10n.dialogueTtsDialogueHint,
            errorText: tooLong == null
                ? null
                : l10n.dialogueTtsLineTooLong(tooLong),
          ),
          onChanged: _onDialogueChanged,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                _lines.isEmpty
                    ? l10n.dialogueTtsEmptyHint
                    : l10n.dialogueTtsStats(
                        _lines.length,
                        _speakers.length,
                        chars,
                      ),
                style: small,
              ),
            ),
            TextButton.icon(
              onPressed: _paste,
              icon: const Icon(Icons.content_paste, size: 18),
              label: Text(l10n.dialogueTtsPaste),
            ),
          ],
        ),
        if (_lines.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(l10n.dialogueTtsVoices, style: theme.textTheme.titleSmall),
          for (final speaker in _speakers)
            _DropdownRow<String>(
              label: speaker,
              value: _voices[speaker]!,
              items: {for (final v in dialogueVoiceOptions) v: v},
              onChanged: (v) => setState(() => _voices[speaker] = v),
            ),
          _DropdownRow<_Quality>(
            label: l10n.dialogueTtsQuality,
            value: _quality,
            items: {
              _Quality.natural:
                  '${l10n.dialogueTtsQualityNatural} (gpt-4o-mini-tts)',
              _Quality.standard: '${l10n.dialogueTtsQualityStandard} (tts-1)',
              _Quality.high: '${l10n.dialogueTtsQualityHigh} (tts-1-hd)',
            },
            onChanged: (v) => setState(() => _quality = v),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.dialogueTtsEstimate(
              _costLabel(chars * _quality.usdPerMillionChars / 1e6),
              // 约 900 字符/分钟朗读。
              (chars / 900).ceil(),
            ),
            style: small,
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        Row(
          children: [
            Expanded(
              child: SecondaryActionButton(
                onPressed: widget.onBack,
                label: l10n.back,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                key: const ValueKey('dialogue-tts-create'),
                onPressed: canCreate ? _create : null,
                child: Text(
                  _error == null
                      ? l10n.dialogueTtsCreate
                      : l10n.dialogueTtsRetry,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 不足 1 美分时按 `$0.01` 显示，避免出现 `$0.00`。
String _costLabel(double usd) =>
    usd < 0.01 ? '\$0.01' : '\$${usd.toStringAsFixed(2)}';

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        DropdownButton<T>(
          value: value,
          isDense: true,
          underline: const SizedBox.shrink(),
          items: [
            for (final e in items.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

/// 对话课程服务（测试可 override）。
final dialogueLessonServiceProvider = Provider<DialogueLessonService>(
  (ref) => DialogueLessonService(),
);
