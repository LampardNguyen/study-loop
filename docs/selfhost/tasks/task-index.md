# Task index (Study Loop self-host)

Mỗi task 1 dòng.
Ký hiệu: `[ ]` chưa làm, `[~]` đang làm, `[D]` chờ duyệt design, `[x]` code xong chờ test, `[P]` pass, `[-]` bỏ.

- [P] T12.1 — Tải & cài bản cập nhật APK ngay trong app → [task-2026-10-26.md](task-2026-10-26.md#t121)
- [P] T12.2 — Đa ngôn ngữ cho menu Nhà phát triển → [task-2026-10-26.md](task-2026-10-26.md#t122)
- [P] T12.3 — Cắt đầu/cuối audio (bỏ quảng cáo) trước khi tạo phụ đề → [task-2026-10-27.md](task-2026-10-27.md#t123)

## Quyết định
- 2026-10-26: Cập nhật APK tải trong app (Dio) + cài qua FileProvider; lỗi tải → mở trình duyệt như cũ.
- 2026-10-27: Cắt audio = cắt file vật lý bằng ffmpeg; bài đã có phụ đề thì xóa phụ đề khi cắt.
