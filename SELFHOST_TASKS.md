# SELFHOST_TASKS — Chuyển Echo Loop sang hệ sinh thái riêng

> Mục tiêu: build APK cá nhân, **không phụ thuộc server tác giả**, không analytics,
> AI gọi thẳng OpenAI bằng key **người dùng tự nhập trong app** (không nhúng vào APK).
> Quy trình làm việc: xem `CLAUDE.local.md`.

## Quy ước trạng thái

| Ký hiệu | Ý nghĩa |
|---|---|
| `[ ]` | Chưa làm |
| `[~]` | Đang làm |
| `[D]` | **Chờ duyệt design UI** (chưa được code) |
| `[x]` | Code xong, chờ test |
| `[P]` | **PASS** — test OK |
| `[-]` | Bỏ qua (ghi lý do) |

Task gắn nhãn **🎨 UI** bắt buộc: design → người dùng approve → mới code.
Mỗi task khi xong ghi: `Hoàn thành: YYYY-MM-DD` + `Test: <lệnh/kết quả>`.

---

## Phase 0 — Chuẩn bị môi trường

- [P] **T0.1** Cài Flutter + Android Studio/SDK + JDK 17; `flutter doctor` sạch phần Android
  - Hoàn thành: 2026-10-20 — Flutter 3.41.5 (khớp CI) tại `~/development/flutter`, đã tắt analytics Flutter/Dart; SDK 36 có sẵn
  - Test: `flutter doctor` → Android toolchain ✓ (Xcode/CocoaPods lỗi, không ảnh hưởng APK)
- [P] **T0.2** `git init` + commit baseline nguyên bản (để diff/rollback mọi thay đổi)
  - Hoàn thành: 2026-10-20 — baseline `50f46c9` (1738 file gốc), không có remote; thêm ignore `key.properties`/`*.jks`/`*.keystore`
  - Test: `git log` 2 commit, `git status` sạch
- [P] **T0.3** `flutter pub get` + `dart run build_runner build` + build APK `dev` nguyên bản thành công
  - Test: `flutter build apk --release --flavor dev` ra file APK, cài chạy được
  - Hoàn thành: 2026-10-20 — `.g.dart` có sẵn nên không cần build_runner; APK 108MB (lần đầu ~17 phút, Gradle tự cài NDK 28.2 + CMake 3.22.1)
  - Test: cài lên emulator Pixel_9_Pro (arm64) → `app.echoloop.dev` mở tới onboarding, logcat crash buffer trống
- [P] **T0.4** Chạy `flutter analyze` + `flutter test` baseline, ghi lại số test fail sẵn có (nếu có) vào mục *Ghi chú* để không nhầm là do mình gây ra
  - Hoàn thành: 2026-10-20
  - Test: `flutter test` → 5551 pass, 11 skip, **7 fail có sẵn** (xem Ghi chú); `flutter analyze` → 3 error có sẵn, 0 warning, 31 info

## Phase 1 — Gỡ analytics & tracking

- [P] **T1.1** Bỏ Firebase: gỡ `firebase_core`, `firebase_analytics`; xoá `lib/firebase_options.dart`,
  `android/app/google-services.json`, `ios|macos/Runner/GoogleService-Info.plist`,
  plugin `google-services` trong gradle; xoá `lib/analytics/channels/firebase_channel.dart`
- [P] **T1.2** Bỏ PostHog (`posthog_flutter`, `PostHogWidget` trong `main.dart`, `posthog_channel.dart`)
- [P] **T1.3** Bỏ Umeng (`umeng_common_sdk`, `umeng_channel.dart`)
- [P] **T1.4** `analytics_providers.dart` luôn trả `LogOnlyChannel` (log local, không gửi đi)
- [P] **T1.5** Gỡ quyền `AD_ID` / `ACCESS_ADSERVICES_AD_ID` khỏi `AndroidManifest.xml` (dùng `tools:node="remove"`)
- Test phase: `flutter analyze` 0 lỗi; `flutter test` không phát sinh fail mới;
  `grep -ri "posthog\|firebase\|umeng" lib android/app` không còn tham chiếu; build APK OK
