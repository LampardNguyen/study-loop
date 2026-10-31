# Dung lượng APK (build-size)

Đo ngày 2026-10-31 trên `app-prod-release.apk` 1.0.51: file APK 106.9 MB; bên trong 117 MB, trong đó 95.5 MB được lưu không nén (thư viện `.so`, AGP mặc định để nguyên khi minSdk ≥ 23). Chỉ có `arm64-v8a` (`abiFilters` trong `android/app/build.gradle.kts`).

| Thành phần | MB | Đến từ |
|---|---|---|
| `libapp.so` (code Dart đã biên dịch) | 27.4 | toàn bộ code app, gồm cả phần thừa từ bản gốc (subscription, supabase, remote config…) |
| `libonnxruntime.so` + `libsherpa-onnx-*` | 25.3 | `sherpa_onnx`: nhận dạng giọng nói offline (ASR) |
| `libmpv.so` + `libav*`/`libswscale` | ~26 | `media_kit_libs_video`: trình phát audio/video (ffmpeg dùng chung với `ffmpeg_kit_flutter_new_min` để cắt audio) |
| `libflutter.so` | 10.8 | Flutter engine (bắt buộc) |
| ~~`NotoSansSC-Regular.ttf` + NotoSans~~ | ~~12~~ | đã xoá cùng tính năng xuất PDF (T14.15) |
| assets khác (bài mẫu 1.8, font, icon) | ~5 | |
| `classes.dex` + `libsqlite3.so` + resources | ~7 | |

## Hướng giảm (chưa làm)
- ~~Bỏ font PDF~~: đã xoá hẳn tính năng xuất PDF (T14.15, khoảng −12 MB).
- Nén thư viện `.so` (`packaging.jniLibs.useLegacyPackaging = true`): file APK tải về nhỏ đi nhiều, nhưng sau khi cài app chiếm nhiều chỗ hơn vì phải giải nén.
- `--split-debug-info --obfuscate` khi build: giảm `libapp.so` vài MB.
- Bỏ ASR offline (sherpa/onnx) nếu chỉ dùng OpenAI để chép lời: −25 MB, nhưng là thay đổi tính năng lớn.
  **Lưu ý:** `sherpa_onnx` dùng ở 3 chỗ: (1) ASR offline khi luyện nói/nhắc lại/kể lại (`services/asr/offline_asr_backend.dart`, `speech_practice_platform.dart` chọn backend); (2) tạo phụ đề trên máy cho bài nghe (`local_transcription_task_provider.dart`, gọi từ `manage_subtitles_sheet.dart`); (3) **giọng đọc TTS offline Piper/Kokoro** (`services/tts/piper_synthesizer.dart`, `kokoro_synthesizer.dart`). Bỏ thư viện này thì mất cả 3. Model không đóng gói trong APK mà người dùng tải về khi bật.

## Liên quan
- [[index]]
