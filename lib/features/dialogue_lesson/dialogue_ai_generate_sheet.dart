/// Bảng "Tạo hội thoại bằng AI" (T15.8). Thiết kế: `docs/selfhost/design-dialogue-ai-generate.md`.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/common/form_input_style.dart';
import '../ai_settings/ai_key_required_dialog.dart';
import '../ai_settings/providers/ai_settings_provider.dart';
import 'dialogue_ai_generator.dart';

/// Cách chọn chủ đề.
enum DialogueTopicMode { suggested, custom, random }

/// Kết quả trả về cho panel: hội thoại + trình độ đã chọn (để gợi ý cấp độ giọng đọc).
class DialogueAiSheetResult {
  const DialogueAiSheetResult(this.dialogue, this.level);

  final GeneratedDialogue dialogue;
  final DialogueCefrLevel level;
}

/// Chủ đề gợi ý sẵn (nhãn theo ngôn ngữ giao diện).
List<String> dialogueTopicSuggestions(AppLocalizations l10n) => [
  l10n.dialogueAiTopicRestaurant,
  l10n.dialogueAiTopicDirections,
  l10n.dialogueAiTopicHotel,
  l10n.dialogueAiTopicInterview,
  l10n.dialogueAiTopicDoctor,
  l10n.dialogueAiTopicShopping,
  l10n.dialogueAiTopicAirport,
  l10n.dialogueAiTopicMeeting,
  l10n.dialogueAiTopicNewFriend,
  l10n.dialogueAiTopicWeekend,
  l10n.dialogueAiTopicRenting,
  l10n.dialogueAiTopicCustomerService,
];

Future<DialogueAiSheetResult?> showDialogueAiGenerateSheet(
  BuildContext context,
) => showModalBottomSheet<DialogueAiSheetResult>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => const DialogueAiGenerateSheet(),
);

class DialogueAiGenerateSheet extends ConsumerStatefulWidget {
  const DialogueAiGenerateSheet({super.key});

  @override
  ConsumerState<DialogueAiGenerateSheet> createState() =>
      _DialogueAiGenerateSheetState();
}

