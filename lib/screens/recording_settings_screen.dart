/// 录音设置页（self-host 新增，仅 Android 入口）。
///
/// 录音来源 + 音量档（增益）+ 音质档（采样率）+ 试录 5 秒。设置对下一次录音生效。
library;

import 'dart:async';

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

/// 耳机类型显示名
String _headsetLabel(AppLocalizations l10n, RecordingHeadset headset) =>
    switch (headset.type) {
      RecordingHeadsetType.wired => l10n.recordingHeadsetWired,
      RecordingHeadsetType.usb => l10n.recordingHeadsetUsb,
      RecordingHeadsetType.bluetooth =>
        headset.name.isEmpty
            ? l10n.recordingHeadsetBluetooth
            : '${l10n.recordingHeadsetBluetooth} · ${headset.name}',
    };

/// 录音设置页
class RecordingSettingsScreen extends ConsumerStatefulWidget {
  const RecordingSettingsScreen({
    super.key,
    this.trialBuilder,
    this.headsetProbe,
  });

  /// 测试注入：替换试录编排器（默认用平台录音 + just_audio 回放）
  final RecordingTrial Function()? trialBuilder;

  /// 测试注入：查询耳机麦克风（默认走平台 `listInputDevices`）
  final Future<RecordingHeadset?> Function()? headsetProbe;

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

  /// 当前可用的耳机麦克风；null 表示只有手机麦克风
  RecordingHeadset? _headset;

  /// 插拔耳机没有回调，页面打开期间定时刷新
  Timer? _headsetTimer;

  @override
  void initState() {
    super.initState();
    _refreshHeadset();
    _headsetTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _refreshHeadset(),
    );
  }

  Future<void> _refreshHeadset() async {
    final probe =
        widget.headsetProbe ?? SpeechPracticePlatform.instance.getHeadsetInput;
    final headset = await probe();
    if (!mounted || headset == _headset) return;
    setState(() => _headset = headset);
  }

  @override
  void dispose() {
    _headsetTimer?.cancel();
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
          _SectionLabel(text: l10n.recordingSource),
          ..._buildSource(l10n, settings, notifier, hintStyle),
          const SizedBox(height: AppSpacing.m),
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

extension on _RecordingSettingsScreenState {
  /// 录音来源区块：无耳机时只显示手机麦克风 + 提示
  List<Widget> _buildSource(
    AppLocalizations l10n,
    RecordingSettings settings,
    RecordingSettingsNotifier notifier,
    TextStyle? hintStyle,
  ) {
    final headset = _headset;
    Widget hint(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.xs,
        AppSpacing.m,
        0,
      ),
      child: Text(text, style: hintStyle),
    );

    if (headset == null) {
      return [
        Card(
          child: ListTile(
            leading: const Icon(Icons.radio_button_checked),
            title: Text(l10n.recordingSourceBuiltIn),
            subtitle: Text(l10n.recordingSourceInUse, style: hintStyle),
          ),
        ),
        hint(
          settings.source == RecordingSource.headset
              ? l10n.recordingSourceHeadsetMissingHint
              : l10n.recordingSourceNoHeadsetHint,
        ),
      ];
    }

    final theme = Theme.of(context);
    return [
      Card(
        child: RadioGroup<RecordingSource>(
          groupValue: settings.source,
          onChanged: (v) {
            if (v != null) notifier.setSource(v);
          },
          child: Column(
            children: [
              RadioListTile<RecordingSource>(
                value: RecordingSource.auto,
                title: Text(l10n.recordingSourceAuto),
                subtitle: Text(l10n.recordingSourceAutoDesc, style: hintStyle),
              ),
              RadioListTile<RecordingSource>(
                value: RecordingSource.builtIn,
                title: Text(l10n.recordingSourceBuiltIn),
                subtitle: Text(
                  l10n.recordingSourceBuiltInDesc,
                  style: hintStyle,
                ),
              ),
              RadioListTile<RecordingSource>(
                value: RecordingSource.headset,
                title: Text(l10n.recordingSourceHeadset),
                subtitle: Text(_headsetLabel(l10n, headset), style: hintStyle),
              ),
            ],
          ),
        ),
      ),
      if (settings.source == RecordingSource.headset &&
          headset.type == RecordingHeadsetType.bluetooth)
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.s),
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            l10n.recordingSourceBluetoothWarning,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ),
    ];
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
