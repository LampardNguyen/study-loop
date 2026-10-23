/// 录音设置模型（self-host 新增）：音量档（增益）+ 采样率。
///
/// 仅 Android 原生 `WavRecorder` 生效；其它平台忽略这些参数。
library;

/// 录音音量档：映射为写入 WAV 前的增益倍数。
enum RecordingGainLevel {
  /// 小（×1.5）：离麦克风近 / 环境嘈杂时
  low(1.5),

  /// 标准（×2.2）：与原版固定增益一致（默认）
  standard(2.2),

  /// 大（×3.5）
  loud(3.5),

  /// 很大（×5）
  extraLoud(5.0);

  const RecordingGainLevel(this.gain);

  /// 增益倍数
  final double gain;
}

/// 录音音质档：映射为采样率。
enum RecordingQuality {
  /// 标准 16 kHz（默认，与原版一致）
  standard(16000),

  /// 较好 24 kHz（设备不支持时原生侧回退 16 kHz）
  good(24000),

  /// 高 44.1 kHz
  high(44100);

  const RecordingQuality(this.sampleRate);

  /// 采样率（Hz）
  final int sampleRate;
}

/// 录音设置（不可变）。
class RecordingSettings {
  const RecordingSettings({
    this.gainLevel = RecordingGainLevel.standard,
    this.quality = RecordingQuality.standard,
  });

  final RecordingGainLevel gainLevel;
  final RecordingQuality quality;

  RecordingSettings copyWith({
    RecordingGainLevel? gainLevel,
    RecordingQuality? quality,
  }) => RecordingSettings(
    gainLevel: gainLevel ?? this.gainLevel,
    quality: quality ?? this.quality,
  );

  /// 传给原生 `startSession` 的参数
  Map<String, Object> toPlatformArgs() => {
    'gain': gainLevel.gain,
    'sampleRate': quality.sampleRate,
  };

  @override
  bool operator ==(Object other) =>
      other is RecordingSettings &&
      other.gainLevel == gainLevel &&
      other.quality == quality;

  @override
  int get hashCode => Object.hash(gainLevel, quality);

  @override
  String toString() =>
      'RecordingSettings(gain=${gainLevel.name}, quality=${quality.name})';
}
