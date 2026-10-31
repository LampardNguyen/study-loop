# Nhận dạng giọng nói offline (offline-asr)

Thư viện: `sherpa_onnx` (kèm `libonnxruntime.so`), engine ở `lib/services/asr/sherpa_onnx_engine.dart`.

## Model (Cá nhân → Nhận dạng giọng nói → Study Loop AI)
- 3 mức tương ứng 3 model Whisper tiếng Anh int8 (`lib/services/asr/asr_model_catalog.dart`): Fast = `whisper-tiny-en-int8`, Balance = `whisper-base-en-int8`, Accurate = `whisper-small-en-int8`.
- Model không đóng gói trong APK. `asr_model_manager.dart` tải từ `RuntimeEndpointRouter.modelCdnUri('/model/asr/…zip')`, mặc định là `https://cdn.echo-loop.top` (`lib/config/regional_service_endpoints.dart`, đổi bằng `MODEL_CDN_BASE_URL`; README self-host ghi đây là ngoại lệ đã biết: file tĩnh công khai, không kèm dữ liệu người dùng). Từ điển offline, thư viện phát âm, giọng Piper/Kokoro cũng tải từ CDN này.
- Cài đặt: `offline_asr_settings_provider.dart`.

## Nơi dùng
1. Luyện nói (Nghe – nhắc lại, Kể lại, luyện câu khó): `speechPracticeBackendProvider` trong `speech_practice_platform.dart` → `OfflineAsrBackend` khi đã bật và có model; nếu không thì chỉ ghi âm. Xem [[recording]].
2. Tạo phụ đề trên máy: `local_transcription_task_provider.dart`. **Mục này bị tác giả gốc ẩn**: `_showOfflineTranscriptionEntry => false` trong `lib/widgets/manage_subtitles_sheet.dart` (comment: kết quả chưa ổn định). Code vẫn còn đủ, model dùng chung với `localTranscriptionModelProvider`.
3. Giọng đọc offline Piper/Kokoro dùng chung thư viện `sherpa_onnx` (`services/tts/*_synthesizer.dart`).

## Liên quan
- [[index]] · [[build-size]] · [[recording]]
