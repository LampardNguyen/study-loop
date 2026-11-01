# Design — Âm lượng phát (T15.1)

**Vị trí:** thanh điều khiển của các trình phát (player, nghe mù, nghe kỹ, nghe-nhắc lại, kể lại) thêm nút 🔊.
Bấm → bottom sheet "Âm lượng phát".

**Bố cục sheet**
- Tiêu đề: "Âm lượng phát"
- Thanh trượt 50% → 200%, bước 10%, nhãn giá trị bên phải (vd "150%"); vạch đánh dấu ở 100%.
- Dòng gợi ý khi >100%: "Mức trên 100% có thể bị rè với file vốn đã to."
- Công tắc "Chuẩn hoá âm lượng" + mô tả: "Tự làm đều độ lớn, câu nhỏ to lên, câu to không bị rè."
- Nút chữ "Đặt lại (100%)".

**Trạng thái**
- Mặc định: 100%, chuẩn hoá tắt.
- Đang kéo: áp dụng ngay (nghe thay đổi trực tiếp).
- Icon nút: 🔊 thường; khi ≠100% hoặc bật chuẩn hoá → icon đổi màu primary để biết đang tăng.
- Lỗi (mpv không áp được bộ lọc): giữ phát bình thường, tắt công tắc, snackbar "Không bật được chuẩn hoá".
- Không có trạng thái rỗng/đang tải (cài đặt cục bộ).

**Phạm vi:** cài đặt toàn cục, lưu lại; áp cho mọi trình phát media_kit. Các trình phát just_audio phụ (nghe thử TTS, cắt audio) giữ nguyên.
