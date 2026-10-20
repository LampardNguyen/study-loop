# Design T3.1 — Màn hình "Cấu hình AI"

> Trạng thái: **Design tự duyệt 2026-10-20** (chế độ tự chạy). Người dùng xem lại và yêu cầu sửa nếu cần.
> Ngôn ngữ UI: en / zh như phần còn lại của app (app chưa có tiếng Việt).

## 1. Lối vào trong Cài đặt

Thêm 1 dòng **đầu tiên** trong nhóm *Learning* (cạnh các mục cài đặt engine khác: Speech Recognition, TTS…):

```
Learning
┌──────────────────────────────────────────────────────┐
│ ✨  AI Settings                  Not configured   ›  │   ← chưa có key (chữ màu error)
│ ✨  AI Settings                  gpt-4.1-mini     ›  │   ← đã có key (hiện model)
│ 🔔  Review Reminder                      20:00    ›  │
│ ...                                                  │
```

- Icon: `Icons.auto_awesome_outlined` (Material, không cần asset mới).
- Bấm → push `AiSettingsScreen` (cùng kiểu `MaterialPageRoute` như các mục Cài đặt khác).

## 2. Màn hình AiSettingsScreen

```
←  AI Settings
────────────────────────────────────────────────────────
  Echo Loop gọi thẳng tới nhà cung cấp AI bằng key của bạn.
  Key chỉ lưu trên thiết bị này (bộ nhớ an toàn của hệ điều hành)
  và không bao giờ được gửi đi nơi nào khác.

  ┌────────────────────────────────────────────────────┐
  │ API Key                                            │
  │ ┌────────────────────────────────────────────┐ 👁  │
  │ │ sk-••••••••••••••••••••••••••••••••4f2a   │      │
  │ └────────────────────────────────────────────┘      │
  │                                                    │
  │ Base URL                                           │
  │ ┌────────────────────────────────────────────┐      │
  │ │ https://api.openai.com/v1                  │      │
  │ └────────────────────────────────────────────┘      │
  │ OpenAI-compatible endpoint (OpenAI, OpenRouter,    │
  │ local server…)                                     │
  │                                                    │
  │ Model                                              │
  │ ┌────────────────────────────────────────────┐      │
  │ │ gpt-4.1-mini                               │      │
  │ └────────────────────────────────────────────┘      │
  └────────────────────────────────────────────────────┘

  [ Test connection ]            [  Save  ]   ← FilledButton

  ✅ Connected — 42 models available             ← kết quả test
  ❌ Invalid API key (401)
  ❌ Cannot reach server: <lỗi ngắn>

  ─────────────────────────────────────────────
  🗑  Remove API key                    (TextButton màu error,
                                         có dialog xác nhận)
```

### Hành vi

| Thành phần | Hành vi |
|---|---|
| API Key | `obscureText` mặc định; nút 👁 bật/tắt hiện. Khi đã lưu: ô hiện placeholder `sk-••••4f2a` (4 ký tự cuối), **không** nạp key thật vào ô; gõ mới = thay key |
| Base URL | Mặc định `https://api.openai.com/v1`; bỏ `/` cuối khi lưu; phải bắt đầu `https://` (cho phép `http://` chỉ với localhost/IP LAN) |
| Model | Text tự do, mặc định `gpt-4.1-mini` |
| Save | Validate → lưu → SnackBar "Saved"; nút disable khi chưa có thay đổi |
| Test connection | Dùng giá trị **đang nhập** (chưa cần Save): `GET {baseUrl}/models` với header `Authorization: Bearer <key>`, timeout 15s; trong lúc chạy hiện spinner trên nút |
| Remove API key | Dialog xác nhận → xoá key khỏi secure storage (giữ Base URL / Model) |

### Trạng thái cần thiết kế

- **Chưa cấu hình**: ô key trống, hint `sk-...`; dòng ở Cài đặt hiện "Not configured".
- **Đang tải** cấu hình từ secure storage: `LinearProgressIndicator` trên đầu form.
- **Lỗi đọc secure storage**: banner lỗi + cho phép nhập lại.
- **Đang test**: spinner, nút Test disable.
- **Test OK / lỗi**: dòng kết quả ngay dưới 2 nút (màu primary / error).

## 3. Bảo mật (bắt buộc)

- Key lưu bằng `flutter_secure_storage` (Android Keystore / iOS Keychain). Base URL + model cũng lưu ở đó cho gọn (không nhạy cảm nhưng một nguồn).
- Không log key; log chỉ ghi `hasKey=true/false`, `baseUrlHost=api.openai.com`.
- Không đưa vào backup (`backup_service.dart` chỉ backup DB + prefs — kiểm tra ở T3.5).
- Không có `--dart-define` nào cho key.
