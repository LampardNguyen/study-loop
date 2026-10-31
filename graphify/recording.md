# Ghi âm (recording)

Mục đích: ghi giọng người học (nhắc lại, kể lại, luyện từ khó) ra file WAV, kèm cài đặt âm lượng và chất lượng.

## File chính
- `lib/models/recording_settings.dart` — `RecordingSettings` (`RecordingGainLevel` → hệ số khuếch đại, `RecordingQuality` → tần số lấy mẫu, `RecordingSource` auto/builtIn/headset), `toPlatformArgs()` → `{gain, sampleRate, source}`; `RecordingHeadset` (wired/usb/bluetooth + tên).
- `lib/providers/recording_settings_provider.dart` — `RecordingSettingsNotifier` (keepAlive), lưu vào SharedPreferences (`recording_gain_level`, `recording_quality`, `recording_source`).
- `lib/screens/recording_settings_screen.dart` — màn Cá nhân → Ghi âm (chỉ có trên Android), có nút thử ghi 5 giây (`lib/services/recording_trial.dart`).
- `lib/services/speech_practice_platform.dart` — `SpeechPracticePlatform` (MethodChannel). Mỗi lần `startSession` app đọc cài đặt qua hàm `recordingSettings` được truyền vào. `getHeadsetInput()` → method native `listInputDevices`.
- `android/.../echoloop/AndroidSpeechPracticeHandler.kt` — xử lý `startSession`, đọc `gain`/`sampleRate` → `wavRecorder.configure(...)`, đọc `source` → `applyRecordingSource()` trước `startRecording` (chọn mic qua `AudioManager.getDevices`; tai nghe: có dây/USB ưu tiên, rồi Bluetooth). Bluetooth cần bật đường SCO (`setCommunicationDevice` API 31+, `startBluetoothSco` cho máy cũ) và tắt lại khi stop/cancel/shutdown. Có thêm quyền `MODIFY_AUDIO_SETTINGS`.
- `android/.../echoloop/WavRecorder.kt` — `AudioRecord(VOICE_RECOGNITION, …)`, `setPreferredDevice(device)`, ghi PCM16 mono + header WAV. Nếu máy không hỗ trợ tần số lấy mẫu đã chọn thì quay về 16 kHz.

## Luồng
Màn cài đặt → Notifier (lưu prefs) → `SpeechPracticePlatform.startSession` gửi args → Handler.configure → `WavRecorder.initialize` → `startRecording(filePath)`.

## Nơi dùng
`speech_recording_controller.dart`, `retell_recording_controller_provider.dart`, `listen_and_repeat_controller.dart`, `repeat_flow_engine.dart`, `review_difficult_practice_provider.dart`.

## Màn cài đặt
Mục "Nguồn ghi âm" chỉ hiện đủ 3 lựa chọn khi có tai nghe; màn hình kiểm tra lại tai nghe mỗi 2 giây (Android không báo cho Flutter khi cắm/rút). Mic đã chọn không còn → native trả `null` → hệ thống tự chọn mic (thường là mic máy).

## Liên quan
- [[index]]
