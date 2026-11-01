# Design T15.8 — Tạo hội thoại bằng AI

Vị trí: khung nhập hội thoại, hàng nút phía trên, bên cạnh nút **Dán**: `[✨ Tạo bằng AI] [Dán]`.

Bấm nút → bottom sheet:

```
Tạo hội thoại bằng AI
Chủ đề        ( Gợi ý ) ( Tự nhập ) ( 🎲 Ngẫu nhiên )
  Gợi ý    →  [Gọi món ở nhà hàng ▾]          (danh sách chọn)
  Tự nhập  →  [ Hỏi đường, đang lạc ở ga Tokyo ]   (ô nhập)
  Ngẫu nhiên → “AI sẽ tự chọn chủ đề phù hợp trình độ”
Ngôn ngữ             [English ▾]   (mặc định: ngôn ngữ đang học)
Trình độ             [A1-A2] [B1] [B2] [C1+]
Số người nói         [2] [3]
Độ dài               [Ngắn ~8 câu] [Vừa ~16] [Dài ~30] [Rất dài ~50]
                                 [Huỷ]  [Tạo]
```

- Trình độ quyết định từ vựng/ngữ pháp; C1+ dùng thành ngữ, cách nói tắt, từ lóng nhẹ như người bản xứ.
  Kết hợp tốt với cấp độ giọng đọc của T15.7 (gợi ý: chọn Trình độ thì tự đề xuất cấp độ giọng tương ứng — chỉ gợi ý, không ép).
- AI trả về: tên bài gợi ý + các dòng `Tên: câu nói` (tên nhân vật thật, vd Mark/Anna) → parse bằng `parseDialogue`.

Chủ đề — 3 cách, chọn 1 (nút chọn kiểu segmented):
- **Gợi ý** (mặc định): danh sách chọn có sẵn — Gọi món ở nhà hàng, Hỏi đường, Check-in khách sạn,
  Phỏng vấn xin việc, Đi khám bệnh, Mua sắm & đổi trả, Sân bay, Họp công việc, Làm quen bạn mới,
  Kế hoạch cuối tuần, Thuê nhà, Gọi tổng đài chăm sóc khách hàng. Không phải ô chữ; dịch theo ngôn ngữ giao diện.
- **Tự nhập**: ô nhập chủ đề/tình huống bất kỳ; nút Tạo mờ khi ô trống.
- **Ngẫu nhiên**: không cần nhập gì; AI tự nghĩ chủ đề đời thường phù hợp trình độ, tên bài lấy theo chủ đề AI chọn.
- Nhớ cách chọn + mục gợi ý lần trước; nội dung tự nhập không nhớ.

Trạng thái:
- **Rỗng**: chỉ ở chế độ Tự nhập, nút Tạo mờ khi ô trống.
- **Đang tạo**: nút Tạo thành vòng xoay + “Đang tạo…”, có nút Huỷ (huỷ request).
- **Lỗi**: dòng lỗi màu đỏ trong sheet (chưa cấu hình AI → mở màn cấu hình như các tính năng AI khác; lỗi mạng/key/không parse được), giữ nguyên dữ liệu đã nhập để thử lại.
- **Thành công**: đóng sheet, điền hội thoại vào khung (và tên bài nếu đang trống).
  Khung đã có nội dung → hỏi “Thay thế hội thoại hiện tại?” trước khi ghi đè.
- Mặc định lần đầu: Chủ đề Gợi ý (mục đầu), Trình độ B1, 2 người nói, Độ dài ~30 câu. Sau đó nhớ các lựa chọn lần trước (trừ nội dung tự nhập).

Kỹ thuật: dùng `openai_chat_client` + model chat đang cấu hình trong Cài đặt AI, chỉ gọi tới endpoint OpenAI người dùng cấu hình; prompt đặt trong `ai_prompts.dart`.
