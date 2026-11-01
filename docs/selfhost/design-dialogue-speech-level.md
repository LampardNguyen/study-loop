# Design T15.7 — Cấp độ giọng đọc

Vị trí: bảng tạo hội thoại → giọng nói, ngay dưới hàng chọn chất lượng.

```
Chất lượng   [Tự nhiên] [Tiêu chuẩn] [Cao]
Cấp độ nghe  [Rõ ràng] [Chuẩn] [Lưu loát] [Bản xứ]
             Tốc độ hội thoại thường, có nối âm, ngữ điệu tự nhiên.
```

| Mức | Dành cho | Prompt (tóm tắt) |
|---|---|---|
| Rõ ràng | mới học | chậm, phát âm tách bạch từng từ, ngắt rõ giữa cụm/câu, không nối âm, to rõ |
| Chuẩn (mặc định) | trung cấp | tốc độ vừa, to rõ, giọng giáo trình, âm lượng đều (= prompt T15.6) |
| Lưu loát | khá | tốc độ hội thoại thường, có nối âm, nhấn nhá và ngữ điệu tự nhiên |
| Bản xứ | nâng cao | nhanh, thoải mái như người bản xứ nói với nhau: nối/nuốt âm, giảm âm, ngữ điệu cảm xúc, ngắt nghỉ tự nhiên |

Trạng thái:
- Chất lượng Tiêu chuẩn/Cao (tts-1, tts-1-hd không hỗ trợ prompt): hàng chip mờ, dòng mô tả đổi thành “Chỉ dùng được với chất lượng Tự nhiên”.
- Đang tạo bài: khoá như các lựa chọn khác.
- Đổi mức → bản nghe thử cũ hết hiệu lực (khoá cache có mức).
- Nhớ mức đã chọn lần trước (SharedPreferences).
- Chỉ đổi giọng đọc, không đổi nội dung câu. Văn bản giữ nguyên nên phụ đề vẫn khớp.
