import 'package:flutter_test/flutter_test.dart';

import 'package:echo_loop/models/speech_practice_models.dart';
import 'package:echo_loop/services/recording_trial.dart';
import 'package:echo_loop/services/speech_practice_platform.dart';

/// 记录调用序列的假后端
class _FakeBackend implements SpeechPracticeBackend {
  _FakeBackend({this.micGranted = true, this.grantOnRequest = false});

  bool micGranted;
  final bool grantOnRequest;
  final calls = <String>[];
  Object? startError;

  SpeechPracticePermissionState get _perm => SpeechPracticePermissionState(
    microphone: micGranted
        ? SpeechPracticePermissionStatus.granted
        : SpeechPracticePermissionStatus.denied,
  );

  @override
  bool get isSupported => true;
  @override
  Future<SpeechPracticePermissionState> getPermissionStatus() async => _perm;
  @override
  Future<SpeechPracticePermissionState> requestPermissions({
    bool onlyMic = false,
  }) async {
    calls.add('request(onlyMic=$onlyMic)');
    if (grantOnRequest) micGranted = true;
    return _perm;
  }

  @override
  Stream<SpeechPracticeEvent> get events => const Stream.empty();
  @override
  Future<int> getDeviceRamBytes() async => 0;
  @override
  Future<void> setRecognitionEnabled(bool enabled) async =>
      calls.add('recognition=$enabled');
  @override
  Future<void> warmup({String locale = 'en-US'}) async => calls.add('warmup');
  @override
  Future<String> startSession({
    required String promptId,
    String locale = 'en-US',
  }) async {
    calls.add('start');
    if (startError != null) throw startError!;
    return '/tmp/trial.wav';
  }

  @override
  Future<SpeechPracticeStopResult> stopSession() async {
    calls.add('stop');
    return const SpeechPracticeStopResult(filePath: '/tmp/trial.wav');
  }

  @override
  Future<void> cancelSession() async => calls.add('cancel');
  @override
  Future<void> deleteRecording(String filePath) async =>
      calls.add('delete $filePath');
  @override
  Future<void> shutdown() async => calls.add('shutdown');
}

void main() {
  test('完整流程：倒计时 → 回放录音 → 删除临时文件', () async {
    final backend = _FakeBackend();
    final played = <String>[];
    final trial = RecordingTrial(
      backend: backend,
      seconds: 3,
      wait: (_) async {},
      play: (path) async => played.add(path),
    );
    final phases = <RecordingTrialState>[];
    trial.state.addListener(() => phases.add(trial.state.value));

    final result = await trial.run();

    expect(result, RecordingTrialResult.completed);
    expect(played, ['/tmp/trial.wav']);
    expect(phases.map((s) => s.secondsLeft).take(3), [3, 2, 1]);
    expect(phases.last, RecordingTrialState.idle);
    expect(backend.calls, [
      'recognition=false',
      'warmup',
      'start',
      'stop',
      'shutdown',
      'delete /tmp/trial.wav',
    ]);
    trial.dispose();
  });

  test('无麦克风权限且请求被拒：不录音', () async {
    final backend = _FakeBackend(micGranted: false);
    final trial = RecordingTrial(
      backend: backend,
      wait: (_) async {},
      play: (_) async {},
    );

    expect(await trial.run(), RecordingTrialResult.noPermission);
    expect(backend.calls, ['request(onlyMic=true)']);
    trial.dispose();
  });

  test('请求权限后获准：继续录音', () async {
    final backend = _FakeBackend(micGranted: false, grantOnRequest: true);
    final trial = RecordingTrial(
      backend: backend,
      seconds: 1,
      wait: (_) async {},
      play: (_) async {},
    );

    expect(await trial.run(), RecordingTrialResult.completed);
    trial.dispose();
  });

  test('录音中途页面销毁：取消会话、释放麦克风、删除文件，不回放', () async {
    final backend = _FakeBackend();
    var playCalled = false;
    late RecordingTrial trial;
    trial = RecordingTrial(
      backend: backend,
      seconds: 5,
      wait: (_) async => trial.dispose(),
      play: (_) async => playCalled = true,
    );

    expect(await trial.run(), RecordingTrialResult.cancelled);
    expect(playCalled, isFalse);
    expect(
      backend.calls,
      containsAllInOrder([
        'start',
        'cancel',
        'shutdown',
        'delete /tmp/trial.wav',
      ]),
    );
  });

  test('startSession 抛错：返回 failed 且回到 idle', () async {
    final backend = _FakeBackend()..startError = Exception('mic busy');
    final trial = RecordingTrial(
      backend: backend,
      wait: (_) async {},
      play: (_) async {},
    );

    expect(await trial.run(), RecordingTrialResult.failed);
    expect(trial.state.value, RecordingTrialState.idle);
    // warmup 已占用麦克风，出错也必须释放
    expect(backend.calls, containsAllInOrder(['warmup', 'start', 'shutdown']));
    trial.dispose();
  });
}
