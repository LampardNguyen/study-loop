# T8.1 — Khảo sát hỗ trợ tiếng Việt

Ngày: 2026-10-20. Khảo sát mọi chỗ code đang giả định ngôn ngữ là `zh` / `zh-CN`.

## A. Ngôn ngữ giao diện (UI locale)

| Vị trí | Hiện trạng | Việc cần làm (T8.2) |
|---|---|---|
| `lib/main.dart:490` `supportedLocales` | `[en, zh-CN]` | thêm `Locale('vi')` |
| `lib/providers/settings_provider.dart` `matchUiLocale` | zh → zh-CN, còn lại → en | thêm `vi` → `Locale('vi')` |
| `settings_provider.dart` `readInitialUiLocaleSync` | đọc `en` / `zh` / `zh-CN` | thêm `vi` |
| `settings_screen.dart` `_getLanguageName` + dialog chọn ngôn ngữ | chỉ có English / 中文 | thêm "Tiếng Việt" 🇻🇳 (key `languageVietnamese`) |
| `lib/l10n/app_vi.arb` | không có | tạo mới, dịch đủ 1649 key (6 agent dịch song song, đã kiểm tra placeholder/ICU) |
| `lib/utils/time_format.dart` timeago | chỉ đăng ký `zh`, `en` | đăng ký `vi` (package `timeago` có sẵn `ViMessages`) |
| `test/helpers/test_app.dart` `supportedLocales` | `[en, zh]` | không bắt buộc |

Chấp nhận giữ nguyên (ảnh hưởng nhỏ, vi rơi về nhánh tiếng Anh):
- `learning_plan_screen.dart:249/2390`, `study_duration_chart.dart`, `review_completion_summary.dart`: chọn định dạng ngày/chuỗi cứng theo `isZh`.
- `study_screen.dart:936`, `main_shell.dart:165`, `settings_screen.dart:629`: link cộng đồng trên server tác giả, xử lý ở Phase 6.
- `onboarding_survey_screen.dart:647/753`: chọn ảnh/nội dung theo `isChinese`.

## B. Ngôn ngữ mẹ đẻ (native language)

| Vị trí | Hiện trạng | Việc cần làm (T8.3) |
|---|---|---|
| `settings_provider.dart` `supportedNativeLanguages` | `zh-CN`, `zh-TW` | thêm `'vi': 'Tiếng Việt'` |
| `settings_provider.dart` `matchNativeLanguage` | không khớp → mục đầu tiên (`zh-CN`) | máy tiếng Việt sẽ tự khớp `vi` |
| `lib/services/dictionary/dictionary_catalog.dart` | chỉ có từ điển offline Anh→Trung (CDN tác giả) | `vi` không có từ điển offline → `dictionarySpecOf('vi')` sẽ ném lỗi; phải chặn trước ở dictionary provider |
| `lib/providers/dictionary_provider.dart` | luôn mở từ điển offline theo native language | `vi` → trạng thái "không có từ điển offline", không tải |
| `ai_dictionary_source.dart:40` `_defaultLanguage = 'zh-CN'` | ngôn ngữ đích của từ điển AI | truyền native language (gắn Phase 4 / T8.4) |
| `sentence_ai_api_client.dart` `targetLanguage` | gửi lên backend tác giả | Phase 4: đưa vào prompt OpenAI |
| Từ điển web | không có từ điển Anh→Việt | thêm Cambridge English–Vietnamese |
