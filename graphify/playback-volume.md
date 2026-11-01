# Âm lượng phát & các engine phát audio

**Mục đích:** chỉnh âm lượng 50–200% + chuẩn hoá cho mọi trình phát; giải thích engine nào phát cái gì.

## Engine phát (3 loại)
- `EchoLoopAudioHandler` — `lib/services/background_audio_handler.dart`: just_audio, có media session/lock screen.
- `ForegroundAudioEngine` — `lib/providers/audio_engine/foreground_audio_engine_provider.dart`: just_audio "trần", dùng cho đọc theo câu khó / kể lại / ôn câu yêu thích.
- `MediaKitPlayerBackend` — `lib/services/media_kit_player_backend.dart`: media_kit (mpv), dùng cho trình phát media/video.
- Mặc định đều 100% (không chỗ nào hạ âm lượng); audio session `speech()` → Android `usage: media`.

## Âm lượng phát (T15.1)
- `lib/services/playback_volume_settings.dart`: `PlaybackVolume` (percent, normalize), `PlaybackVolumeSettings` (ValueNotifier toàn cục, SharedPreferences `playback_volume_percent` / `playback_volume_normalize`, nạp trong `main.dart`).
- just_audio: `VolumeAwarePlayer` tạo player kèm `AndroidLoudnessEnhancer`; volume = min(%,100)/100, phần >100% → gain dB; chuẩn hoá = +6 dB (enhancer có limiter).
- media_kit: `volume-max=200`, `setVolume(%)`, chuẩn hoá = `af=lavfi=[dynaudnorm]`; gỡ `af` trước khi `open()` và chỉ gắn sau khi `play()` (gắn trước khi mở file làm mpv đứng ở 0s — T15.9).
- UI: `lib/widgets/playback_volume_button.dart` (icon `speaker_outlined` — tránh trùng `volume_up_outlined` của badge ghi âm trong test retell). Gắn ở AppBar: player, media playback, intensive, listen-and-repeat, `ParagraphPracticeScaffold` (nghe mù, kể lại).
- Không áp: player phụ (nghe thử TTS, cắt audio, nghe thử ghi âm).

## Bài hội thoại (T15.2)
- `normalizePcm16Loudness` trong `lib/features/dialogue_lesson/dialogue_lesson_service.dart`: mỗi câu PCM16 về RMS ~-18 dBFS trước khi ghép.

## Liên quan
- [[recording]]
