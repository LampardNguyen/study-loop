# Nhật ký thay đổi (Study Loop self-host)

Ghi theo từng task hoàn thành, dùng để chép vào ghi chú GitHub Release.

## v1.0.51 (build 16) — 2026-10-30

### Tính năng mới
- Hội thoại → giọng nói: danh sách giọng hiện rõ **Nam / Nữ** (vd `ballad · Nam`, `sage · Nữ`); giọng mặc định người nói 1 là ballad (nam), người nói 2 là sage (nữ).
- Nút **Nghe thử 2 câu đầu** để nghe giọng trước khi tạo bài; bấm nghe lại nhiều lần không tốn phí, chỉ tạo lại khi đổi giọng, chất lượng hoặc nội dung 2 câu đầu. Có nút Dừng.
- Giao diện chọn giọng mới: mỗi người nói có avatar chữ cái (màu theo giọng nam/nữ) và nút chọn giọng dạng chip; chất lượng chọn bằng 3 nút Tự nhiên / Chuẩn / Cao.

## v1.0.50 (build 15) — 2026-10-29

### Sửa lỗi
- Mở lại app giờ luôn tự kiểm tra và hiện thông báo khi có bản mới (trước đây mở lại trong vòng 1 giờ thì không hiện, phải vào Cá nhân → Kiểm tra cập nhật).
- Vào tab **Cá nhân** không còn bật lên khung Google "Đang đăng nhập" mỗi lần mở lại app; email tài khoản Drive được hiển thị từ bộ nhớ đệm.

## v1.0.49 (build 14) — 2026-10-29

### Tính năng mới
- **Tạo bài học từ hội thoại** (Thêm audio → *Hội thoại → giọng nói*): dán đoạn hội thoại dạng `Tên: câu nói`, chọn giọng cho từng người và chất lượng (gpt-4o-mini-tts / tts-1 / tts-1-hd). App dùng OpenAI key của bạn để đọc từng câu, ghép thành một bài nghe và tạo phụ đề khớp chính xác từng câu (phụ đề chỉ có câu thoại, không kèm tên). Có ước tính chi phí trước khi tạo (đoạn 50 câu ≈ $0.04), tiến độ từng câu và nút Huỷ.

## v1.0.48 (build 13) — 2026-10-28

### Tính năng mới
- **Đồng bộ Google Drive** (Cài đặt → Lưu trữ): đăng nhập Google rồi bấm "Sao lưu ngay" / "Khôi phục từ Drive". Cài đặt, tiến độ học, podcast, phụ đề và audio được lưu vào thư mục riêng (ẩn) của app trên Drive của bạn; audio đã tải lên sẽ không tải lại. OpenAI API key **không bao giờ** được sao lưu và được giữ nguyên khi khôi phục.
- Đồng bộ Google Drive mở cho **mọi tài khoản Google** (OAuth đã publish Production); trang chủ và chính sách quyền riêng tư: https://lampardnguyen.github.io/study-loop/
- Nút **Đăng nhập bằng Google** theo đúng hướng dẫn thương hiệu của Google (logo "G", màu chuẩn cho giao diện sáng/tối).
- **Đổi package thành `com.studyloop.app`** (bản dev: `com.studyloop.app.dev`). Android coi đây là app mới: hãy sao lưu ở app cũ, cài bản này, khôi phục rồi nhập lại OpenAI key; sau đó gỡ app cũ.

## v1.0.47 (build 12) — 2026-10-27

### Tính năng mới
- **Cắt đoạn audio** (trong Quản lý phụ đề): chọn điểm đầu/cuối trên dạng sóng để bỏ quảng cáo ở đầu/cuối tập podcast trước khi tạo phụ đề. Có nghe thử (từ điểm đầu, đến điểm cuối, cả bản đã cắt) để kiểm tra vị trí cắt. Bài đã có phụ đề vẫn cắt được: phụ đề, câu yêu thích và tiến độ học sẽ bị xóa để tạo lại.

## v1.0.46 (build 11) — 2026-10-26

### Tính năng mới
- Cập nhật ứng dụng ngay trong app: bấm "Cập nhật ngay" sẽ tải APK với thanh tiến độ (%, MB, nút Hủy) rồi mở màn cài đặt Android. Lần đầu app xin quyền "Cài ứng dụng không rõ nguồn" và tự tải tiếp khi bạn quay lại. Nếu tải lỗi, app tự mở link APK bằng trình duyệt như trước.

### Sửa lỗi
- Menu **Nhà phát triển** (và các màn ASR test, Gỡ lỗi gói đăng ký, Tuỳ chọn, Nhật ký, Bộ nhớ trong) hiển thị theo ngôn ngữ app (Việt / Anh / Trung) thay vì luôn tiếng Trung.

## v1.0.45 (build 10) — 2026-10-26

### Sửa lỗi
- Đổi tên hiển thị còn sót "Echo Loop" thành "Study Loop".

## v1.0.44 (build 9) — 2026-10-26

### Sửa lỗi
- Bảo mật: nâng `dio_http2_adapter` 2.7.1 → 2.8.0, vá lỗi lộ header nhạy cảm (vd API key) khi bị chuyển hướng sang domain khác.

## v1.0.43 (build 8) — 2026-10-23

### Tính năng mới
- Cài đặt → Học tập → **Ghi âm** (Android): chỉnh **âm lượng ghi** (Nhỏ ×1.5 / Chuẩn ×2.2 / To ×3.5 / Rất to ×5, có giới hạn mềm chống rè) và **chất lượng ghi** (Tiêu chuẩn 16 kHz / Tốt 24 kHz / Cao 44.1 kHz). Có nút **Ghi thử 5 giây** để nghe lại ngay. Máy không hỗ trợ 24 kHz sẽ tự dùng 16 kHz.

### Sửa lỗi
- Thông báo nhắc ôn tập hiển thị theo ngôn ngữ của app (Tiếng Việt / English / 中文) thay vì luôn là tiếng Trung; đổi ngôn ngữ app thì thông báo đã lên lịch cũng đổi theo. *(Sau khi cập nhật, mở app một lần để lịch nhắc cũ bằng tiếng Trung được thay thế.)*
- Ảnh bìa thẻ phát nhạc trên màn khoá / thanh thông báo đổi từ con vẹt cũ sang con mèo (trước đây ảnh cũ bị lưu tạm và không được cập nhật).
- Icon nhỏ trên thanh thông báo của thông báo nhắc ôn tập dùng hình con mèo (trước đây dùng icon launcher).