- **Phase 1 hoàn thành: 2026-10-20**
  - Đã xoá: 4 package, `firebase_options.dart`, `google-services.json`, 2× `GoogleService-Info.plist`, `firebase.json`,
    3 channel (firebase/posthog/umeng), `posthog_event_policy.dart` + test; plugin gradle `google-services`;
    iOS `setupPostHogNative()` (có bật **Session Replay**) + PostHog key trong `Info.plist` iOS/macOS
  - T1.5: bản gốc đã có `tools:node="remove"` cho AD_ID → giữ nguyên, xác nhận bằng aapt2
  - Test mới: `test/analytics/analytics_providers_test.dart` "默认通道固定为 LogOnly"
  - Test: `flutter analyze` 34 issue = baseline (3 error cũ); `flutter test` 5558 pass / 0 fail
    (7 test retell baseline lần này pass → là test flaky/timeout, không phải lỗi thật);
    `aapt2 dump permissions` không còn AD_ID; dex không còn class posthog/firebase-analytics/umeng
    (còn 3 file `firebase-encoders*.properties` do Google Play Services kéo theo — không phải analytics);
    emulator: app mở OK, log `LogOnlyChannel initialized`, crash buffer trống
  - Chưa làm: `.github/workflows/*` vẫn truyền `POSTHOG_*` dart-define (CI của tác giả, không dùng, vô hại vì code đã gỡ)

## Phase 2 — Mở khoá Pro, bỏ thanh toán

- [P] **T2.1** `entitlement_repository` / `subscription_controller`: luôn trả trạng thái Pro (nguồn `local`)
- [P] **T2.2** Gỡ RevenueCat (`purchases_flutter`), Paddle, `in_app_purchase`; gỡ quyền `BILLING`
- [P] **T2.3** 🎨 Ẩn mọi lối vào paywall / mục "Gói đăng ký" trong Cài đặt
  - Design duyệt: 2026-10-20 — phương án A (ẩn hoàn toàn, không đổi giao diện)
  - Hoàn thành: 2026-10-20 — `subscriptionAvailability` / `webCheckoutMode` / `showStoreWebCheckoutFallback` → `false` khi bật tự host
  - Test: `self_hosted_unlock_test.dart` +1 test; emulator: Cài đặt không có mục Pro
- Test phase: unit test "mọi `PremiumFeature` đều unlocked"; build OK; duyệt tay không thấy paywall
- **T2.1 + T2.2 hoàn thành: 2026-10-20**
  - Công tắc `selfHostedUnlockAllProvider` (mặc định `true`, `lib/features/subscription/providers/self_hosted_unlock.dart`):
    `featureAccess` → luôn `true` (không cần đăng nhập); `SubscriptionController` → luôn Premium,
    `refresh/restore/purchase/refreshIfStale/clearLocalCacheAndRefresh/refreshAfterExternalCheckout` no-op,
    Paddle checkout/portal ném `StateError`
  - `purchaseServiceProvider` → `StubPurchaseService` (chuyển sang `purchase_service.dart`); xoá
    `revenuecat_purchase_service.dart`, `local_storekit_purchase_service.dart` + 2 file test; gỡ RevenueCat init khi khởi động;
    gỡ `purchases_flutter`, `in_app_purchase`; manifest `BILLING` → `tools:node="remove"`
  - Test cũ của logic thanh toán gốc: override công tắc = `false` (8 file) → vẫn kiểm tra logic gốc, không xoá test;
    chỉ xoá group `purchaseServiceTypeFor` (hàm đã gỡ)
  - Test mới: `test/features/subscription/self_hosted_unlock_test.dart` (3 test)
  - Test: analyze không có issue mới; `flutter test` 5531 pass, fail duy nhất = 7 test retell flaky đã biết;
    APK 109.8MB: không còn quyền BILLING, dex không còn `com/revenuecat` / billingclient; emulator chạy OK
  - Còn lại (Phase 4): `sentence_ai_provider` / chat / retell vẫn tự kiểm tra đăng nhập + xử lý 402 từ backend → sẽ thay khi chuyển sang OpenAI

## Phase 3 — Màn hình nhập OpenAI key 🎨 UI

- [P] **T3.1** 🎨 **Design** màn hình "Cấu hình AI" (mockup gửi duyệt) gồm:
  ô nhập API key (ẩn/hiện), Base URL (mặc định `https://api.openai.com/v1`, cho phép endpoint tương thích),
  chọn model, nút "Kiểm tra kết nối", nút xoá key, vị trí mục này trong Cài đặt
