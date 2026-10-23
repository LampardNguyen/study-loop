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

- [P] **T4.1** Khảo sát: liệt kê mọi endpoint `/api/v1/stream/*`, định dạng frame NDJSON
  (`ndjson_object_stream.dart` — giao thức "set leaf theo path", xem CLAUDE.md §7.27) và model kết quả;
  ghi vào `docs/selfhost/ai-endpoints.md`
- [P] **T4.2** `OpenAiClient` tầng thấp (dio, streaming SSE `chat/completions`, timeout, huỷ, map lỗi 401/429/5xx)
- [P] **T4.3** Adapter: chuyển output OpenAI (JSON) → frame/kết quả mà UI đang chờ
- [P] **T4.4** Viết prompt + JSON schema cho từng tính năng:
  - [x] translate  - [x] lookup-word  - [x] lookup-phrase  - [x] analyze
  - [x] sense-groups  - [x] evaluate-review  - [x] chat/sentence
  - Hoàn thành: 2026-10-21 — Test: người dùng tự thử với key OpenAI thật, mọi tính năng AI chạy ổn
- [P] **T4.5** Thay `SentenceAiApiClient` + `ChatApiClient` bằng bản OpenAI qua provider
- [P] **T4.6** 🎨 **Design** trạng thái "chưa có key" khi bấm tính năng AI (banner/dialog dẫn tới Cấu hình AI) → duyệt → code
- Test phase: unit test adapter với stream giả lập (đúng, cắt giữa chừng, lỗi 401/429, huỷ);
  test tay mỗi tính năng với key thật
- **Phase 4 hoàn thành code + test tự động: 2026-10-20** (T4.4 còn chờ người dùng thử với key thật → giữ `[x]`)
  - Khảo sát: `docs/selfhost/ai-endpoints.md`; design T4.6 tự duyệt: `docs/selfhost/design-ai-key-required.md`
  - Cách làm: OpenAI stream JSON → `parsePartialJson` → `diffJsonLeafOps` → frame NDJSON cũ → `accumulateNdjsonObject` cũ
    (`lib/services/openai/`), nên provider/cache/UI hiện dần giữ nguyên. Chat: `OpenAiChatApi`. Kể lại: Whisper + chat
  - "Đăng nhập" để dùng AI → `aiAccessTokenProvider` (đã có key hay chưa); các hộp thoại/nút "Đăng nhập" ở AI → "Chưa cấu hình AI / Mở Cài đặt AI"
  - Test mới: `test/services/openai/` (5 file, 27 test), `test/features/chatbot/services/openai_chat_api_test.dart`;
    test cũ: override `aiAccessTokenProvider` từ session giả lập (giữ nguyên ý nghĩa), cập nhật chữ ở 5 test UI (thay đổi có chủ đích);
    `test/flutter_test_config.dart` giả lập `FlutterSecureStorage` dùng chung
  - Test: `flutter test` 5603 pass / 0 fail; analyze = baseline
  - Còn lại: chưa thử với key thật; chuyển giọng nói thành văn bản trên đám mây + word timestamps vẫn đi server tác giả → T6.1

## Phase 5 — Đăng nhập / Supabase

