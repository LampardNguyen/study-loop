# CLAUDE.local.md — Dự án Self-host Echo Loop (ưu tiên cao hơn CLAUDE.md)

> File này do người dùng tạo cho dự án chuyển đổi riêng. Claude Code tự nạp file này mỗi session.
> Khi có xung đột với `CLAUDE.md` (của tác giả gốc), **file này thắng** ở các điểm dưới đây;
> các quy tắc kỹ thuật khác trong `CLAUDE.md` (kiến trúc Flutter, Riverpod, test, §7 Troubleshooting) vẫn áp dụng.

## 1. Bối cảnh

- Mã nguồn tải dạng zip từ repo gốc Echo Loop (AGPL-3.0).
- Mục tiêu: APK cá nhân không phụ thuộc server tác giả, không analytics,
  AI gọi thẳng OpenAI bằng **key người dùng nhập trong app** (không nhúng khi build).
- Danh sách task và tiến độ: **`docs/selfhost/tasks/task-index.md`** (nguồn sự thật duy nhất), xem §2b.

## 2. Bắt đầu mỗi session (bắt buộc)

1. Chỉ đọc `docs/selfhost/tasks/task-index.md`, tìm task đầu tiên chưa `[P]` / `[-]` (ưu tiên `[~]` hoặc `[D]`).
   Chỉ mở file `task-<ngày>.md` của task cần làm — **không đọc các file task khác**.
2. Nói ngắn gọn bằng **tiếng Việt**: đã xong đến đâu, task tiếp theo là gì.
3. Nếu task đang `[D]` (chờ duyệt design) → hỏi người dùng đã approve chưa, **không code** khi chưa có approve.

## 2b. Tổ chức file task (người dùng chốt 2026-10-26)

- Thư mục: `docs/selfhost/tasks/`.
- **Mỗi lần tạo task mới** → tạo file `task-YYYY-MM-DD.md` (ngày tạo). Nhiều task cùng ngày thì ghi chung
  file của ngày đó. Nội dung mỗi task: mã `T<x.y>`, trạng thái, mô tả, tiêu chí xong, rồi
  `Design duyệt:` / `Hoàn thành:` / `Test:` khi có.
- **`task-index.md`**: mỗi task 1 dòng, trỏ tới file chi tiết, vd:
  `- [P] T12.3 — Sửa lỗi phát audio → [task-2026-10-26.md](task-2026-10-26.md#t123)`
- Mọi thay đổi trạng thái phải cập nhật **cả** file task lẫn dòng tương ứng trong `task-index.md`.
- Ký hiệu: `[ ]` chưa làm, `[~]` đang làm, `[D]` chờ duyệt design, `[x]` code xong chờ test, `[P]` pass, `[-]` bỏ.
- Quyết định quan trọng ghi vào mục *Ghi chú / Quyết định* cuối file task của ngày đó, và 1 dòng tóm tắt
  ở mục *Quyết định* cuối `task-index.md`.

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
6. Quyết định quan trọng → ghi theo §2b.
7. Mỗi task PASS → 1 git commit: `selfhost(T<x.y>): <mô tả>`.

## 3b. Quy tắc bắt buộc (người dùng chốt 2026-10-23)

1. **Task** = yêu cầu làm liên quan đến **ứng dụng** (tính năng, sửa lỗi, UI, build/phát hành app).
   Task phải ghi vào file task theo §2b (+ `task-index.md`) trước khi làm; làm xong + test OK thì đánh dấu
   `[P]` kèm `Hoàn thành:` / `Test:`. Việc lặt vặt không đụng tới app (dịch/sửa tài liệu hướng dẫn, file CLAUDE*,
   trả lời câu hỏi, thao tác git…) **không phải task**, không cần ghi vào file task.
2. **UI**: làm design (lưu `docs/selfhost/design-*.md` + mockup) → `[D]` → **dừng, chờ người dùng approve**.
   Không tự duyệt. Chế độ tự chạy/tự duyệt design trước đây (từ 2026-10-20) đã **bỏ**.
3. **Changelog**: mọi sửa/thêm có ảnh hưởng người dùng phải ghi vào `docs/selfhost/CHANGELOG.md`
   ngay khi task xong (mục `## Chưa phát hành`, nhóm *Tính năng mới* / *Sửa lỗi*), dùng làm ghi chú release tag.
4. **Build bản phát hành**: luôn dựa vào `version` trong `pubspec.yaml` — **tăng version trước khi build**
   (tăng cả tên version và số build, vd `1.0.43+8` → `1.0.44+9`), đổi tiêu đề `## Chưa phát hành` trong
   CHANGELOG thành `## vX.Y.Z (build N) — YYYY-MM-DD`; tag release = `vX.Y.Z`.

## 3c. Tiết kiệm token (người dùng chốt 2026-10-23)

- Yêu cầu đơn giản (dịch, sửa vài dòng, hỏi đáp, thao tác git…): làm trực tiếp, **không tạo agent**,
  không chia bước, không thêm kiểm tra/xác minh mà người dùng không yêu cầu.
- Không suy nghĩ/lập kế hoạch dài dòng cho việc nhỏ; không hỏi lại khi đã có cách làm hợp lý.
- Chỉ dùng agent khi việc thật sự lớn và người dùng đồng ý.

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
