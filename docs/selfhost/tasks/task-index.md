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

## Quyết định
- 2026-10-26: Cập nhật APK tải trong app (Dio) + cài qua FileProvider; lỗi tải → mở trình duyệt như cũ.
- 2026-10-27: Cắt audio = cắt file vật lý bằng ffmpeg; bài đã có phụ đề thì xóa phụ đề khi cắt.
- 2026-10-28: Đồng bộ = chỉ Google, Drive appDataFolder, thủ công; không đồng bộ OpenAI key.
- 2026-10-28: Package mới com.studyloop.app (dev: com.studyloop.app.dev), giữ namespace Kotlin.
