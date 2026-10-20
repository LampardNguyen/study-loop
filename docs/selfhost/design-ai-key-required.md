# Design T4.6 — Trạng thái "chưa cấu hình AI key"

> Trạng thái: **Design tự duyệt 2026-10-20** (chế độ tự chạy). Người dùng xem lại và yêu cầu sửa nếu cần.

Bản gốc: dùng AI khi chưa đăng nhập → hỏi "Đăng nhập". Bản tự host không cần đăng nhập;
điều kiện duy nhất là **đã nhập API key** trong Cài đặt → Cài đặt AI.

## 1. Hộp thoại chung (thay cho "Cần đăng nhập" ở chat, kể lại, giải thích câu)

```
┌───────────────────────────────────────────┐
│ Chưa cấu hình AI                          │
│                                           │
│ Thêm API key OpenAI (hoặc dịch vụ tương   │
│ thích) của bạn trong Cài đặt AI để dùng   │
│ các tính năng AI.                         │
│                                           │
│               [Hủy]   [ Mở Cài đặt AI ]   │
└───────────────────────────────────────────┘
```
- "Mở Cài đặt AI" → mở `AiSettingsScreen`. Quay lại mà **đã có key** → thao tác vừa bấm tiếp tục luôn (không phải bấm lại).

## 2. Tra từ bằng AI (tab "Từ điển AI") khi chưa có key

```
        Chưa cấu hình AI
  Thêm API key của bạn trong Cài đặt AI
  để dùng từ điển AI.
          [ Mở Cài đặt AI ]
```

## 3. Banner trong chat & bảng chấm bài kể lại

- Thay tiêu đề "Đăng nhập để …" bằng "Chưa cấu hình AI", nút "Đăng nhập" → "Mở Cài đặt AI".
- Key sai (OpenAI trả 401) dùng cùng trạng thái này: người dùng vào Cài đặt AI → Kiểm tra kết nối.
