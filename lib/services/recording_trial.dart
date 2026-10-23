/// 录音设置页「试录 5 秒」流程编排（self-host 新增）。
///
/// 纯 Dart：录音后端与播放函数均注入，可脱离平台测试。
/// 流程：确认麦克风权限 → 录音 N 秒（倒计时）→ 回放 → 删除临时文件 → 释放麦克风。
library;

import 'package:flutter/foundation.dart';

import '../models/speech_practice_models.dart';
import 'app_logger.dart';
import 'speech_practice_platform.dart';

/// 试录阶段
enum RecordingTrialPhase { idle, recording, playing }

/// 试录结果
enum RecordingTrialResult { completed, noPermission, failed, cancelled }

/// 试录界面状态
@immutable
class RecordingTrialState {
  const RecordingTrialState(this.phase, {this.secondsLeft = 0});

  static const idle = RecordingTrialState(RecordingTrialPhase.idle);

  final RecordingTrialPhase phase;

  /// 录音阶段剩余秒数
  final int secondsLeft;

  @override
  bool operator ==(Object other) =>
      other is RecordingTrialState &&
      other.phase == phase &&
      other.secondsLeft == secondsLeft;

  @override
  int get hashCode => Object.hash(phase, secondsLeft);
}

/// 试录编排器。谁创建谁 [dispose]（页面 State）。
class RecordingTrial {
  RecordingTrial({
    required SpeechPracticeBackend backend,
    required Future<void> Function(String filePath) play,
    this.seconds = 5,
    Future<void> Function(Duration)? wait,
  }) : _backend = backend,
       _play = play,
       _wait = wait ?? Future<void>.delayed;

  static const _logTag = 'RecordingTrial';
  static const _promptId = 'recording-trial';

  final SpeechPracticeBackend _backend;
  final Future<void> Function(String filePath) _play;
  final Future<void> Function(Duration) _wait;

  /// 录音时长（秒）
  final int seconds;

  /// 界面订阅的状态
  final ValueNotifier<RecordingTrialState> state = ValueNotifier(
    RecordingTrialState.idle,
  );

  bool _disposed = false;

  /// 是否正在试录（录音或回放中）
  bool get isBusy => state.value.phase != RecordingTrialPhase.idle;

  /// 执行一次试录。进行中重复调用直接返回 [RecordingTrialResult.cancelled]。
  Future<RecordingTrialResult> run() async {
    if (isBusy || _disposed) return RecordingTrialResult.cancelled;
    String? filePath;
    // warmup 之后任何退出路径都必须 cancel + shutdown 释放麦克风
    var engineActive = false;
    try {
      if (!await _ensureMicPermission()) {
        AppLogger.log(_logTag, 'no microphone permission');
        return RecordingTrialResult.noPermission;
      }
      if (_disposed) return RecordingTrialResult.cancelled;

      await _backend.setRecognitionEnabled(false);
      engineActive = true;
      await _backend.warmup();
      filePath = await _backend.startSession(promptId: _promptId);
      AppLogger.log(_logTag, 'recording started seconds=$seconds');

      for (var left = seconds; left > 0; left--) {
        if (_disposed) return RecordingTrialResult.cancelled;
        _emit(
          RecordingTrialState(RecordingTrialPhase.recording, secondsLeft: left),
        );
        await _wait(const Duration(seconds: 1));
      }
      if (_disposed) return RecordingTrialResult.cancelled;

      final stop = await _backend.stopSession();
      engineActive = false;
      filePath = (stop.filePath?.isNotEmpty ?? false)
          ? stop.filePath
          : filePath;
      await _backend.shutdown();
      if (_disposed || filePath == null) return RecordingTrialResult.cancelled;

      _emit(const RecordingTrialState(RecordingTrialPhase.playing));
      await _play(filePath);
      AppLogger.log(_logTag, 'playback done');
      return RecordingTrialResult.completed;
    } catch (e, st) {
      AppLogger.log(_logTag, 'failed error=$e\n$st');
      return RecordingTrialResult.failed;
    } finally {
      if (engineActive) {
        await _safely(_backend.cancelSession);
        await _safely(_backend.shutdown);
      }
      final path = filePath;
      if (path != null) await _safely(() => _backend.deleteRecording(path));
      _emit(RecordingTrialState.idle);
    }
  }

  /// 释放：进行中的流程会在下一个检查点退出并清理。
  void dispose() {
    _disposed = true;
    state.dispose();
  }

  Future<bool> _ensureMicPermission() async {
    final current = await _backend.getPermissionStatus();
    if (current.microphone == SpeechPracticePermissionStatus.granted) {
      return true;
    }
    final requested = await _backend.requestPermissions(onlyMic: true);
    return requested.microphone == SpeechPracticePermissionStatus.granted;
  }

  void _emit(RecordingTrialState next) {
    if (!_disposed) state.value = next;
  }

  Future<void> _safely(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      AppLogger.log(_logTag, 'cleanup failed error=$e');
    }
  }
}
