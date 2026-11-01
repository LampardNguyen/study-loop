# Hội thoại → giọng nói (dialogue lesson)

## Mục đích
Biến văn bản hội thoại `Tên: câu nói` thành bài học audio có phụ đề; có thể nhờ AI viết hội thoại.

## File / class chính
- `lib/features/dialogue_lesson/dialogue_parser.dart` — `parseDialogue` (mỗi dòng `Tên: câu nói`).
- `lib/features/dialogue_lesson/dialogue_lesson_service.dart` — `DialogueLessonService` (preview / createLesson),
  `synthesizeToWav`, `normalizePcm16Loudness` (cân bằng độ lớn từng câu), `DialogueSpeechLevel` (prompt giọng đọc).
- `lib/features/dialogue_lesson/dialogue_tts_panel.dart` — UI nhập hội thoại, chọn giọng, chất lượng, cấp độ nghe.
- `lib/features/dialogue_lesson/dialogue_ai_generator.dart` — `DialogueAiGenerator`, `DialogueCefrLevel`, `parseGeneratedDialogue`.
- `lib/features/dialogue_lesson/dialogue_ai_generate_sheet.dart` — bảng "Tạo bằng AI".
- `lib/services/openai/ai_prompts.dart` — `dialogueGeneratePrompt`.

## Luồng
1. Tạo bằng AI (tuỳ chọn): sheet → `OpenAiChatClient.streamCompletion` (jsonMode, model trong Cài đặt AI, mặc định gpt-4.1-mini)
   → JSON `{title, lines[{speaker,text}]}` → văn bản `Tên: câu nói` → điền khung; cấp độ giọng tự chọn theo trình độ.
2. Mỗi câu → `OpenAiAudioClient.synthesizeSpeech` (PCM16 24kHz); `gpt-4o-mini-tts` kèm `instructions` theo
   `DialogueSpeechLevel` (tts-1 / tts-1-hd không gửi).
3. Chuẩn hoá RMS từng câu → ghép + khoảng lặng → WAV → m4a; phụ đề SRT tính theo byte.

## Mạng
Chỉ gọi `{baseUrl}/chat/completions` và `{baseUrl}/audio/speech` trong Cài đặt AI (mặc định api.openai.com).

## Lưu ý
- SharedPreferences: `dialogue_speech_level`, `dialogue_ai_*` (lựa chọn sheet; không lưu chủ đề tự nhập).

## Liên quan
- [[playback-volume]] · [[network-hosts]]
