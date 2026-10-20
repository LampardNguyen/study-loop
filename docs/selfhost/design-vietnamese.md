# Design T8.5 — Tiếng Việt trong chọn ngôn ngữ + trạng thái "không có từ điển offline"

> Trạng thái: **Design tự duyệt 2026-10-20** (chế độ tự chạy). Người dùng xem lại và yêu cầu sửa nếu cần.

## 1. Cài đặt → App Language (dialog có sẵn, thêm 1 dòng cuối)

```
  ○  Follow System
  ○  🇺🇸  English
  ○  🇨🇳  简体中文
  ●  🇻🇳  Tiếng Việt        ← mới
```
Dòng tóm tắt ở Cài đặt hiện "Tiếng Việt". Máy để tiếng Việt + "Follow System" → giao diện tự sang tiếng Việt.

## 2. Cài đặt → Native Language (dialog có sẵn, sinh từ `supportedNativeLanguages`)

```
  ○  简体中文
  ○  繁體中文
  ●  Tiếng Việt              ← mới
```

## 3. Từ điển khi native language = Tiếng Việt

- Không có từ điển offline Anh→Việt: tab "Local Dictionary" hiện thông báo, **không có nút Tải**:
  ```
        Chưa có từ điển offline cho ngôn ngữ mẹ đẻ của bạn.
        Hãy dùng từ điển AI hoặc từ điển web.
  ```
- Nguồn mặc định đang là "Local" → tự dùng **AI** (không đổi cài đặt đã lưu; quay về tiếng Trung là lại dùng Local).
- Thêm nguồn web **Cambridge EN–VI** (`dictionary.cambridge.org/dictionary/english-vietnamese/<từ>`) ngay sau Cambridge, có thể tắt trong Dictionary Settings.
