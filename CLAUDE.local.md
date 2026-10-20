# CLAUDE.local.md — Dự án Self-host Echo Loop (ưu tiên cao hơn CLAUDE.md)

> File này do người dùng tạo cho dự án chuyển đổi riêng. Claude Code tự nạp file này mỗi session.
> Khi có xung đột với `CLAUDE.md` (của tác giả gốc), **file này thắng** ở các điểm dưới đây;
> các quy tắc kỹ thuật khác trong `CLAUDE.md` (kiến trúc Flutter, Riverpod, test, §7 Troubleshooting) vẫn áp dụng.

## 1. Bối cảnh

- Mã nguồn tải dạng zip từ repo gốc Echo Loop (AGPL-3.0).
- Mục tiêu: APK cá nhân không phụ thuộc server tác giả, không analytics,
  AI gọi thẳng OpenAI bằng **key người dùng nhập trong app** (không nhúng khi build).
- Danh sách task và tiến độ: **`SELFHOST_TASKS.md`** (nguồn sự thật duy nhất).
- `PLAN.md` / `TASKS.md` là của tác giả gốc — **chỉ đọc tham khảo, không sửa, không dùng làm danh sách việc**.

## 2. Bắt đầu mỗi session (bắt buộc)

1. Đọc `SELFHOST_TASKS.md`, tìm task đầu tiên chưa `[P]` / `[-]` (ưu tiên task đang `[~]` hoặc `[D]`).
2. Nói ngắn gọn bằng **tiếng Việt**: đã xong đến đâu, task tiếp theo là gì.
3. Nếu task đang `[D]` (chờ duyệt design) → hỏi người dùng đã approve chưa, **không code** khi chưa có approve.

## 3. Quy trình mỗi task

1. Đánh dấu `[~]`.
2. **Task 🎨 UI**: làm design trước (mockup bằng widget/HTML hoặc mô tả bố cục + trạng thái:
   rỗng / đang tải / lỗi / thành công) → đổi sang `[D]` → **dừng, chờ người dùng approve**.
   Chỉ code sau khi người dùng nói rõ là duyệt; ghi `Design duyệt: YYYY-MM-DD` dưới task.
3. Code (thay đổi tối thiểu, theo style hiện có) → đổi sang `[x]`.
4. Test: `flutter analyze`, test liên quan (`flutter test <file>`), viết test mới cho hành vi mới;
   build APK khi task đụng tới dependency/gradle/manifest.
5. Test OK → `[P]` + ghi `Hoàn thành: YYYY-MM-DD` và `Test: <lệnh — kết quả>`.
   Test fail → giữ `[x]`, ghi lỗi, sửa tiếp; **không sửa assertion cho xanh** nếu chưa rõ nguyên nhân (CLAUDE.md §7.29).
6. Quyết định quan trọng → ghi vào mục *Ghi chú / Quyết định* cuối `SELFHOST_TASKS.md`.
7. Mỗi task PASS → 1 git commit: `selfhost(T<x.y>): <mô tả>`.

## 4. Quy tắc bảo mật riêng

- **Không bao giờ** hardcode, log, commit, hay đưa vào `--dart-define` OpenAI API key.
- Key chỉ lưu bằng `flutter_secure_storage`; không vào SharedPreferences, backup, analytics, log, crash report.
- Không thêm SDK analytics/tracking mới.
- Không gửi request tới `echo-loop.top`, `echo-loop.cn`, posthog, firebase, umeng.
- `key.properties`, keystore, `.dev.env`, `.prod.env` không commit.

## 5. Lệnh hay dùng

```bash
flutter pub get && dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release --flavor dev
```

## 6. Ngôn ngữ

- Trao đổi với người dùng: tiếng Việt.
- Comment code: theo quy ước dự án (tiếng Trung, Dart doc) để đồng nhất với code gốc.