- [P] **T3.2** `OpenAiSettingsRepository`: lưu key bằng `flutter_secure_storage` (KHÔNG SharedPreferences, KHÔNG log key)
- [P] **T3.3** Provider `openAiConfigProvider` (state: chưa cấu hình / hợp lệ / lỗi)
- [P] **T3.4** Code UI theo design đã duyệt + chuỗi l10n (en/zh; vi nếu muốn)
- [P] **T3.5** Loại key khỏi backup: kiểm tra `backup_service.dart` không export secure storage
- Test phase: unit test repository (lưu/đọc/xoá, không rò ra prefs); widget test form; test tay "Kiểm tra kết nối"
- **Phase 3 hoàn thành: 2026-10-20**
  - Design tự duyệt: `docs/selfhost/design-ai-settings.md`
  - Code: `lib/features/ai_settings/` (model + validate URL, repository secure storage, `aiSettingsProvider`,
    `AiConnectionTester` GET /models, `AiSettingsScreen`), mục "AI Settings" đầu nhóm Learning trong Cài đặt, 26 chuỗi en/zh
  - T3.5: backup trong app chỉ xuất SharedPreferences + DB → key (secure storage) không bị đưa vào.
    Android auto-backup có thể chép dữ liệu secure storage nhưng đã mã hoá bằng Keystore của máy → không đọc được ở máy khác; giữ nguyên
  - Test mới: `test/features/ai_settings/` 4 file / 22 test + 1 test mục Cài đặt; sửa 2 test Cài đặt cũ (cần cuộn vì danh sách dài thêm)
  - Test: `flutter analyze` = baseline; `flutter test` 5563 pass / 0 fail; emulator: màn hình đúng design,
    Test connection với key giả → hiện lỗi mạng (DNS emulator hỏng), logcat không chứa key
  - Chưa test: key thật (để người dùng); DNS emulator cần chạy lại với `-dns-server 8.8.8.8` trước Phase 6

## Phase 4 — Thay AI backend bằng OpenAI trực tiếp

> Giữ nguyên giao diện client hiện có (`SentenceAiApiClient`, `ChatApiClient`) → chỉ thay implementation,
> UI và parser NDJSON phía trên không đổi.

- [ ] **T4.1** Khảo sát: liệt kê mọi endpoint `/api/v1/stream/*`, định dạng frame NDJSON
  (`ndjson_object_stream.dart` — giao thức "set leaf theo path", xem CLAUDE.md §7.27) và model kết quả;
  ghi vào `docs/selfhost/ai-endpoints.md`
- [ ] **T4.2** `OpenAiClient` tầng thấp (dio, streaming SSE `chat/completions`, timeout, huỷ, map lỗi 401/429/5xx)
- [ ] **T4.3** Adapter: chuyển output OpenAI (JSON) → frame/kết quả mà UI đang chờ
- [ ] **T4.4** Viết prompt + JSON schema cho từng tính năng:
  - [ ] translate  - [ ] lookup-word  - [ ] lookup-phrase  - [ ] analyze
  - [ ] sense-groups  - [ ] evaluate-review  - [ ] chat/sentence
- [ ] **T4.5** Thay `SentenceAiApiClient` + `ChatApiClient` bằng bản OpenAI qua provider
- [ ] **T4.6** 🎨 **Design** trạng thái "chưa có key" khi bấm tính năng AI (banner/dialog dẫn tới Cấu hình AI) → duyệt → code
- Test phase: unit test adapter với stream giả lập (đúng, cắt giữa chừng, lỗi 401/429, huỷ);
  test tay mỗi tính năng với key thật

## Phase 5 — Đăng nhập / Supabase

