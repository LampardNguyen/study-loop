/// 导入面板「对话转语音」步骤：输入对话 → 选择声音 → 逐句 TTS 生成课程。
///
/// 设计稿见 `docs/selfhost/design-dialogue-tts.md`。
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:universal_io/io.dart';

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

/// OpenAI 可选声音 → 是否男声（fable 偏中性，归入男声）。男声在前。
const dialogueVoiceOptions = {
  'ash': true,
  'ballad': true,
  'echo': true,
  'fable': true,
  'onyx': true,
  'alloy': false,
  'coral': false,
  'nova': false,
  'sage': false,
  'shimmer': false,
};

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

  AudioPlayer? _player;
  CancelToken? _previewCancel;
  bool _previewLoading = false;
  bool _previewPlaying = false;
  File? _previewFile;
  String? _previewKey;

  @override
  void dispose() {
    _cancelToken?.cancel();
    _previewCancel?.cancel();
    _player?.dispose();
    final file = _previewFile;
    if (file != null) unawaited(file.delete().catchError((_) => file));
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

  /// 试听缓存键：前几句内容 + 声音 + 模型，不变则直接重播。
  String get _currentPreviewKey {
    final lines = _lines.take(dialoguePreviewLines);
    return [
      _quality.model,
      for (final l in lines) '${_voices[l.speaker]}|${l.speaker}|${l.text}',
    ].join('\n');
  }

  Future<void> _togglePreview() async {
    if (_previewPlaying) {
      await _player?.stop();
      return;
    }
    final key = _currentPreviewKey;
    var file = _previewFile;
    if (file == null || _previewKey != key) {
      await ref.read(aiSettingsProvider.future);
      if (!mounted) return;
      final ok = await ensureAiConfiguredForAction(context: context, ref: ref);
      if (!ok || !mounted) return;
      final config = await ref.read(aiSettingsProvider.future);
      if (!mounted) return;
      _previewCancel = CancelToken();
      setState(() => _previewLoading = true);
      try {
        file = await ref
            .read(dialogueLessonServiceProvider)
            .preview(
              config: config,
              lines: _lines,
              voices: Map.of(_voices),
              model: _quality.model,
              cancelToken: _previewCancel,
            );
        _previewFile = file;
        _previewKey = key;
      } catch (e) {
        if (!mounted) return;
        setState(() => _previewLoading = false);
        final canceled = e is DioException && e.type == DioExceptionType.cancel;
        if (!canceled) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_errorText(e))));
        }
        return;
      }
      if (!mounted) return;
    }
    final player = _player ??= _createPlayer();
    setState(() {
      _previewLoading = false;
      _previewPlaying = true;
    });
    await player.setFilePath(file.path);
    unawaited(player.play());
  }

  /// 按播放器真实状态刷新「停止」按钮：播完或停止即恢复为试听。
  AudioPlayer _createPlayer() {
    final player = AudioPlayer();
    player.playerStateStream.listen((s) {
      final playing =
          s.playing &&
          s.processingState != ProcessingState.completed &&
          s.processingState != ProcessingState.idle;
      if (mounted && _previewPlaying != playing && !_previewLoading) {
        setState(() => _previewPlaying = playing);
      }
    });
    return player;
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
    final canCreate =
        _lines.isNotEmpty &&
        tooLong == null &&
        !_busy &&
        !_previewLoading &&
        !_previewPlaying;

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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.white
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                for (final (i, speaker) in _speakers.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  _SpeakerVoiceRow(
                    speaker: speaker,
                    voice: _voices[speaker]!,
                    onChanged: (v) => setState(() => _voices[speaker] = v),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.dialogueTtsQuality, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<_Quality>(
              key: const ValueKey('dialogue-tts-quality'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _Quality.natural,
                  label: Text(l10n.dialogueTtsQualityNatural),
                ),
                ButtonSegment(
                  value: _Quality.standard,
                  label: Text(l10n.dialogueTtsQualityStandard),
                ),
                ButtonSegment(
                  value: _Quality.high,
                  label: Text(l10n.dialogueTtsQualityHigh),
                ),
              ],
              selected: {_quality},
              onSelectionChanged: (v) => setState(() => _quality = v.first),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_quality.model} · ${l10n.dialogueTtsEstimate(
              _costLabel(chars * _quality.usdPerMillionChars / 1e6),
              // 约 900 字符/分钟朗读。
              (chars / 900).ceil(),
            )}',
            style: small,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('dialogue-tts-preview'),
              onPressed: _previewLoading || tooLong != null
                  ? null
                  : _togglePreview,
              icon: _previewLoading
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_previewPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(
                _previewLoading
                    ? l10n.dialogueTtsPreviewing
                    : _previewPlaying
                    ? l10n.dialogueTtsPreviewStop
                    : l10n.dialogueTtsPreview,
              ),
            ),
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

/// 说话人一行：首字母头像（按声音性别着色）+ 名字 + 声音选择 chip。
class _SpeakerVoiceRow extends StatelessWidget {
  const _SpeakerVoiceRow({
    required this.speaker,
    required this.voice,
    required this.onChanged,
  });

  final String speaker;
  final String voice;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final male = dialogueVoiceOptions[voice] ?? true;
    final bg = male ? scheme.primaryContainer : scheme.tertiaryContainer;
    final fg = male ? scheme.onPrimaryContainer : scheme.onTertiaryContainer;
    String genderOf(bool m) =>
        m ? l10n.dialogueTtsVoiceMale : l10n.dialogueTtsVoiceFemale;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: bg,
            child: Text(
              speaker.characters.first.toUpperCase(),
              style: TextStyle(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              speaker,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          PopupMenuButton<String>(
            initialValue: voice,
            onSelected: onChanged,
            itemBuilder: (_) => [
              for (final e in dialogueVoiceOptions.entries)
                PopupMenuItem(
                  value: e.key,
                  child: Text('${e.key} · ${genderOf(e.value)}'),
                ),
            ],
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(voice),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      genderOf(male),
                      style: TextStyle(color: fg, fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 对话课程服务（测试可 override）。
final dialogueLessonServiceProvider = Provider<DialogueLessonService>(
  (ref) => DialogueLessonService(),
);
