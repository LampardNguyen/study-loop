/// 录音设置模型（self-host 新增）：音量档（增益）+ 采样率 + 录音来源。
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

/// 录音来源（麦克风选择）。
enum RecordingSource {
  /// 自动：由系统选择（默认，与原版一致）
  auto,

  /// 手机内置麦克风
  builtIn,

  /// 耳机麦克风（有线/USB 优先，其次蓝牙）；不可用时回退内置麦克风
  headset,
}

/// 耳机麦克风类型
enum RecordingHeadsetType { wired, usb, bluetooth }

/// 当前可用的耳机麦克风（原生 `listInputDevices` 返回）。
class RecordingHeadset {
  const RecordingHeadset({required this.type, this.name = ''});

  final RecordingHeadsetType type;

  /// 设备名（可能为空）
  final String name;

  @override
  bool operator ==(Object other) =>
      other is RecordingHeadset && other.type == type && other.name == name;

  @override
  int get hashCode => Object.hash(type, name);
}

/// 录音设置（不可变）。
class RecordingSettings {
  const RecordingSettings({
    this.gainLevel = RecordingGainLevel.standard,
    this.quality = RecordingQuality.standard,
    this.source = RecordingSource.auto,
  });

  final RecordingGainLevel gainLevel;
  final RecordingQuality quality;
  final RecordingSource source;

  RecordingSettings copyWith({
    RecordingGainLevel? gainLevel,
    RecordingQuality? quality,
    RecordingSource? source,
  }) => RecordingSettings(
    gainLevel: gainLevel ?? this.gainLevel,
    quality: quality ?? this.quality,
    source: source ?? this.source,
  );

  /// 传给原生 `startSession` 的参数
  Map<String, Object> toPlatformArgs() => {
    'gain': gainLevel.gain,
    'sampleRate': quality.sampleRate,
    'source': source.name,
  };

  @override
  bool operator ==(Object other) =>
      other is RecordingSettings &&
      other.gainLevel == gainLevel &&
      other.quality == quality &&
      other.source == source;

  @override
  int get hashCode => Object.hash(gainLevel, quality, source);

  @override
  String toString() =>
      'RecordingSettings(gain=${gainLevel.name}, quality=${quality.name}, source=${source.name})';
}
