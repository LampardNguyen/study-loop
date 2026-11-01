# Task index (Study Loop self-host)

Mỗi task 1 dòng.
Ký hiệu: `[ ]` chưa làm, `[~]` đang làm, `[D]` chờ duyệt design, `[x]` code xong chờ test, `[P]` pass, `[-]` bỏ.

- [P] T12.1 — Tải & cài bản cập nhật APK ngay trong app → [task-2026-10-26.md](task-2026-10-26.md#t121)
- [P] T12.2 — Đa ngôn ngữ cho menu Nhà phát triển → [task-2026-10-26.md](task-2026-10-26.md#t122)
- [P] T12.3 — Cắt đầu/cuối audio (bỏ quảng cáo) trước khi tạo phụ đề → [task-2026-10-27.md](task-2026-10-27.md#t123)
- [P] T13.1 — Design màn hình Đồng bộ Google Drive → [task-2026-10-28.md](task-2026-10-28.md#t131)
- [P] T13.2 — Đăng nhập Google + scope drive.appdata → [task-2026-10-28.md](task-2026-10-28.md#t132)
- [P] T13.3 — Sao lưu/Khôi phục Drive (dữ liệu + audio, không OpenAI key) → [task-2026-10-28.md](task-2026-10-28.md#t133)
- [P] T13.4 — Đổi package thành com.studyloop.app → [task-2026-10-28.md](task-2026-10-28.md#t134)
- [P] T13.5 — Nút "Sign in with Google" đúng hướng dẫn thương hiệu → [task-2026-10-28.md](task-2026-10-28.md#t135)
- [x] T13.6 — Publish OAuth Production: GitHub Pages + xác minh domain → [task-2026-10-28.md](task-2026-10-28.md#t136)
- [P] T14.1 — OpenAI speech client (synthesizeSpeech) → [task-2026-10-29.md](task-2026-10-29.md#t141)
- [P] T14.2 — Dialogue lesson builder (TTS từng câu → ghép → SRT) → [task-2026-10-29.md](task-2026-10-29.md#t142)
- [P] T14.3 — 🎨 UI tạo bài học từ hội thoại → [task-2026-10-29.md](task-2026-10-29.md#t143)
- [P] T14.4 — CHANGELOG + chạy thử end-to-end → [task-2026-10-29.md](task-2026-10-29.md#t144)
- [P] T14.5 — Tự hiện thông báo cập nhật khi khởi động lại app → [task-2026-10-29.md](task-2026-10-29.md#t145)
- [P] T14.6 — Bỏ sheet Google "Đang đăng nhập" khi vào tab Cá nhân → [task-2026-10-29.md](task-2026-10-29.md#t146)
- [P] T14.7 — 🎨 Nhãn nam/nữ cho giọng đọc → [task-2026-10-30.md](task-2026-10-30.md#t147)
- [P] T14.8 — 🎨 Nghe thử 2 câu đầu → [task-2026-10-30.md](task-2026-10-30.md#t148)
- [P] T14.9 — 🎨 Làm đẹp bố cục phần Giọng đọc → [task-2026-10-30.md](task-2026-10-30.md#t149)
- [P] T14.10 — 🎨 Chọn nguồn ghi âm (thiết bị / tai nghe) → [task-2026-10-31.md](task-2026-10-31.md#t1410)
- [x] T14.11 — Bỏ mục FAQ trong Cá nhân → [task-2026-10-31.md](task-2026-10-31.md#t1411)
- [x] T14.12 — Việt hoá "第 x/y 句" ở màn chi tiết câu → [task-2026-10-31.md](task-2026-10-31.md#t1412)
- [x] T14.13 — 🎨 Khôi phục Drive xong → khởi động lại app → [task-2026-10-31.md](task-2026-10-31.md#t1413)
- [x] T14.14 — 🎨 Báo có bản sao lưu Drive mới hơn từ máy khác → [task-2026-10-31.md](task-2026-10-31.md#t1414)
- [x] T14.15 — Xoá tính năng xuất PDF và font PDF → [task-2026-10-31.md](task-2026-10-31.md#t1415)
- [P] T15.1 — 🎨 Điều chỉnh âm lượng + chuẩn hoá trên trình phát → [task-2026-11-01.md](task-2026-11-01.md#t151)
- [P] T15.2 — Cân bằng độ lớn từng câu khi tạo bài hội thoại → [task-2026-11-01.md](task-2026-11-01.md#t152)
- [P] T15.3 — Sửa test router còn tham chiếu pdfPreviewSegment → [task-2026-11-01.md](task-2026-11-01.md#t153)
- [P] T15.4 — Kiểm tra host remote config, chặn khi không có backend → [task-2026-11-01.md](task-2026-11-01.md#t154)

## Quyết định
- 2026-10-26: Cập nhật APK tải trong app (Dio) + cài qua FileProvider; lỗi tải → mở trình duyệt như cũ.
- 2026-10-27: Cắt audio = cắt file vật lý bằng ffmpeg; bài đã có phụ đề thì xóa phụ đề khi cắt.
- 2026-10-28: Đồng bộ = chỉ Google, Drive appDataFolder, thủ công; không đồng bộ OpenAI key.
- 2026-10-28: Package mới com.studyloop.app (dev: com.studyloop.app.dev), giữ namespace Kotlin.
- 2026-10-29: Bài học từ hội thoại: OpenAI TTS dạng PCM từng câu, thời gian phụ đề tính theo byte.
- 2026-11-01: Âm lượng phát 50–200% + chuẩn hoá, cài đặt toàn cục; câu hội thoại chuẩn hoá RMS từng câu khi tạo.
- 2026-11-01: Remote config không gọi khi chưa cấu hình backend gốc; CDN model echo-loop.top giữ nguyên.
