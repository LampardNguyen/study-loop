# Study Loop — bản tự host

Bản này được sửa từ mã nguồn gốc Echo Loop (AGPL-3.0). Mục tiêu là **không phụ thuộc server của tác giả** và **không có analytics**.
AI dùng **API key OpenAI (hoặc dịch vụ tương thích) của chính bạn**, nhập trong app.

## 1. Đã thay đổi gì

| Hạng mục | Bản gốc | Bản tự host |
|---|---|---|
| Analytics | PostHog (iOS có Session Replay), Firebase, Umeng | **Đã gỡ.** Chỉ ghi log trên máy (`LogOnlyChannel`) |
| Quyền Android | AD_ID, BILLING | Đã gỡ |
| Thanh toán / Pro | RevenueCat, Paddle, StoreKit | Đã gỡ. **Mở khoá toàn bộ** tính năng |
| Tính năng AI (dịch, giải thích câu, từ điển AI, cụm nghĩa, chat, chấm bài kể lại) | Server tác giả | Gọi thẳng `chat/completions` bằng key của bạn |
| Chuyển giọng nói thành văn bản (phụ đề AI) | Upload lên R2 và server tác giả | Gửi thẳng lên `audio/transcriptions` (Whisper) bằng key của bạn |
| Đăng nhập | Supabase của tác giả | Mặc định **chế độ khách** (ẩn Tài khoản). Có thể bật lại bằng Supabase riêng |
| Cấu hình từ xa, podcast nổi bật, bộ sưu tập cộng đồng, kiểm tra cập nhật, xác định vùng, Baidu Netdisk | Server tác giả | Tắt (`API_BASE_URL` để trống). Dùng giá trị mặc định trên máy |
| Đăng ký Podcast | Bắt đăng nhập | Không cần đăng nhập. Tìm qua iTunes Search và đọc RSS trực tiếp |
| Ngôn ngữ | en / zh | **Thêm tiếng Việt** (giao diện + ngôn ngữ mẹ đẻ) |
| Package / tên app (prod) | `app.echoloop` / "Echo Loop" | `app.echoloop.selfhost` / "Study Loop", cài song song được với bản gốc |

**Vẫn còn kết nối ra ngoài** (không mang dữ liệu cá nhân, chỉ lộ địa chỉ IP):

- `cdn.echo-loop.top`: tải các file **tĩnh công khai** như model nhận dạng giọng nói / đọc văn bản, từ điển offline Anh→Trung, thư viện phát âm.
Bạn có thể tự host (xem mục 5).
- Các từ điển web (Cambridge, Oxford, …): mở trong WebView khi bạn chọn.
- iTunes Search API: khi tìm podcast.
- Địa chỉ AI bạn nhập (mặc định `api.openai.com`): chỉ khi dùng tính năng AI.

## 2. Build

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
flutter pub get
flutter build apk --release --flavor prod
```

File APK nằm ở `build/app/outputs/flutter-apk/app-prod-release.apk`, được ký bằng keystore riêng (xem mục 4).
Bản `--flavor dev` ký bằng debug key, package `app.echoloop.dev`.

**Cập nhật bản mới**: số build nằm trong `pubspec.yaml`, dòng `version: 1.0.42+7` (phần sau dấu `+`).
Android chỉ cho cài đè khi số build lớn hơn bản đang cài, nên **trước mỗi lần phát hành, tăng `+N` lên 1 rồi commit**
(ví dụ `+7` → `+8`), sau đó build bình thường, không cần `--build-number`. Không bao giờ giảm số này.

Có thể truyền thêm các biến lúc build (tuỳ chọn):

| Biến | Ý nghĩa |
|---|---|
| `MODEL_CDN_BASE_URL` | CDN riêng cho model và từ điển (mặc định là CDN của tác giả) |
| `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_WEB_CLIENT_ID` | Bật đăng nhập bằng Supabase của bạn |
| `API_BASE_URL` | **Để trống.** Chỉ điền nếu bạn tự viết backend tương thích với server tác giả |

Ví dụ: `flutter build apk --release --flavor prod --dart-define-from-file=.prod.env` (file `.prod.env` đã có trong `.gitignore`).

## 3. Nhập API key

Mở **Cá nhân → Cài đặt → Cài đặt AI**:

1. **API Key**: `sk-...` (lưu trong Android Keystore, không bao giờ ghi vào log hay bản sao lưu).
2. **Base URL**: mặc định `https://api.openai.com/v1`. Có thể dùng dịch vụ tương thích OpenAI như OpenRouter, hay server trên máy hoặc trong mạng LAN (`http://` chỉ cho phép localhost / LAN).
3. **Model**: mặc định `gpt-4.1-mini`.
4. Bấm **Kiểm tra kết nối** → **Lưu**.

Chuyển giọng nói thành văn bản dùng model `whisper-1` trên cùng Base URL và key. Dịch vụ của bạn phải hỗ trợ `audio/transcriptions`.

### Checklist tự thử với key thật (chưa được test tự động)

