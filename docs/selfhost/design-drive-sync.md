# Design — Đồng bộ Google Drive (T13.1)

Mockup: [design-drive-sync.html](design-drive-sync.html)

## Lối vào
Cài đặt → nhóm **Dữ liệu**, ngay dưới "Sao lưu & khôi phục": ô **"Đồng bộ Google Drive"**, dòng phụ = email nếu đã đăng nhập, hoặc "Chưa đăng nhập". Mũi tên ›.

## Màn hình "Đồng bộ Google Drive"
### A. Chưa đăng nhập
- Biểu tượng đám mây, mô tả: "Sao lưu cài đặt, tiến độ học, podcast, phụ đề và audio vào thư mục riêng của ứng dụng trên Google Drive của bạn. OpenAI API key không bao giờ được sao lưu."
- Nút chính **Đăng nhập bằng Google**.

### B. Đã đăng nhập
- Thẻ tài khoản: avatar, tên, email, nút chữ **Đăng xuất**.
- Thẻ trạng thái: "Lần sao lưu gần nhất: 28/10/2026 21:05 · 42 bài · 1,2 GB audio" (hoặc "Chưa có bản sao lưu trên Drive").
- Nút **Sao lưu ngay** (chính), **Khôi phục từ Drive** (viền; tắt nếu chưa có bản sao lưu).
- Ghi chú nhỏ: "🔒 OpenAI API key không được sao lưu."

### C. Đang chạy
- Thay 2 nút bằng thanh tiến độ + dòng bước: "Đang chuẩn bị dữ liệu…", "Đang tải audio 12/42…", "Đang tải bản sao lưu…". Nút **Huỷ**. Không cho rời màn (hỏi xác nhận khi bấm Back).

### D. Xác nhận khôi phục (hộp thoại)
- "Khôi phục sẽ thay dữ liệu học tập và cài đặt hiện tại bằng bản sao lưu ngày 28/10/2026 (42 bài). OpenAI key hiện tại được giữ nguyên." → **Huỷ** / **Khôi phục**. Xong: app khởi động lại dữ liệu như luồng Khôi phục hiện có.

### E. Lỗi
- SnackBar/thẻ đỏ: không có mạng · hết dung lượng Drive · phiên Google hết hạn (nút Đăng nhập lại) · bản sao lưu từ phiên bản app mới hơn. Dữ liệu máy không bị đổi khi lỗi giữa chừng.

## Thành công
SnackBar "Đã sao lưu lên Google Drive" / "Đã khôi phục"; cập nhật thời điểm sao lưu gần nhất.
