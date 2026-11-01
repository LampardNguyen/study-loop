import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_logger.dart';

/// 播放音量设置（全局）：音量百分比（50–200）+ 是否响度标准化。
@immutable
class PlaybackVolume {
  const PlaybackVolume({this.percent = 100, this.normalize = false});

  static const int minPercent = 50;
  static const int maxPercent = 200;

  final int percent;
  final bool normalize;

  /// 与默认（100%、未标准化）不同 → 按钮高亮。
  bool get isCustom => percent != 100 || normalize;

  /// just_audio 的 volume（0–1）。
  double get justAudioVolume => math.min(percent, 100) / 100;

  /// just_audio 的 Android LoudnessEnhancer 增益（dB）。
  /// >100% 的部分换算成增益；标准化再额外 +6 dB（LoudnessEnhancer 自带限幅，不易破音）。
  double get loudnessGainDb {
    var db = percent > 100 ? 20 * math.log(percent / 100) / math.ln10 : 0.0;
    if (normalize) db += 6;
    return db;
  }

  PlaybackVolume copyWith({int? percent, bool? normalize}) => PlaybackVolume(
    percent: percent ?? this.percent,
    normalize: normalize ?? this.normalize,
  );

  @override
  bool operator ==(Object other) =>
      other is PlaybackVolume &&
      other.percent == percent &&
      other.normalize == normalize;

  @override
  int get hashCode => Object.hash(percent, normalize);
}

/// 全局播放音量：各播放器实例监听 [notifier] 即时生效，修改时写入 SharedPreferences。
class PlaybackVolumeSettings {
  PlaybackVolumeSettings._();

  static const _percentKey = 'playback_volume_percent';
  static const _normalizeKey = 'playback_volume_normalize';

  static final ValueNotifier<PlaybackVolume> notifier = ValueNotifier(
    const PlaybackVolume(),
  );

  static SharedPreferences? _prefs;

  static PlaybackVolume get value => notifier.value;

  /// 启动时读取已保存的设置。
  static void load(SharedPreferences prefs) {
    _prefs = prefs;
    notifier.value = PlaybackVolume(
      percent: (prefs.getInt(_percentKey) ?? 100).clamp(
        PlaybackVolume.minPercent,
        PlaybackVolume.maxPercent,
      ),
      normalize: prefs.getBool(_normalizeKey) ?? false,
    );
  }

  static Future<void> update(PlaybackVolume volume) async {
    notifier.value = volume;
    await _prefs?.setInt(_percentKey, volume.percent);
    await _prefs?.setBool(_normalizeKey, volume.normalize);
  }
}

/// 创建带 LoudnessEnhancer 的 just_audio 播放器，并绑定全局播放音量。
/// 返回的 [VolumeAwarePlayer.unbind] 需在播放器释放时调用。
class VolumeAwarePlayer {
  VolumeAwarePlayer._(this.player, this._enhancer) {
    PlaybackVolumeSettings.notifier.addListener(_apply);
    _apply();
  }

  factory VolumeAwarePlayer.create() {
    final enhancer = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? ja.AndroidLoudnessEnhancer()
        : null;
    final player = ja.AudioPlayer(
      audioPipeline: ja.AudioPipeline(androidAudioEffects: [?enhancer]),
    );
    return VolumeAwarePlayer._(player, enhancer);
  }

  final ja.AudioPlayer player;
  final ja.AndroidLoudnessEnhancer? _enhancer;

  void _apply() {
    final volume = PlaybackVolumeSettings.value;
    unawaited(() async {
      try {
        await player.setVolume(volume.justAudioVolume);
        final enhancer = _enhancer;
        if (enhancer == null) return;
        final gain = volume.loudnessGainDb;
        await enhancer.setTargetGain(gain);
        await enhancer.setEnabled(gain > 0);
      } catch (error) {
        AppLogger.log('PlaybackVolume', 'apply failed: $error');
      }
    }());
  }

  void unbind() => PlaybackVolumeSettings.notifier.removeListener(_apply);
}
