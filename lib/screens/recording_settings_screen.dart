/// 录音设置页（self-host 新增，仅 Android 入口）。
///
/// 音量档（增益）+ 音质档（采样率）+ 试录 5 秒。设置对下一次录音生效。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../l10n/app_localizations.dart';
import '../models/recording_settings.dart';
import '../providers/recording_settings_provider.dart';
import '../services/app_logger.dart';
import '../services/recording_trial.dart';
import '../services/speech_practice_platform.dart';
import '../theme/app_theme.dart';

/// 音量档显示名
String recordingGainLabel(AppLocalizations l10n, RecordingGainLevel level) =>
    switch (level) {
      RecordingGainLevel.low => l10n.recordingGainLow,
      RecordingGainLevel.standard => l10n.recordingGainStandard,
      RecordingGainLevel.loud => l10n.recordingGainLoud,
      RecordingGainLevel.extraLoud => l10n.recordingGainExtraLoud,
    };

/// 音质档显示名
String recordingQualityLabel(AppLocalizations l10n, RecordingQuality q) =>
    switch (q) {
      RecordingQuality.standard => l10n.recordingQualityStandard,
      RecordingQuality.good => l10n.recordingQualityGood,
      RecordingQuality.high => l10n.recordingQualityHigh,
    };

String _gainDesc(AppLocalizations l10n, RecordingGainLevel level) =>
    switch (level) {
      RecordingGainLevel.low => l10n.recordingGainLowDesc,
      RecordingGainLevel.standard => l10n.recordingGainStandardDesc,
      RecordingGainLevel.loud => l10n.recordingGainLoudDesc,
      RecordingGainLevel.extraLoud => l10n.recordingGainExtraLoudDesc,
    };

String _qualityDesc(AppLocalizations l10n, RecordingQuality q) => switch (q) {
  RecordingQuality.standard => l10n.recordingQualityStandardDesc,
  RecordingQuality.good => l10n.recordingQualityGoodDesc,
  RecordingQuality.high => l10n.recordingQualityHighDesc,
};

/// 录音设置页
class RecordingSettingsScreen extends ConsumerStatefulWidget {
  const RecordingSettingsScreen({super.key, this.trialBuilder});

  /// 测试注入：替换试录编排器（默认用平台录音 + just_audio 回放）
  final RecordingTrial Function()? trialBuilder;

  @override
  ConsumerState<RecordingSettingsScreen> createState() =>
      _RecordingSettingsScreenState();
}

class _RecordingSettingsScreenState
    extends ConsumerState<RecordingSettingsScreen> {
  late final RecordingTrial _trial =
      widget.trialBuilder?.call() ?? _defaultTrial();

  /// 试录只需纯录音，直接用平台后端（不经离线 ASR）。
  /// 平台单例的设置来源平时由 speechPracticeBackendProvider 注入，
  /// 本页可能先于该 provider 构建，故在此显式注入，保证试录用的是当前设置。
  RecordingTrial _defaultTrial() {
    final platform = SpeechPracticePlatform.instance
      ..recordingSettings = () => ref.read(recordingSettingsNotifierProvider);
    return RecordingTrial(backend: platform, play: _playFile);
  }

  @override
  void dispose() {
    _trial.dispose();
    super.dispose();
  }

  /// 用临时播放器回放试录文件，播完即释放（谁创建谁销毁）。
  static Future<void> _playFile(String path) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(path);
      await player.play();
      await player.playerStateStream
          .firstWhere((s) => s.processingState == ProcessingState.completed)
          .timeout(const Duration(seconds: 15));
    } finally {
      await player.dispose();
    }
  }

  Future<void> _runTrial(AppLocalizations l10n) async {
    final result = await _trial.run();
    AppLogger.log('RecordingSettings', 'trial result=${result.name}');
    if (!mounted) return;
    final message = switch (result) {
      RecordingTrialResult.noPermission => l10n.recordingTrialNoPermission,
      RecordingTrialResult.failed => l10n.recordingTrialFailed,
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(recordingSettingsNotifierProvider);
    final notifier = ref.read(recordingSettingsNotifierProvider.notifier);
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordingSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _SectionLabel(text: l10n.recordingVolume),
          Card(
            child: RadioGroup<RecordingGainLevel>(
              groupValue: settings.gainLevel,
              onChanged: (v) {
                if (v != null) notifier.setGainLevel(v);
              },
              child: Column(
                children: [
                  for (final level in RecordingGainLevel.values)
                    RadioListTile<RecordingGainLevel>(
                      value: level,
                      title: Text(recordingGainLabel(l10n, level)),
                      subtitle: Text(_gainDesc(l10n, level), style: hintStyle),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.xs,
              AppSpacing.m,
              0,
            ),
            child: Text(l10n.recordingVolumeHint, style: hintStyle),
          ),
          const SizedBox(height: AppSpacing.m),
          _SectionLabel(text: l10n.recordingQuality),
          Card(
            child: RadioGroup<RecordingQuality>(
              groupValue: settings.quality,
              onChanged: (v) {
                if (v != null) notifier.setQuality(v);
              },
              child: Column(
                children: [
                  for (final q in RecordingQuality.values)
                    RadioListTile<RecordingQuality>(
                      value: q,
                      title: Text(recordingQualityLabel(l10n, q)),
                      subtitle: Text(_qualityDesc(l10n, q), style: hintStyle),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          ValueListenableBuilder<RecordingTrialState>(
            valueListenable: _trial.state,
            builder: (context, trial, _) {
              final label = switch (trial.phase) {
                RecordingTrialPhase.idle => l10n.recordingTrialButton,
                RecordingTrialPhase.recording => l10n.recordingTrialRecording(
                  trial.secondsLeft,
                ),
                RecordingTrialPhase.playing => l10n.recordingTrialPlaying,
              };
              final idle = trial.phase == RecordingTrialPhase.idle;
              return OutlinedButton.icon(
                onPressed: idle ? () => _runTrial(l10n) : null,
                icon: Icon(
                  trial.phase == RecordingTrialPhase.playing
                      ? Icons.volume_up_outlined
                      : Icons.mic_none_outlined,
                ),
                label: Text(label),
              );
            },
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            l10n.recordingSettingsFootnote,
            style: hintStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
