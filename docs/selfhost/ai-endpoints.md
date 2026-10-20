# T4.1 — Các endpoint AI của server tác giả và cách thay thế (2026-10-20)

## Giao thức stream gốc (server tác giả)

Mỗi dòng NDJSON là một trong các dạng sau (`lib/services/ndjson_object_stream.dart`):
- `{"ops":[{"p":["meanings",0,"definition"],"v":"..."}]}`: đặt giá trị vô hướng (lá) theo đường dẫn
- `{"done":true}`: kết thúc thành công, khung cuối có `isFinal = true`, chỉ khi đó mới được ghi vào cache
- `{"__error":...}`: lỗi trong stream

Chat dùng giao thức text riêng: `{"delta":"..."}` / `{"done":true}` (`ndjson_text_stream.dart`).

## Cách thay thế (bản tự host)

Model trả JSON qua `chat/completions` (`stream: true`, `response_format: json_object`)
→ `parsePartialJson` dựng snapshot từ đoạn JSON dở dang
→ `diffJsonLeafOps` so snapshot mới với cũ, sinh `ops` cho các lá mới hoặc đã đổi
→ JSON đầy đủ parse được → `{"done":true}`, không parse được → `{"__error":"invalid_json"}`
→ đưa vào **đúng** `accumulateNdjsonObject` cũ. Provider, cache và UI hiện chữ dần giữ nguyên.

| Endpoint gốc | Method client | Thay bằng | Prompt / schema |
|---|---|---|---|
| `POST /api/v1/stream/translate` | `translateStream` | chat JSON | `translationPrompt` → `{translation}` |
| `POST /api/v1/stream/analyze` | `analyzeStream` | chat JSON | `analysisPrompt` → `{grammar[], vocabulary[], listening[]}` |
| `POST /api/v1/stream/lookup-word` | `lookupWordStreamFrames` | chat JSON | `wordLookupPrompt` → `DictionaryEntry` |
| `POST /api/v1/stream/lookup-phrase` | `lookupPhraseStreamFrames` | chat JSON | `phraseLookupPrompt` → `MultiWordDictionaryEntry` |
| `POST /api/v1/stream/sense-groups` | `senseGroupsStream` | chat JSON | `senseGroupsPrompt` → `{medium[], fine[]}` (ghép các chunk phải ra đúng câu gốc) |
| `POST /api/v1/stream/evaluate-review` | `evaluateReviewStream` | `audio/transcriptions` (whisper-1) + chat JSON | `retellReviewPrompt` → `RetellReviewEvaluation`; `transcript` lấy từ Whisper |
| `POST /api/v1/stream/chat/sentence` | `ChatApi.streamChat` | chat text stream | system prompt chứa câu đang học + ngôn ngữ mẹ đẻ |

Mã nguồn: `lib/services/openai/`, `lib/features/chatbot/services/openai_chat_api.dart`.

## Lỗi và "đăng nhập"

- Chưa có key, hoặc OpenAI trả 401 → giữ nguyên nhánh "cần đăng nhập" của code cũ (401 / `DictionaryAuthRequiredException` /
  `ChatAuthRequiredException`) → UI hiện "Chưa cấu hình AI" và dẫn tới Cài đặt AI (T4.6).
- `aiAccessTokenProvider` thay token Supabase ở các chỗ gọi AI: trả token đánh dấu khi đã có key, `null` khi chưa.
- Các lỗi HTTP khác (429, 5xx…) ném `DioException` kèm status, đi vào nhánh lỗi chung có sẵn ("Thử lại").

## Còn phụ thuộc server tác giả (Phase 6)

- `transcription_api_client.dart` (`/api/v2/user-audio/*`): chuyển giọng nói thành văn bản trên đám mây và word timestamps → T6.1
- Các endpoint ngoài AI: config, podcast, collections, Paddle, Baidu → T6.3–T6.6
