/// 录音设置 Provider（self-host 新增）
///
/// keepAlive Notifier，`build()` 返回默认值并异步从 SharedPreferences 加载；
/// 通过 [RecordingSettingsNotifier.setGainLevel] / [setQuality] 修改并持久化。
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recording_settings.dart';
import '../services/app_logger.dart';

part 'recording_settings_provider.g.dart';

const _gainKey = 'recording_gain_level';
const _qualityKey = 'recording_quality';
const _logTag = 'RecordingSettings';

/// 录音设置 Notifier
@Riverpod(keepAlive: true)
class RecordingSettingsNotifier extends _$RecordingSettingsNotifier {
  /// 用户在加载完成前已修改过设置时，加载结果不得覆盖用户选择。
  bool _userChanged = false;

  @override
  RecordingSettings build() {
    _load();
    return const RecordingSettings();
  }

  /// 异步加载持久化设置；未知取值回退默认。
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gain = _byName(
        RecordingGainLevel.values,
        prefs.getString(_gainKey),
      );
      final quality = _byName(
        RecordingQuality.values,
        prefs.getString(_qualityKey),
      );
      if (_userChanged) return;
      state = RecordingSettings(
        gainLevel: gain ?? RecordingGainLevel.standard,
        quality: quality ?? RecordingQuality.standard,
      );
      AppLogger.log(_logTag, 'loaded $state');
    } catch (e) {
      AppLogger.log(_logTag, 'load failed error=$e');
    }
  }

  /// 修改音量档并持久化
  Future<void> setGainLevel(RecordingGainLevel level) async {
    _userChanged = true;
    state = state.copyWith(gainLevel: level);
    await _persist(_gainKey, level.name);
  }

  /// 修改音质档并持久化
  Future<void> setQuality(RecordingQuality quality) async {
    _userChanged = true;
    state = state.copyWith(quality: quality);
    await _persist(_qualityKey, quality.name);
  }

  Future<void> _persist(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      AppLogger.log(_logTag, 'saved $state');
    } catch (e) {
      AppLogger.log(_logTag, 'persist failed key=$key error=$e');
    }
  }
}

T? _byName<T extends Enum>(List<T> values, String? name) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