- [x] Cài đặt AI → Kiểm tra kết nối báo "Đã kết nối"
- [x] Mở một bài học → bấm **Dịch** một câu → bản dịch hiện dần, bằng ngôn ngữ mẹ đẻ
- [x] **Phân tích** câu → có mục ngữ pháp / từ vựng / nghe
- [x] **Cụm nghĩa** → câu được chia thành các cụm
- [x] Bôi đen một từ → **Từ điển AI** hiện phiên âm, nghĩa, ví dụ
- [x] Bôi đen nhiều từ (cụm) → từ điển AI cho cụm từ
- [x] **Chat AI** về câu đang học
- [x] **Kể lại** → ghi âm → chấm bằng AI (Whisper + chat)
- [x] Quản lý phụ đề → **Phiên âm đám mây** cho một file audio ngắn (dưới 30 phút / 25MB)
- [x] Nhập key sai → thông báo "Chưa cấu hình AI" và có nút mở Cài đặt AI

## 4. Keystore: **phải sao lưu**

- File: `android/app/selfhost-release.jks`, mật khẩu nằm trong `android/key.properties`. Cả hai **không được commit**.
- **Mất keystore thì không thể cài bản cập nhật đè lên bản cũ** (phải gỡ app và mất dữ liệu). Hãy chép cả 2 file vào nơi an toàn, ví dụ password manager hoặc ổ mã hoá.
- SHA-256 của chứng chỉ: `F5:1E:E8:E3:62:1D:39:DF:54:A0:B7:01:8B:C7:FC:23:B7:FA:1B:07:28:9F:C4:2F:5B:8E:25:9A:09:2A:8A:93`

## 4b. Phát hành bản mới (GitHub Release + thông báo cập nhật trong app)

App Android tự kiểm tra **Release mới nhất** của repo `LampardNguyen/study-loop` khi mở app (hoặc bấm
**Cài đặt → Kiểm tra cập nhật**). Nếu tag mới hơn bản đang cài thì hiện hộp thoại "Có bản mới" kèm mô tả Release;
bấm cập nhật thì trình duyệt tải APK, Android hỏi cài đè, dữ liệu giữ nguyên.

Mỗi lần phát hành:

1. Sửa `pubspec.yaml`, tăng **cả hai phần**: `version: 1.0.42+7` → `1.0.43+8`
   (tên version để app so sánh, số build để Android cho cài đè). Commit rồi `git push`.
2. Build: `flutter build apk --release --flavor prod`.
3. Vào https://github.com/LampardNguyen/study-loop/releases/new:
   - **Tag**: `v1.0.43` (đúng bằng tên version), chọn *Create new tag*, target `main`.
   - **Title**: `Study Loop 1.0.43`; **Description**: ghi thay đổi (hiện trong hộp thoại cập nhật).
   - Kéo file `build/app/outputs/flutter-apk/app-prod-release.apk` vào (nên đổi tên `study-loop-1.0.43.apk`, phải đuôi `.apk`).
   - Không chọn *pre-release*, giữ *Set as the latest release* → **Publish release**.
4. Gửi bạn bè link https://github.com/LampardNguyen/study-loop/releases/latest (lần đầu); những lần sau app tự báo.

**Không thấy thông báo?** Kiểm tra: tag có lớn hơn bản đang cài không; Release có phải *latest* (không phải
pre-release/draft) không; có đính file `.apk` không. Bản cài trước build 7 không có tính năng này.

## 5. Tự host CDN model (tuỳ chọn)

1. Tải các file mà app cần từ `https://cdn.echo-loop.top/...`, giữ nguyên đường dẫn

   (xem `lib/services/dictionary/dictionary_catalog.dart`, `scripts/piper_tts_models.manifest.txt`, `scripts/upload_asr_models_to_r2.sh`).
2. Upload lên R2 / S3 / GitHub Pages với **cùng cấu trúc thư mục**.
3. Build với `--dart-define=MODEL_CDN_BASE_URL=https://cdn.cua-ban.example`.

## 6. Đăng nhập bằng Supabase riêng (tuỳ chọn)

1. Tạo project Supabase và bật nhà cung cấp đăng nhập (Email, Google, Apple).
2. Điền `SUPABASE_URL` và `SUPABASE_PUBLISHABLE_KEY` (và `GOOGLE_WEB_CLIENT_ID` nếu dùng Google) vào `.prod.env`.
3. Build lại → mục **Tài khoản** sẽ hiện lại. Đăng nhập **không bắt buộc** để dùng AI.

## 7. Giới hạn đã biết

- Phiên âm đám mây giới hạn 30 phút và 25MB mỗi file (giới hạn của Whisper). File dài hơn sẽ được nén. Nếu vẫn quá lớn thì báo lỗi.
- Chuyển giọng nói thành văn bản offline vẫn đang bị tác giả gốc ẩn (do chất lượng chưa ổn định).
- Không có từ điển offline Anh→Việt. Khi ngôn ngữ mẹ đẻ là tiếng Việt, app dùng từ điển AI hoặc Cambridge EN–VI.
- Bản tiếng Việt do AI dịch: có thể còn vài chữ chưa tự nhiên, và nút "Quay lại" ở onboarding bị xuống dòng.

## 8. Giấy phép

Mã nguồn gốc theo **AGPL-3.0** (`LICENSE`). Dùng cá nhân thì không có ràng buộc gì thêm. Nếu **phân phối APK cho người khác**,
bạn phải công khai mã nguồn đã sửa theo AGPL.
