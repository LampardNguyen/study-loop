# Study Loop — Privacy Policy / Chính sách quyền riêng tư

_Last updated / Cập nhật: 2026-10-28_

Study Loop is a personal, open-source English listening & speaking practice app
(source: https://github.com/LampardNguyen/study-loop). It has **no server of its own**
and contains **no analytics or tracking SDK**.

## English

### Data stored on your device
Your library (audio, video, subtitles), learning progress, saved words and app settings
are stored only on your device. Your OpenAI API key is stored in the device's secure storage
(Android Keystore) and never leaves the device except in requests you make to OpenAI.

### Google Sign-In and Google Drive
If you choose **Google Drive sync**, the app asks for your Google account's basic profile
(name, email, photo, used only to show which account is signed in) and the
`https://www.googleapis.com/auth/drive.appdata` permission. This permission lets the app
access **only its own hidden app-data folder** in your Google Drive; it cannot see or change
any other file in your Drive.

When you tap *Back up* or *Restore*, the app uploads to / downloads from that folder:
settings, learning progress, library metadata, subtitles and audio files.
**Your OpenAI API key is never uploaded.** Data goes directly between your device and
Google; the developer never receives it. Google's handling is described in the
[Google Privacy Policy](https://policies.google.com/privacy).

The app's use of information received from Google APIs adheres to the
[Google API Services User Data Policy](https://developers.google.com/terms/api-services-user-data-policy),
including the Limited Use requirements. Google user data is not sold, shared with third
parties, used for advertising, or used to train AI models.

### OpenAI
AI features (subtitles, explanations, speech) send the relevant audio or text directly
from your device to OpenAI using **your own** API key, under
[OpenAI's policies](https://openai.com/policies). No Google user data is sent to OpenAI.

### Deleting your data
- Sign out in *Settings → Google Drive sync*, or revoke access at
  https://myaccount.google.com/permissions.
- Delete the backup: Google Drive (web) → Settings → Manage apps → Study Loop →
  Options → *Delete hidden app data*.
- Uninstalling the app removes all local data.

### Contact
nguyenduylinh.lampard@gmail.com

## Tiếng Việt

Study Loop là app luyện nghe – nói tiếng Anh cá nhân, mã nguồn mở. App **không có server riêng**
và **không có SDK phân tích hay theo dõi người dùng**.

- **Trên máy:** thư viện bài học, tiến độ, từ đã lưu và cài đặt chỉ lưu trên máy.
  OpenAI API key lưu trong bộ nhớ bảo mật của máy.
- **Google Drive:** khi bạn dùng *Đồng bộ Google Drive*, app xin thông tin cơ bản của tài khoản
  (tên, email, ảnh — chỉ để hiển thị) và quyền `drive.appdata`. Quyền này **chỉ** cho app truy cập
  thư mục ẩn của chính nó trên Drive, không xem hay sửa được file nào khác.
  Khi sao lưu, app tải lên cài đặt, tiến độ học, danh sách bài, phụ đề và audio.
  **OpenAI key không bao giờ được tải lên.** Dữ liệu đi thẳng giữa máy bạn và Google;
  nhà phát triển không nhận được dữ liệu này.
- Dữ liệu người dùng Google không bị bán, chia sẻ cho bên thứ ba, dùng cho quảng cáo hay huấn luyện AI.
  App tuân thủ [Google API Services User Data Policy](https://developers.google.com/terms/api-services-user-data-policy),
  bao gồm yêu cầu Limited Use.
- **OpenAI:** các tính năng AI gửi audio/văn bản liên quan từ máy bạn thẳng tới OpenAI bằng key của chính bạn.
- **Xoá dữ liệu:**
  - Đăng xuất trong app, hoặc thu hồi quyền tại https://myaccount.google.com/permissions.
  - Xoá bản sao lưu: Drive → Cài đặt → Quản lý ứng dụng → Study Loop → *Xoá dữ liệu ứng dụng ẩn*.
  - Gỡ app sẽ xoá dữ liệu trên máy.
- **Liên hệ:** nguyenduylinh.lampard@gmail.com
