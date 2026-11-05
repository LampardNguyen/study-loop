# Design T15.10 — Thiết bị của bản sao lưu Drive gần nhất

## Bố cục (tab Cá nhân → Lưu trữ)
```
☁  Đồng bộ Google Drive                         ›
   linh@gmail.com
   Sao lưu gần nhất: Pixel 9 Pro (máy này) · 05/11 14:32
```
- Dòng 2: email như hiện tại. Dòng 3 (mới): chữ nhỏ, màu phụ (`bodySmall`, onSurfaceVariant).
- Thiết bị trùng máy hiện tại (so `deviceId`) → thêm "(máy này)".
- Thời gian: hôm nay → "hôm nay 14:32"; khác ngày → "05/11 14:32"; khác năm → "05/11/2025".

## Trạng thái
| Trạng thái | Hiển thị |
|---|---|
| Chưa đăng nhập | "Chưa đăng nhập" (như cũ), không có dòng 3 |
| Đã đăng nhập, chưa biết bản sao lưu nào (chưa từng sao lưu/khôi phục/kiểm tra) | chỉ email |
| Bản sao lưu cũ không có tên thiết bị | "Sao lưu gần nhất: 05/11 14:32" (bỏ tên máy) |
| Có đủ | như mockup |
| Đang tải / lỗi | không có — chỉ đọc cache, không gọi mạng |

## Nguồn dữ liệu
- Mở tab Cá nhân **không** gọi Drive (tránh sheet "Đang đăng nhập", xem T14.6).
- Lưu cache trong SharedPreferences `drive_sync_last_backup_device_name/_id/_at` (tiền tố `drive_sync_` → không bị sao lưu).
- Cập nhật cache khi: Sao lưu xong, Khôi phục xong, và khi `checkNewerDriveBackup` đọc `backup-index.json`
  (nên máy khác sao lưu thì lần kiểm tra kế tiếp sẽ hiện tên máy đó).
- Đăng xuất → xoá cache.
