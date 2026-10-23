# Design T11.3 — Cài đặt ghi âm (chờ người dùng duyệt)

## Hiện trạng (Android `WavRecorder.kt`)
- Nguồn mic `VOICE_RECOGNITION`, 16 kHz, mono, 16-bit, **hệ số khuếch đại cố định ×2.2**, không chống vỡ tiếng.
- Kết quả: giọng nói nhỏ khi phát lại, nhất là khi để điện thoại xa miệng.

## Vị trí
Cài đặt → nhóm **Học tập** → dòng mới **"Ghi âm"** ngay dưới "Nhận dạng giọng nói" (chỉ hiện trên Android).
Phụ đề dòng: tóm tắt lựa chọn hiện tại, ví dụ `To · Chất lượng cao`.

## Màn "Cài đặt ghi âm"
1. **Âm lượng ghi âm** (chọn 1 trong 4, có ✓):
   - Nhỏ (×1.5) — khi nói gần mic / môi trường ồn
   - Chuẩn (×2.2) — như hiện tại *(mặc định)*
   - To (×3.5)
   - Rất to (×5)
   Kèm bộ giới hạn mềm (soft limiter) để tiếng không bị rè/vỡ khi khuếch đại lớn.
2. **Chất lượng ghi âm**:
   - Tiêu chuẩn — 16 kHz, file nhỏ *(mặc định, như hiện tại)*
   - Cao — 44.1 kHz, tiếng rõ hơn, file lớn ~2.8 lần
   (Nhận dạng giọng nói offline vẫn tự hạ về 16 kHz nên không bị ảnh hưởng.)
3. **Ghi thử** (tuỳ chọn): nút "Ghi thử 5 giây" → tự phát lại để nghe mức âm lượng vừa chọn.
4. Ghi chú nhỏ cuối màn: "Áp dụng cho lần ghi âm tiếp theo. Bản ghi cũ không thay đổi."

## Trạng thái
- Bình thường: hiển thị lựa chọn hiện tại.
- Ghi thử: nút đổi thành "Đang ghi… 3s" → "Đang phát…" → về lại; lỗi không có quyền mic → snackbar "Chưa cấp quyền micro".
- Không có trạng thái rỗng/tải (cài đặt lưu local, đọc tức thì).

## Phạm vi code (T11.4)
- Lưu 2 cài đặt (SharedPreferences, theo cách các cài đặt khác của app), truyền xuống Android qua method channel khi bắt đầu ghi.
- `WavRecorder.kt`: gain + sample rate thành tham số; thêm soft limiter.
- Chuỗi l10n en/zh/vi; test unit cho lưu/đọc cài đặt và phép khuếch đại có giới hạn.
