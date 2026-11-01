import 'package:echo_loop/services/playback_volume_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('just_audio: volume ≤ 1, phần >100% chuyển thành gain dB', () {
    expect(const PlaybackVolume(percent: 50).justAudioVolume, 0.5);
    expect(const PlaybackVolume(percent: 200).justAudioVolume, 1.0);
    expect(const PlaybackVolume().loudnessGainDb, 0);
    expect(
      const PlaybackVolume(percent: 200).loudnessGainDb,
      closeTo(6.02, 0.01),
    );
    expect(const PlaybackVolume(normalize: true).loudnessGainDb, 6);
  });

  test('lưu và nạp lại từ SharedPreferences, kẹp trong 50–200', () async {
    SharedPreferences.setMockInitialValues({'playback_volume_percent': 500});
    final prefs = await SharedPreferences.getInstance();
    PlaybackVolumeSettings.load(prefs);
    expect(PlaybackVolumeSettings.value.percent, 200);

    await PlaybackVolumeSettings.update(
      const PlaybackVolume(percent: 150, normalize: true),
    );
    PlaybackVolumeSettings.load(prefs);
    expect(
      PlaybackVolumeSettings.value,
      const PlaybackVolume(percent: 150, normalize: true),
    );
    await PlaybackVolumeSettings.update(const PlaybackVolume());
  });
}
