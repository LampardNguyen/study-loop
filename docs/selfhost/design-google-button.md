# Design — Nút "Sign in with Google" theo hướng dẫn thương hiệu (T13.5)

Mockup: [design-google-button.html](design-google-button.html)
Nguồn: Google Sign-In Branding Guidelines (developers.google.com/identity/branding-guidelines).

## Hiện tại
`FilledButton` màu chính của app + icon `Icons.login` + chữ "Đăng nhập bằng Google". Nút này sai hướng dẫn của Google vì không có logo "G", sai màu nền và sai font.

## Thay đổi
Chỉ thay **một nút** ở trạng thái "Chưa đăng nhập" (màn Đồng bộ Google Drive, cũng dùng ở nút "Đăng nhập lại" trong thẻ lỗi). Các phần khác của màn giữ nguyên.

| Thuộc tính | Theme sáng | Theme tối |
|---|---|---|
| Nền | `#FFFFFF` | `#131314` |
| Viền | 1px `#747775` | 1px `#8E918F` |
| Chữ | `#1F1F1F` | `#E3E3E3` |
| Logo | "G" 4 màu chuẩn (không đổi màu, không méo) | như theme sáng |

- Hình dạng: bo tròn hết cỡ (pill), cao 40dp, kéo hết chiều rộng như nút hiện tại.
- Khoảng cách: lề trái 12dp → logo 20×20dp → cách 10dp → chữ; chữ căn giữa nút.
- Chữ: Roboto Medium 14sp (font mặc định Android), lấy từ chuỗi i18n sẵn có `driveSyncSignIn`:
  - en: "Sign in with Google"
  - vi: "Đăng nhập bằng Google"
  - zh: "使用 Google 登录"

  Các chuỗi này nằm trong danh sách bản dịch Google cho phép.
- Trạng thái:
  - Nhấn: thêm lớp phủ 12% (ripple mặc định).
  - Đang đăng nhập: nút bị khoá, logo thay bằng vòng xoay 20dp.
  - Bị khoá: độ mờ 38%.
- Logo: vẽ bằng SVG (`assets/icon/google_g.svg`) theo các đường path chuẩn của logo "G", dùng `flutter_svg` có sẵn trong dự án. Không cần tải file từ ngoài.

## Không đổi
Nút "Đăng xuất", "Sao lưu ngay" và "Khôi phục từ Drive" vẫn dùng style của app, vì Google chỉ quy định cho nút đăng nhập.