- [ ] **T5.1** Quyết định: (a) Supabase riêng (chỉ auth) hoặc (b) bỏ đăng nhập — *hỏi người dùng*
- [ ] **T5.2a** Nếu (a): tạo project, điền `.dev.env` (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`), cấu hình Google/Apple OAuth
- [ ] **T5.2b** Nếu (b): app khởi động ở chế độ khách, ẩn UI đăng nhập/tài khoản
- Test phase: khởi động sạch, không request tới `echo-loop.*`

## Phase 6 — Các dịch vụ còn phụ thuộc server tác giả

- [ ] **T6.1** Cloud transcription (`transcription_api_client.dart`): chuyển sang ASR offline mặc định; (tùy chọn) Whisper API bằng key người dùng
- [ ] **T6.2** Model CDN (`regional_service_endpoints.dart`): trỏ về CDN riêng (R2 / GitHub Releases) theo `scripts/piper_tts_models.manifest.txt`
- [ ] **T6.3** Remote config (`remote_config_service.dart`): dùng giá trị mặc định local, không gọi mạng
- [ ] **T6.4** Featured podcasts + community collections: tắt hoặc trỏ JSON tĩnh
- [ ] **T6.5** App update check: tắt
- [ ] **T6.6** Baidu Netdisk: gỡ tính năng (OAuth qua server tác giả)
- [ ] **T6.7** `API_BASE_URL` không còn được dùng → xoá cấu hình
- Test phase: chạy app + mitmproxy/Charles, xác nhận **không còn request nào tới `echo-loop.top/.cn`**,
  posthog, firebase, umeng; chỉ còn OpenAI (khi dùng AI), CDN riêng, trang từ điển

## Phase 7 — Hoàn thiện

- [ ] **T7.1** Đổi `applicationId` (vd `com.<bạn>.echoloop`) + tên app để cài song song bản gốc
- [ ] **T7.2** Tạo keystore riêng + `android/key.properties` (KHÔNG commit), build `--flavor prod`
- [ ] **T7.3** Kiểm thử tổng: `flutter analyze`, `flutter test`, smoke test trên máy thật
- [ ] **T7.4** Viết `docs/selfhost/README.md`: cách build, cách nhập key, giữ LICENSE gốc (AGPL-3.0 — nếu phân phối APK cho người khác phải công khai mã đã sửa)

## Phase 8 — Tiếng Việt (yêu cầu thêm 2026-10-20)

> Làm sau Phase 3 (cùng sửa file `.arb`), trước Phase 4. T8.4 gắn với Phase 4 (prompt AI).

- [P] **T8.1** Khảo sát mọi chỗ giả định `zh` / `zh-CN` (UI locale, native language, từ điển offline, prompt, TTS, sắp xếp/định dạng) → ghi `docs/selfhost/vietnamese.md`
  - Hoàn thành: 2026-10-20 — xem `docs/selfhost/vietnamese.md`
- [ ] **T8.2** Giao diện tiếng Việt: `lib/l10n/app_vi.arb` dịch đủ mọi key (đối chiếu số key với `app_en.arb`),
  thêm `Locale('vi')` vào `supportedLocales` + `matchUiLocale` (máy tiếng Việt → UI tiếng Việt), thêm "Tiếng Việt" vào chọn App Language
- [ ] **T8.3** Native language `vi`: thêm vào `supportedNativeLanguages`; không có từ điển offline Anh→Việt →
  ẩn/không tải từ điển local cho `vi`, mặc định dùng từ điển AI + thêm Cambridge English–Vietnamese vào từ điển web
- [ ] **T8.4** Prompt AI (Phase 4) trả lời theo native language (vi / zh-CN / zh-TW)
- [ ] **T8.5** 🎨 Design: dòng "Tiếng Việt" trong 2 màn chọn ngôn ngữ + trạng thái "không có từ điển offline" → tự duyệt
- Test phase: unit test `matchUiLocale` / `matchNativeLanguage` với `vi`/`vi-VN`; test số key `app_vi.arb` == `app_en.arb`;
  widget test chuyển sang tiếng Việt; emulator: đổi ngôn ngữ → UI tiếng Việt, tra từ không lỗi

---

## Ghi chú / Quyết định

- 2026-10-20: Chọn cách A (client gọi thẳng OpenAI). Key nhập trong app, lưu secure storage.
- 2026-10-20 **Baseline test (bản gốc, chưa sửa gì)** — mọi fail dưới đây KHÔNG phải do mình:
  - `flutter test`: 5551 pass / 11 skip / 7 fail — cả 7 đều trong `test/providers/retell_recording_controller_test.dart`, lỗi "did not complete" (test treo/timeout)
  - `flutter analyze`: 3 error, cả 3 trong `integration_test/kokoro_tts_test.dart` (API `TtsEngineKind.echoLoop` / `TtsEngineFactory` đã đổi, test cũ chưa cập nhật)
  - **Đính chính (2026-10-20)**: baseline còn **3 warning** có sẵn (`text_context_menu.dart`, `notification_permission_dialog.dart`,
    `test/database/database_switch_test.dart`) — ghi "0 warning" ở T0.4 là sai do lệnh grep lọc thiếu
- 2026-10-20 `flutter pub get` cảnh báo advisory GHSA-cr65-55v9-xhvv ở `dio_http2_adapter` 2.7.1 (bản vá 2.9.0) — cân nhắc nâng cấp sau Phase 6
- 2026-10-20 **Chế độ tự chạy (người dùng đi ngủ, yêu cầu làm hết không cần hỏi):**
  - Design UI (T3.1, T4.6): Claude tự duyệt, mockup lưu ở `docs/selfhost/design-*.md` để người dùng xem lại sau
  - T5.1: chọn cả hai — chưa cấu hình Supabase → chế độ khách (ẩn đăng nhập); điền `SUPABASE_URL`/key → đăng nhập bật lại
  - Test AI với key thật: để người dùng tự làm (checklist trong `docs/selfhost/README.md`)
  - T6.2: model tải thẳng từ nguồn công khai gốc thay vì CDN riêng
  - T7.2: Claude tự tạo keystore + mật khẩu ngẫu nhiên trong `android/key.properties` (không commit) — người dùng PHẢI sao lưu

