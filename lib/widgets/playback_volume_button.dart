import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/playback_volume_settings.dart';

/// Nút âm lượng trên AppBar của trình phát: mở bảng "Âm lượng phát"; icon tô sáng khi khác mặc định.
class PlaybackVolumeButton extends StatelessWidget {
  const PlaybackVolumeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlaybackVolume>(
      valueListenable: PlaybackVolumeSettings.notifier,
      builder: (context, volume, _) => IconButton(
        key: const ValueKey('playback-volume-button'),
        tooltip: AppLocalizations.of(context)!.playbackVolume,
        icon: Icon(
          Icons.speaker_outlined,
          color: volume.isCustom ? Theme.of(context).colorScheme.primary : null,
        ),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => const PlaybackVolumeSheet(),
        ),
      ),
    );
  }
}

/// Bảng "Âm lượng phát": thanh trượt 50–200% + công tắc chuẩn hoá + đặt lại. Kéo là áp ngay.
class PlaybackVolumeSheet extends StatelessWidget {
  const PlaybackVolumeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ValueListenableBuilder<PlaybackVolume>(
      valueListenable: PlaybackVolumeSettings.notifier,
      builder: (context, volume, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.playbackVolume, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.volume_down_outlined),
                  Expanded(
                    child: Slider(
                      key: const ValueKey('playback-volume-slider'),
                      min: PlaybackVolume.minPercent.toDouble(),
                      max: PlaybackVolume.maxPercent.toDouble(),
                      divisions:
                          (PlaybackVolume.maxPercent -
                              PlaybackVolume.minPercent) ~/
                          10,
                      value: volume.percent.toDouble(),
                      label: '${volume.percent}%',
                      onChanged: (v) => PlaybackVolumeSettings.update(
                        volume.copyWith(percent: v.round()),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${volume.percent}%',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              if (volume.percent > 100)
                Text(
                  l10n.playbackVolumeBoostHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              SwitchListTile(
                key: const ValueKey('playback-volume-normalize'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.playbackVolumeNormalize),
                subtitle: Text(l10n.playbackVolumeNormalizeHint),
                value: volume.normalize,
                onChanged: (v) => PlaybackVolumeSettings.update(
                  volume.copyWith(normalize: v),
                ),
              ),
              TextButton(
                onPressed: volume.isCustom
                    ? () =>
                          PlaybackVolumeSettings.update(const PlaybackVolume())
                    : null,
                child: Text(l10n.playbackVolumeReset),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
