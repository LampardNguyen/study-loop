# Cấu hình đăng nhập Google + Đồng bộ Google Drive

Hướng dẫn này ghi lại đúng các bước đã làm cho project `study loop` (2026-10-28).
Làm lại khi: tạo project Google Cloud mới, đổi package, đổi keystore ký app.

## Tổng quan

| Thành phần | Giá trị đang dùng | Ghi chú |
|---|---|---|
| Project Google Cloud | `study loop` (`study-loop-513014`) | |
| API | Google Drive API | |
| Scope | `https://www.googleapis.com/auth/drive.appdata` | Chỉ đọc/ghi thư mục ẩn của app, không thấy file khác của người dùng |
| Package prod | `com.studyloop.app` | Ký bằng keystore release (`android/key.properties`) |
| Package dev | `com.studyloop.app.dev` | Ký bằng debug keystore `~/.android/debug.keystore` |
| Web Client ID | lưu trong `.prod.env` / `.dev.env` | Không commit, không nằm trong code |

**Không có secret nào trong code.** Android xác thực app bằng cặp *package + SHA-1*.
App chỉ cần **Web Client ID** (thông tin công khai, không phải mật khẩu). Client ID này được
truyền vào lúc build qua `--dart-define-from-file`. Thư viện `google_sign_in` trên Android **bắt buộc**
có giá trị này (`serverClientId`), kể cả khi app không có server.
Client secret của Web client **không dùng**, đừng lưu ở đâu cả.

---

## Bước 0 — Lấy SHA-1 của các keystore

SHA-1 phải là của đúng keystore đã ký APK. Ký sai keystore thì đăng nhập báo lỗi `DEVELOPER_ERROR` / code 10.

**Release (prod)**: đường dẫn, alias và mật khẩu nằm trong `android/key.properties`. Đường dẫn `storeFile` là tương đối so với `android/app/`.
```bash
cd android/app
keytool -list -v -keystore <storeFile> -alias <keyAlias>
```
Nhập `storePassword` khi được hỏi, rồi chép dòng `SHA1:`.

**Cách chắc chắn nhất (dùng cho cả dev lẫn prod)**: đọc SHA-1 trực tiếp từ file APK đã build.
```bash
$(ls -d ~/Library/Android/sdk/build-tools/*/ | tail -1)apksigner verify --print-certs build/app/outputs/flutter-apk/app-dev-release.apk
```
Lệnh in ra dòng `SHA-1 digest: 7844a1…`. Viết hoa và chèn dấu `:` sau mỗi 2 ký tự khi nhập vào Google Cloud.

> ⚠️ Bản dev được Gradle ký bằng debug keystore của Gradle. Keystore này **không phải**
> `~/.android/debug.keystore` trên máy này. Lần đầu tôi lấy SHA-1 từ file đó, kết quả bị sai
> và đăng nhập báo `[16] Account reauth failed`. Vì vậy luôn kiểm tra bằng `apksigner` như trên.

SHA-1 hiện tại:
- release: `A0:88:78:80:32:CC:6F:27:D2:3F:A6:16:52:C4:D3:3B:29:F1:B6:33`
- dev (máy Mac đang build, đọc từ APK): `78:44:A1:02:25:78:64:AD:0F:BB:88:DA:E5:98:55:C4:A9:62:10:F1`

> Mỗi máy có debug keystore riêng. Build bản dev trên máy khác thì phải thêm SHA-1 của máy đó vào client Android dev.

## Bước 1 — Tạo project và bật Google Drive API

1. Mở https://console.cloud.google.com, chọn **Select a project → New project**, đặt tên (vd `study loop`), bấm **Create**.
2. Chọn project vừa tạo ở thanh trên cùng.
3. Vào **APIs & Services → Library**, tìm **Google Drive API**, bấm **Enable**.

## Bước 2 — Cấu hình Google Auth Platform (màn đồng ý OAuth)

