# Design T14.3 — Tạo bài học từ hội thoại (OpenAI TTS)

Mockup: [design-dialogue-tts.html](design-dialogue-tts.html)

## Vị trí
Import sheet hiện có (`lib/widgets/import_audio_sheet.dart`), màn **Chọn nguồn** thêm ô thứ 3 (sau "Tệp trên máy",
"Liên kết"): **💬 Hội thoại → giọng nói** — phụ đề "Dán hội thoại, AI đọc thành bài nghe". Bấm → step mới `dialogueTts`
(tiêu đề sheet: "Tạo từ hội thoại"). Không thêm route mới.

## Bố cục step `dialogueTts`
1. **Tên bài học** (TextField) — mặc định rỗng; khi bấm Tạo mà rỗng → dùng câu đầu (cắt 40 ký tự).
2. **Hội thoại** (TextField nhiều dòng, 8–14 dòng, có nút 📋 Dán) — gợi ý: `Mark: Hi Anna…` / `Anna: Hi, Doctor…`.
   Dưới ô: "50 câu · 2 người nói · 2.300 ký tự" (cập nhật khi gõ).
3. **Giọng đọc** — mỗi người nói 1 dòng: tên + dropdown giọng (alloy, ash, ballad, coral, echo, fable, nova, onyx,
   sage, shimmer). Mặc định theo thứ tự: ash, nova, onyx, shimmer.
4. **Chất lượng** (dropdown, mặc định *Tự nhiên — gpt-4o-mini-tts*; khác: *Tiêu chuẩn — tts-1*, *Cao — tts-1-hd*).
5. Dòng ước tính: "Ước tính ≈ $0.04 · ~3 phút audio" (ký tự × giá model; mini ≈ $0.000016/ký tự).
6. Nút **Tạo bài học** (vô hiệu khi < 1 câu hợp lệ).

Phụ đề: **chỉ câu thoại**, không kèm tên người nói (đề xuất — để luyện nghe/shadowing gọn). Câu > 4.000 ký tự → báo lỗi
ngay dưới ô hội thoại.

## Trạng thái
- **A. Rỗng**: ô trống, phần Giọng đọc ẩn, nút Tạo mờ, gợi ý định dạng.
- **B. Sẵn sàng**: có hội thoại → hiện người nói + giọng + ước tính; nút Tạo bật.
  Dòng không nhận ra người nói được nối vào câu trước (ghi chú nhỏ nếu có).
- **C. Đang tạo**: thanh tiến độ "Đang tạo giọng 12/50…" → "Đang ghép audio…"; nút **Huỷ** (hỏi lại không cần —
  huỷ ngay, xoá file tạm). Không đóng sheet bằng vuốt khi đang chạy (như luồng Liên kết).
- **D. Lỗi** (thẻ đỏ, giữ nguyên nội dung đã nhập, nút **Thử lại**):
  - Chưa có OpenAI key → mở `ai_key_required_dialog` (như các tính năng AI khác) thay vì thẻ lỗi.
  - Key sai (401) · Hết hạn mức / quá nhanh (429 sau khi đã thử lại) · Mất mạng · Ghép audio thất bại · Trùng bài.
- **E. Thành công**: dùng `_CompletedPanel` có sẵn ("Đã thêm 'Doctor visit' · 3:02 · 50 câu phụ đề") → Xong.

## Câu hỏi cho người duyệt
1. Phụ đề chỉ câu thoại (đề xuất) hay kèm `Mark:`?
2. Mặc định *gpt-4o-mini-tts* (đề xuất) hay *tts-1*?
3. Có cần ô "Phong cách đọc" (instructions, vd "chậm, rõ ràng cho người học") không? Đề xuất: **chưa** — để sau.