- [P] **T5.1** Quyết định: (a) Supabase riêng (chỉ auth) hoặc (b) bỏ đăng nhập — *hỏi người dùng*
- [-] **T5.2a** Nếu (a): tạo project, điền `.dev.env` (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`), cấu hình Google/Apple OAuth
- [P] **T5.2b** Nếu (b): app khởi động ở chế độ khách, ẩn UI đăng nhập/tài khoản
- Test phase: khởi động sạch, không request tới `echo-loop.*`
- **Phase 5 hoàn thành: 2026-10-20** — chọn cả hai (tự quyết theo chế độ tự chạy): mặc định **chế độ khách**
  (`supabaseAuthEnabledProvider` = `isSupabaseAuthConfigured`, ẩn nhóm Tài khoản); điền `SUPABASE_URL`/key → tự bật lại.
  T5.2a `[-]`: người dùng tự tạo project khi cần (hướng dẫn trong `docs/selfhost/README.md` §6). Test: `settings_screen_test` thêm case khách

## Phase 6 — Các dịch vụ còn phụ thuộc server tác giả

- [P] **T6.1** Cloud transcription (`transcription_api_client.dart`): chuyển sang ASR offline mặc định; (tùy chọn) Whisper API bằng key người dùng
- [P] **T6.2** Model CDN (`regional_service_endpoints.dart`): trỏ về CDN riêng (R2 / GitHub Releases) theo `scripts/piper_tts_models.manifest.txt`
- [P] **T6.3** Remote config (`remote_config_service.dart`): dùng giá trị mặc định local, không gọi mạng
- [P] **T6.4** Featured podcasts + community collections: tắt hoặc trỏ JSON tĩnh
- [P] **T6.5** App update check: tắt
- [P] **T6.6** Baidu Netdisk: gỡ tính năng (OAuth qua server tác giả)
- [P] **T6.7** `API_BASE_URL` không còn được dùng → xoá cấu hình
- Test phase: chạy app + mitmproxy/Charles, xác nhận **không còn request nào tới `echo-loop.top/.cn`**,
  posthog, firebase, umeng; chỉ còn OpenAI (khi dùng AI), CDN riêng, trang từ điển
- **Phase 6 hoàn thành: 2026-10-20**
  - T6.7 (gốc rễ): `API_BASE_URL` / `API_CHINA_BASE_URL` mặc định **rỗng** → mọi dịch vụ của tác giả đi vào nhánh "chưa cấu hình" có sẵn
    (cấu hình từ xa → giá trị mặc định, xác định vùng → theo hệ thống); `backendApiConfiguredProvider` để ẩn các lối vào
  - T6.1: chuyển giọng nói thành văn bản trên đám mây → **Whisper** bằng key người dùng (`OpenAiTranscriptionApiClient`: upload giả, gửi đồng bộ, verbose_json → câu + timestamp từng từ).
    Bản offline vẫn bị tác giả ẩn, nên giữ lại tính năng đám mây
  - T6.2 (**khác kế hoạch**): model/từ điển là gói do tác giả đóng gói, không có nguồn gốc tương đương → giữ CDN tác giả (chỉ file tĩnh công khai, lộ IP),
    nhưng cho cấu hình qua `MODEL_CDN_BASE_URL` + hướng dẫn tự host
  - T6.3: remote config dùng giá trị mặc định; T6.4: ẩn banner Khám phá tài nguyên, trang Podcast chỉ hiện gợi ý tìm/dán RSS,
    **đăng ký podcast không cần đăng nhập**; T6.5: ẩn "Kiểm tra cập nhật"; T6.6: Baidu (`cloudDriveImport`) mặc định tắt;
    link "Cộng đồng/Liên hệ" → trang GitHub mã nguồn mở
  - Test: cập nhật test có chủ đích (remote config default, endpoint router, settings icon), thêm test Whisper (5), podcast khách (1)
  - Kiểm tra mạng (emulator, cài mới bản prod): logcat của tiến trình app chỉ có `cdn.echo-loop.top`
    (gói phát âm); không có posthog/firebase/umeng/API tác giả. (Chưa dùng mitmproxy — cần cài CA trên emulator)

## Phase 7 — Hoàn thiện

- [P] **T7.1** Đổi `applicationId` (vd `com.<bạn>.echoloop`) + tên app để cài song song bản gốc
- [P] **T7.2** Tạo keystore riêng + `android/key.properties` (KHÔNG commit), build `--flavor prod`
- [P] **T7.3** Kiểm thử tổng: `flutter analyze`, `flutter test`, smoke test trên máy thật
- **Phase 7 hoàn thành: 2026-10-20**
  - T7.1: prod `applicationIdSuffix=".selfhost"` → `app.echoloop.selfhost`, tên "Echo Loop (SH)"
  - T7.2: keystore `android/app/selfhost-release.jks` + `android/key.properties` (mật khẩu ngẫu nhiên, đã ignore, SHA-256 F5:1E:…:8A:93) — **người dùng phải sao lưu**
  - T7.3: `flutter test` 5610 pass / 0 fail; APK prod 109.8MB, `apksigner` khớp chứng chỉ, không có AD_ID/BILLING; chạy được trên emulator (tiếng Việt)
- [P] **T7.4** Viết `docs/selfhost/README.md`: cách build, cách nhập key, giữ LICENSE gốc (AGPL-3.0 — nếu phân phối APK cho người khác phải công khai mã đã sửa)

## Phase 8 — Tiếng Việt (yêu cầu thêm 2026-10-20)

> Làm sau Phase 3 (cùng sửa file `.arb`), trước Phase 4. T8.4 gắn với Phase 4 (prompt AI).

- [P] **T8.1** Khảo sát mọi chỗ giả định `zh` / `zh-CN` (UI locale, native language, từ điển offline, prompt, TTS, sắp xếp/định dạng) → ghi `docs/selfhost/vietnamese.md`
  - Hoàn thành: 2026-10-20 — xem `docs/selfhost/vietnamese.md`
- [P] **T8.2** Giao diện tiếng Việt: `lib/l10n/app_vi.arb` dịch đủ mọi key (đối chiếu số key với `app_en.arb`),
  thêm `Locale('vi')` vào `supportedLocales` + `matchUiLocale` (máy tiếng Việt → UI tiếng Việt), thêm "Tiếng Việt" vào chọn App Language
- [P] **T8.3** Native language `vi`: thêm vào `supportedNativeLanguages`; không có từ điển offline Anh→Việt →
  ẩn/không tải từ điển local cho `vi`, mặc định dùng từ điển AI + thêm Cambridge English–Vietnamese vào từ điển web
- [P] **T8.4** Prompt AI (Phase 4) trả lời theo native language (vi / zh-CN / zh-TW)
- [P] **T8.5** 🎨 Design: dòng "Tiếng Việt" trong 2 màn chọn ngôn ngữ + trạng thái "không có từ điển offline" → tự duyệt
- Test phase: unit test `matchUiLocale` / `matchNativeLanguage` với `vi`/`vi-VN`; test số key `app_vi.arb` == `app_en.arb`;
  widget test chuyển sang tiếng Việt; emulator: đổi ngôn ngữ → UI tiếng Việt, tra từ không lỗi
- **Phase 8 hoàn thành: 2026-10-20**
  - `app_vi.arb`: 1655 key, dịch bằng 6 agent song song, kiểm tra tự động placeholder/ICU; design `docs/selfhost/design-vietnamese.md`
  - Native `vi`: không có từ điển offline → `DictionaryStatus.unavailable`, mặc định Local → AI, thêm nguồn web `cambridgeVi`
  - T8.4: prompt OpenAI dùng `aiLanguageName(targetLanguage)` (vi / zh-CN / zh-TW)
  - Test mới: `test/l10n/arb_parity_test.dart`, `dictionary_provider_vi_test.dart`, thêm case vi trong settings/visible sources/web dict
  - Emulator: đặt locale app = vi-VN → onboarding, trang chủ, Cài đặt hiển thị tiếng Việt; chọn native Tiếng Việt → từ điển mặc định "Từ điển AI"
  - Ghi nhận nhỏ: nút "Quay lại" ở onboarding bị xuống dòng (chữ tiếng Việt dài hơn), chưa sửa

---

## Phase 9 — Chọn model có danh sách + giá (yêu cầu thêm 2026-10-21) 🎨 UI

- [-] **T9.1–T9.4** Bỏ (2026-10-21): người dùng quyết định giữ ô Model nhập tay, mặc định `gpt-4.1-mini`.
  Lý do: các tính năng AI của app (dịch, phân tích, từ điển, cụm nghĩa, chat, chấm kể lại) không cần model reasoning;
  mọi model từ gpt-5 trở đi đều là reasoning → chậm hơn, tốn token suy nghĩ, và cần sửa tham số
  (bỏ `temperature`, thêm `reasoning_effort`) mới gọi được. Design tham khảo: `docs/selfhost/design-ai-model-picker.md`.
  **Lưu ý nếu tự nhập model gpt-5*/gpt-6*:** có thể lỗi 400 vì app vẫn gửi `temperature`.

## Phase 10 — Thông báo cập nhật trong app (yêu cầu thêm 2026-10-21) 🎨 UI

- [P] **T10.1** Android: kiểm tra bản mới qua GitHub Releases của fork (`api.github.com/repos/LampardNguyen/study-loop/releases/latest`)
  thay cho `version.json` của tác giả; hiện lại mục "Kiểm tra cập nhật" trong Cài đặt trên Android
  - Design tự duyệt: 2026-10-21 — dùng lại nguyên hộp thoại cập nhật và mục Cài đặt có sẵn của bản gốc, không thêm UI mới
  - Quy ước: tag Release `vX.Y.Z` = phần tên version trong `pubspec.yaml`; app so sánh tên version (không so build number);
    đính file `.apk` vào Release (không có thì mở trang Release); không có cập nhật bắt buộc
  - Hoàn thành: 2026-10-21
  - Test: `test/services/github_release_update_test.dart` (5 test) + `app_update_checker_test.dart`, `test/providers` → pass;
    `flutter analyze` các file đã sửa → 0 issue

## Phase 11 — Thông báo tiếng Việt, icon mèo, cài đặt ghi âm (yêu cầu thêm 2026-10-23)

> Người dùng yêu cầu: task 🎨 UI phải chờ người dùng **duyệt thật** (không tự duyệt). Mỗi task xong ghi vào `docs/selfhost/CHANGELOG.md`.

- [P] **T11.1** Thông báo nhắc ôn tập theo ngôn ngữ app (đang hardcode tiếng Trung trong `review_reminder_service.dart`):
  thêm chuỗi l10n en/zh/vi, đổi ngôn ngữ app → lên lịch lại thông báo
  - Hoàn thành: 2026-10-23 — 6 key mới `reviewReminder*`; service nhận `localizations` từ provider; `main_shell` nghe đổi locale → resync
  - Test: `flutter test test/services/review_reminder_service_test.dart test/l10n test/router` → pass; `flutter analyze` file sửa → 0 issue
- [P] **T11.2** Icon thanh thông báo: thông báo nhắc ôn tập đang dùng `@mipmap/ic_launcher` → dùng `ic_stat_logo` (mèo trắng)
  - Hoàn thành: 2026-10-23 — đã kiểm tra APK 1.0.42: `ic_stat_logo` (thông báo phát nhạc) đã là mèo; chỉ thông báo nhắc ôn tập dùng icon launcher
  - Test: assertion `defaultIcon == '@drawable/ic_stat_logo'` trong `review_reminder_service_test.dart` → pass
  - Bổ sung 2026-10-23 (theo ảnh chụp của người dùng): con vẹt là **ảnh bìa** thẻ phát nhạc — file cache
    `now_playing_artwork.png` chỉ ghi lần đầu nên còn ảnh vẹt từ bản cũ. Sửa: ghi lại khi kích thước khác asset
    (`background_audio_handler.dart`, `echo_loop_media_handler.dart`). Test: `flutter analyze` → 0 issue; chưa có unit test (cần giả lập thư mục dữ liệu app)
- [P] **T11.3** 🎨 Design: mục "Ghi âm" trong menu cá nhân (âm lượng ghi + chất lượng) → **chờ người dùng duyệt**
  - Design: `docs/selfhost/design-recording-settings.md` (2026-10-23)
  - Design duyệt: 2026-10-23 — chất lượng 3 mức 16 / 24 / 44.1 kHz, giữ nút Ghi thử 5 giây
- [P] **T11.4** Code cài đặt ghi âm theo design đã duyệt (Android `WavRecorder`: hệ số khuếch đại + tần số mẫu)
  - Hoàn thành: 2026-10-23 — `RecordingSettings` + `recordingSettingsNotifierProvider` (SharedPreferences); gửi `gain`/`sampleRate`
    trong `startSession`; `WavRecorder.configure` (24 kHz không hỗ trợ → 16 kHz), soft limiter `amplifySample`, ngưỡng cắt lặng theo gain;
    màn `RecordingSettingsScreen` + `RecordingTrial` (Ghi thử 5 giây)
  - Test: `recording_settings_provider_test` / `recording_trial_test` / `recording_settings_screen_test` + Kotlin `AmplifySampleTest` → pass;
    emulator Pixel 9 Pro: log native `AudioRecord ready rate=24000 gain=5.0`, ghi thử + phát lại OK, cài đặt giữ sau khi cài lại.
    Đã dừng `flutter test` toàn bộ theo yêu cầu người dùng (chưa chạy hết suite)

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
- 2026-10-20 **Sự cố (đã khắc phục)**: một vòng lặp `git diff --name-only | git checkout` bị hook `rtk` làm hỏng output → khôi phục nhầm
  toàn bộ file đã sửa trong `lib/` (chưa commit). Đã áp dụng lại từ lịch sử phiên và kiểm tra bằng test. Bài học: parse output git thì dùng `/usr/bin/git`

