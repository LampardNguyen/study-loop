import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_logger.dart';

/// Cài đặt âm lượng phát (toàn cục): phần trăm âm lượng (50–200) + có chuẩn hoá độ lớn hay không.
@immutable
class PlaybackVolume {
  const PlaybackVolume({this.percent = 100, this.normalize = false});

  static const int minPercent = 50;
  static const int maxPercent = 200;

  final int percent;
  final bool normalize;

  /// Khác mặc định (100%, không chuẩn hoá) → nút được tô sáng.
  bool get isCustom => percent != 100 || normalize;

  /// volume cho just_audio (0–1).
  double get justAudioVolume => math.min(percent, 100) / 100;

  /// Độ khuếch đại (dB) cho Android LoudnessEnhancer của just_audio.
  /// Phần >100% đổi thành độ khuếch đại; chuẩn hoá cộng thêm +6 dB (LoudnessEnhancer có sẵn limiter, khó bị rè).
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

/// Âm lượng phát toàn cục: mỗi player lắng nghe [notifier] để áp ngay, khi đổi thì lưu vào SharedPreferences.
class PlaybackVolumeSettings {
  PlaybackVolumeSettings._();

  static const _percentKey = 'playback_volume_percent';
  static const _normalizeKey = 'playback_volume_normalize';

  static final ValueNotifier<PlaybackVolume> notifier = ValueNotifier(
    const PlaybackVolume(),
  );

  static SharedPreferences? _prefs;

  static PlaybackVolume get value => notifier.value;

  /// Đọc cài đặt đã lưu khi khởi động app.
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

/// Tạo player just_audio kèm LoudnessEnhancer và gắn với âm lượng phát toàn cục.
/// Phải gọi [VolumeAwarePlayer.unbind] khi giải phóng player.
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