class _DialogueAiGenerateSheetState
    extends ConsumerState<DialogueAiGenerateSheet> {
  static const _prefsMode = 'dialogue_ai_topic_mode';
  static const _prefsTopic = 'dialogue_ai_topic_index';
  static const _prefsLanguage = 'dialogue_ai_language';
  static const _prefsLevel = 'dialogue_ai_level';
  static const _prefsSpeakers = 'dialogue_ai_speakers';
  static const _prefsLines = 'dialogue_ai_lines';

  final _topicController = TextEditingController();
  DialogueTopicMode _mode = DialogueTopicMode.suggested;
  int _topicIndex = 0;
  String _language = 'en';
  DialogueCefrLevel _level = DialogueCefrLevel.b1;
  int _speakers = 2;
  int _lines = 30;
  CancelToken? _cancelToken;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _mode =
          DialogueTopicMode.values.asNameMap()[prefs.getString(_prefsMode)] ??
          _mode;
      _topicIndex = (prefs.getInt(_prefsTopic) ?? 0).clamp(0, 11);
      final lang = prefs.getString(_prefsLanguage);
      if (dialogueAiLanguages.containsKey(lang)) _language = lang!;
      _level =
          DialogueCefrLevel.values.asNameMap()[prefs.getString(_prefsLevel)] ??
          _level;
      final speakers = prefs.getInt(_prefsSpeakers);
      if (speakers == 2 || speakers == 3) _speakers = speakers!;
      final lines = prefs.getInt(_prefsLines);
      if (dialogueAiLengths.contains(lines)) _lines = lines!;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsMode, _mode.name);
    await prefs.setInt(_prefsTopic, _topicIndex);
    await prefs.setString(_prefsLanguage, _language);
    await prefs.setString(_prefsLevel, _level.name);
    await prefs.setInt(_prefsSpeakers, _speakers);
    await prefs.setInt(_prefsLines, _lines);
  }

  bool get _canGenerate =>
      !_loading &&
      (_mode != DialogueTopicMode.custom ||
          _topicController.text.trim().isNotEmpty);

  Future<void> _generate() async {
    await ref.read(aiSettingsProvider.future);
    if (!mounted) return;
    final ok = await ensureAiConfiguredForAction(context: context, ref: ref);
    if (!ok || !mounted) return;
    final config = await ref.read(aiSettingsProvider.future);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final topic = switch (_mode) {
      DialogueTopicMode.suggested => dialogueTopicSuggestions(
        l10n,
      )[_topicIndex],
      DialogueTopicMode.custom => _topicController.text.trim(),
      DialogueTopicMode.random => null,
    };
    _cancelToken = CancelToken();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dialogue = await ref
          .read(dialogueAiGeneratorProvider)
          .generate(
            config,
            topic: topic,
            languageCode: _language,
            level: _level,
            speakers: _speakers,
            lines: _lines,
            cancelToken: _cancelToken,
          );
      await _savePrefs();
      if (!mounted) return;
      Navigator.of(context).pop(DialogueAiSheetResult(dialogue, _level));
    } catch (e) {
      if (!mounted) return;
      final canceled = e is DioException && e.type == DioExceptionType.cancel;
      setState(() {
        _loading = false;
        _error = canceled ? null : _errorText(l10n, e);
      });
    }
  }

  String _errorText(AppLocalizations l10n, Object e) {
    if (e is DialogueGenerateFormatException) return l10n.dialogueAiErrorFormat;
    if (e is DioException) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) return l10n.dialogueTtsErrorAuth;
      if (status == 429) return l10n.dialogueTtsErrorRateLimit;
      if (e.response == null) return l10n.dialogueTtsErrorNetwork;
      return l10n.dialogueTtsErrorGeneric('HTTP $status');
    }
    return l10n.dialogueTtsErrorGeneric(e.toString());
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _choices<T>(List<(T, String)> items, T selected, ValueChanged<T> on) =>
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final (value, label) in items)
            ChoiceChip(
              label: Text(label),
              selected: value == selected,
              onSelected: _loading ? null : (_) => setState(() => on(value)),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final topics = dialogueTopicSuggestions(l10n);
    final lengthLabels = [
      l10n.dialogueAiLengthShort,
      l10n.dialogueAiLengthMedium,
      l10n.dialogueAiLengthLong,
      l10n.dialogueAiLengthVeryLong,
    ];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dialogueAiTitle, style: theme.textTheme.titleMedium),
              _label(l10n.dialogueAiTopic),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<DialogueTopicMode>(
                  key: const ValueKey('dialogue-ai-topic-mode'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: DialogueTopicMode.suggested,
                      label: Text(l10n.dialogueAiTopicSuggested),
                    ),
                    ButtonSegment(
                      value: DialogueTopicMode.custom,
                      label: Text(l10n.dialogueAiTopicCustom),
                    ),
                    ButtonSegment(
                      value: DialogueTopicMode.random,
                      icon: const Icon(Icons.casino_outlined, size: 18),
                      label: Text(l10n.dialogueAiTopicRandom),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: _loading
                      ? null
                      : (v) => setState(() => _mode = v.first),
                ),
              ),
              const SizedBox(height: 8),
              switch (_mode) {
                DialogueTopicMode.suggested => DropdownButtonFormField<int>(
                  key: const ValueKey('dialogue-ai-topic-select'),
                  initialValue: _topicIndex,
                  isExpanded: true,
                  decoration: compactFormInputDecoration(context),
                  items: [
                    for (final (i, t) in topics.indexed)
                      DropdownMenuItem(value: i, child: Text(t)),
                  ],
                  onChanged: _loading
                      ? null
                      : (v) => setState(() => _topicIndex = v ?? 0),
                ),
                DialogueTopicMode.custom => TextField(
                  key: const ValueKey('dialogue-ai-topic-input'),
                  controller: _topicController,
                  enabled: !_loading,
                  style: compactFormTextStyle(context),
                  decoration: compactFormInputDecoration(
                    context,
                    hintText: l10n.dialogueAiTopicCustomHint,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                DialogueTopicMode.random => Text(
                  l10n.dialogueAiTopicRandomHint,
                  style: theme.textTheme.bodySmall,
                ),
              },
              _label(l10n.dialogueAiLanguage),
              DropdownButtonFormField<String>(
                initialValue: _language,
                isExpanded: true,
                decoration: compactFormInputDecoration(context),
                items: [
                  for (final MapEntry(:key, :value)
                      in dialogueAiLanguages.entries)
                    DropdownMenuItem(value: key, child: Text(value)),
                ],
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _language = v ?? 'en'),
              ),
              _label(l10n.dialogueAiLevel),
              _choices(
                [for (final l in DialogueCefrLevel.values) (l, l.label)],
                _level,
                (v) => _level = v,
              ),
              _label(l10n.dialogueAiSpeakers),
              _choices([(2, '2'), (3, '3')], _speakers, (v) => _speakers = v),
              _label(l10n.dialogueAiLength),
              _choices(
                [
                  for (final (i, n) in dialogueAiLengths.indexed)
                    (n, '${lengthLabels[i]} ~$n'),
                ],
                _lines,
                (v) => _lines = v,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_loading) {
                        _cancelToken?.cancel();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const ValueKey('dialogue-ai-generate'),
                    onPressed: _canGenerate ? _generate : null,
                    icon: _loading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      _loading
                          ? l10n.dialogueAiGenerating
                          : l10n.dialogueAiCreate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