Vào **Google Auth Platform → Overview** (https://console.cloud.google.com/auth/overview), bấm **Get started**:

1. **App Information**
   - App name: `Study Loop`
   - User support email: chọn email của bạn
   - Bấm **Next**
2. **Audience**: chọn **External**, bấm **Next**.
   (*Internal* chỉ dùng được với tài khoản Google Workspace của tổ chức.)
3. **Contact Information**: nhập email của bạn, bấm Enter để thành thẻ, rồi bấm **Next**.
4. **Finish**: tích ô *I agree to the Google API Services: User Data Policy*, bấm **Continue** rồi **Create**.

## Bước 3 — Thêm test user

App ở trạng thái **Testing**: chỉ test user mới đăng nhập được. Đổi lại, Google không cần duyệt app (tối đa 100 user).

1. Vào **Google Auth Platform → Audience**.
2. Ở mục **Test users**, bấm **+ Add users**.
3. Nhập email Google sẽ dùng trong app, bấm Enter, rồi bấm **Save**.

> Không cần bấm *Publish app*. Nếu publish sang Production thì scope `drive.appdata` (non-sensitive) vẫn không cần xác minh, nhưng phải có thêm trang chính sách quyền riêng tư.

### (Tuỳ chọn) Publish sang Production
Làm khi muốn người ngoài danh sách test user cũng đăng nhập được:
1. Commit và push file [docs/privacy-policy.md](../privacy-policy.md). URL công khai sẽ là
   `https://github.com/LampardNguyen/study-loop/blob/main/docs/privacy-policy.md`.
2. Vào **Google Auth Platform → Branding** và điền:
   - **Application home page**: `https://github.com/LampardNguyen/study-loop`
   - **Application privacy policy link**: URL ở bước 1
   - Bấm **Save**.
3. Vào **Audience** và bấm **Publish app**. Scope `drive.appdata` là non-sensitive nên không cần Google xác minh.
   Nếu sau này đổi logo hoặc thêm scope khác, Google có thể yêu cầu xác minh thương hiệu.

## Bước 4 — Khai báo scope Drive

1. Vào **Google Auth Platform → Data Access**, bấm **Add or remove scopes**.
2. Kéo xuống mục **Manually add scopes** và nhập:
   ```
   https://www.googleapis.com/auth/drive.appdata
   ```
3. Bấm **Add to table**, rồi bấm **Update**.
4. Kiểm tra scope đã nằm trong bảng **Your non-sensitive scopes**, rồi bấm **Save** ở cuối trang.

## Bước 5 — Tạo 3 OAuth client

Vào **Google Auth Platform → Clients → + Create client**. Mỗi client tạo một lần:

| # | Application type | Name | Package name | SHA-1 |
|---|---|---|---|---|
| 1 | Android | `Study Loop Android (prod)` | `com.studyloop.app` | SHA-1 release |
| 2 | Android | `Study Loop Android (dev)` | `com.studyloop.app.dev` | SHA-1 của APK dev |
| 3 | Web application | `Study Loop Web (server client)` | — | — (không cần redirect URI / JS origin) |

- Với client Android, bấm **Create** rồi bấm **OK**. Client ID của client Android không cần dùng trong app.
- Với client Web, bấm **Create** rồi chép **Client ID** (dạng `xxxx-yyyy.apps.googleusercontent.com`). **Không** chép client secret.
- Ghi chú: thay đổi có thể mất **5 phút đến vài giờ** mới có hiệu lực.

## Bước 6 — Đưa Web Client ID vào bản build

Tạo `.prod.env` và `.dev.env` ở thư mục gốc repo. Cả hai đã nằm trong `.gitignore`. Thêm dòng:
```
GOOGLE_WEB_CLIENT_ID=xxxx-yyyy.apps.googleusercontent.com
```
Nếu cần thêm biến khác, xem mẫu `.dev.env.template`.

Build:
```bash
flutter build apk --release --flavor dev --target-platform android-arm64 --dart-define-from-file=.dev.env
```
```bash
flutter build apk --release --flavor prod --target-platform android-arm64 --dart-define-from-file=.prod.env
```
Nếu build **thiếu** `--dart-define-from-file`, app vẫn chạy bình thường, nhưng màn Đồng bộ sẽ báo
"Bản build này chưa cấu hình đăng nhập Google (GOOGLE_WEB_CLIENT_ID)".

## Bước 7 — Kiểm tra trong app

1. Mở **Cài đặt → Lưu trữ → Đồng bộ Google Drive**, bấm **Đăng nhập bằng Google**, chọn tài khoản test user, rồi cho phép quyền Drive.
2. Bấm **Sao lưu ngay**. Thẻ "Lần sao lưu gần nhất" phải hiện ngày giờ, số file và dung lượng.
3. Thử khôi phục: xoá dữ liệu app (hoặc cài trên máy khác), đăng nhập, rồi bấm **Khôi phục từ Drive**.
4. Kiểm tra lại tiến độ học, podcast, phụ đề và audio. Riêng **OpenAI key** sẽ không có trên máy mới (phải nhập lại), và trên máy cũ thì giữ nguyên.

Thử trên emulator: cần image **Google Play** (có Play Store) và đã đăng nhập tài khoản Google trong
*Settings → Accounts* của emulator. Image chỉ có "Google APIs" có thể không hỗ trợ Credential Manager.

## Lỗi thường gặp

| Hiện tượng | Nguyên nhân / cách sửa |
|---|---|
| "chưa cấu hình đăng nhập Google" | Build thiếu `--dart-define-from-file`, hoặc trong file `.env` chưa có `GOOGLE_WEB_CLIENT_ID` |
| `DEVELOPER_ERROR` / code 10, `[16] Account reauth failed`, hoặc đăng nhập đóng ngay sau khi chọn tài khoản | Package hoặc SHA-1 của client Android không khớp với APK. Kiểm tra bằng `keytool` (bước 0) và `aapt dump badging <apk>`; đợi vài phút sau khi sửa |
| "Access blocked: app has not completed verification" / `access_denied` | Email chưa có trong **Test users** (bước 3) |
| Đăng nhập được nhưng sao lưu báo "Phiên Google đã hết hạn" | Chưa cho phép quyền Drive, hoặc scope chưa được khai báo (bước 4). Đăng xuất rồi đăng nhập lại |
| Lỗi 403 `accessNotConfigured` | Chưa bật Google Drive API (bước 1) |
| "Google Drive đã hết dung lượng" | Dung lượng Drive của tài khoản đã đầy |

## Dữ liệu trên Drive

Dữ liệu nằm trong thư mục ẩn **appDataFolder**, không hiện trong giao diện Drive. Muốn xem dung lượng hoặc xoá:
Drive (web) → ⚙ **Cài đặt → Quản lý ứng dụng → Study Loop → Tuỳ chọn → Xoá dữ liệu ứng dụng ẩn**.

- `backup.zip` — DB và cài đặt (không có audio, không có OpenAI key).
- `backup-index.json` — danh sách audio/phụ đề kèm sha256, dùng để đối chiếu với `backup.zip`.
- `media-<sha256>` — từng file audio hoặc phụ đề. File trùng nội dung chỉ lưu 1 bản; file không còn dùng sẽ bị xoá ở lần sao lưu sau.
