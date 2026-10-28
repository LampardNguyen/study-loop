# Nhật ký thay đổi (Study Loop self-host)

Ghi theo từng task hoàn thành, dùng để chép vào ghi chú GitHub Release.

## Chưa phát hành

### Tính năng mới
- **Đồng bộ Google Drive** (Cài đặt → Lưu trữ): đăng nhập Google rồi bấm "Sao lưu ngay" / "Khôi phục từ Drive". Cài đặt, tiến độ học, podcast, phụ đề và audio được lưu vào thư mục riêng (ẩn) của app trên Drive của bạn; audio đã tải lên sẽ không tải lại. OpenAI API key **không bao giờ** được sao lưu và được giữ nguyên khi khôi phục.
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
