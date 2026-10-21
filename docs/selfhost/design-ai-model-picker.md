# Design T9.1: Chọn model có sẵn danh sách và giá, vẫn nhập tay được

> Trạng thái: **Không làm** (2026-10-21). Người dùng quyết định giữ ô nhập tay, mặc định `gpt-4.1-mini`. Giữ file để tham khảo.
> Yêu cầu (2026-10-21): ô Model trong Cài đặt AI có sẵn danh sách từ gpt-4.1-mini đến bản mới nhất,
> hiện giá input/output, và vẫn nhập tay được model khác (phòng khi danh sách cũ).

## 1. Danh sách model

Giá lấy từ https://developers.openai.com/api/docs/pricing ngày **2026-10-21**. Đơn vị: USD cho 1 triệu token, gói Standard.

| Nhóm | Model | Input | Output | Nhãn |
|---|---|---|---|---|
| GPT-6 | `gpt-6-luna` | $0.10 | $0.50 | Rẻ nhất · Mới |
| | `gpt-6.1-sol` | $2.00 | $10.00 | Mới |
| | `gpt-6-sol` | $2.00 | $10.00 | |
| | `gpt-6-astra` | $10.00 | $50.00 | Mạnh nhất |
| GPT-5.6 | `gpt-5.6-luna` | $0.20 | $1.20 | |
| | `gpt-5.6-terra` | $2.00 | $12.00 | |
| | `gpt-5.6-sol` | $4.00 | $20.00 | |
| GPT-5.5 | `gpt-5.5` | $5.00 | $30.00 | |
| GPT-5.4 | `gpt-5.4-nano` | $0.20 | $1.25 | |
| | `gpt-5.4-mini` | $0.75 | $4.50 | |
| | `gpt-5.4` | $2.50 | $15.00 | |
| GPT-5.2 | `gpt-5.2` | $1.75 | $14.00 | |
| GPT-5.1 | `gpt-5.1` | $1.25 | $10.00 | |
| GPT-5 | `gpt-5-nano` | $0.05 | $0.40 | |
| | `gpt-5-mini` | $0.25 | $2.00 | |
| | `gpt-5` | $1.25 | $10.00 | |
| GPT-4.1 | `gpt-4.1-mini` | $0.40 | $1.60 | **Mặc định** |
| | `gpt-4.1` | $2.00 | $8.00 | |

Không đưa vào danh sách (vẫn nhập tay được):
- Các bản `-pro`: rất đắt, từ $15 trở lên cho input.
- `codex`, `search`, `chat-latest`: dùng cho mục đích khác.
- Các bản cũ hơn gpt-4.1-mini.

Danh sách là hằng số trong code (`ai_model_catalog.dart`), không tải từ mạng, để không thêm kết nối ra ngoài.

## 2. Giao diện

### Ô Model trên màn Cài đặt AI
Ô nhập chữ được thay bằng một dòng bấm được:

```
  Model
  ┌────────────────────────────────────────────┐
  │ gpt-4.1-mini                            ▾  │
  └────────────────────────────────────────────┘
  Input $0.40 · Output $1.60 / 1M token
```

- Bấm vào thì mở bottom sheet chọn model.
- Dòng phụ bên dưới hiện giá của model đang chọn.
- Nếu là model tự nhập (không có trong danh sách), dòng phụ ghi: *"Model tuỳ chỉnh, không có thông tin giá"*.

### Bottom sheet "Chọn model" (kéo lên được tới gần full màn hình)

```
  ───  (thanh kéo)
  Chọn model
  Giá OpenAI, USD / 1 triệu token · cập nhật 2026-10-21
  ┌──────────────────────────────────────────────┐
  │ ✏️  Nhập model khác…                          │  ← luôn ở trên cùng
  ├──────────────────────────────────────────────┤
  │ GPT-6                                        │  ← tiêu đề nhóm
  │ ○ gpt-6-luna      [Rẻ nhất] [Mới]            │
  │   Vào $0.10 · Ra $0.50                       │
  │ ○ gpt-6.1-sol     [Mới]                      │
  │   Vào $2.00 · Ra $10.00                      │
  │ …                                            │
  │ GPT-4.1                                      │
  │ ● gpt-4.1-mini    [Mặc định]            ✓    │  ← đang chọn
  │   Vào $0.40 · Ra $1.60                       │
  │ ○ gpt-4.1                                    │
  │   Vào $2.00 · Ra $8.00                       │
  └──────────────────────────────────────────────┘
```

- Bấm một dòng thì đóng sheet và điền model đó vào. Vẫn phải bấm **Lưu** như hiện nay (nút Lưu chỉ sáng khi có thay đổi).
- **Nhập model khác…** mở một dialog có ô chữ (gõ sẵn model hiện tại), với 2 nút Huỷ / OK. Ô trống thì nút OK bị khoá.
- Màu giá: input dùng màu chữ phụ. Không tô màu theo đắt/rẻ, để giao diện gọn.

### Khi Base URL không phải OpenAI
Ví dụ dùng OpenRouter hay server trên máy:
- Danh sách vẫn hiện bình thường.
- Dưới tiêu đề sheet thêm dòng *"Giá chỉ đúng với api.openai.com"*.
- Thường người dùng sẽ chọn **Nhập model khác…**.

### Các trạng thái
- **Chưa chọn:** không xảy ra, vì luôn có model mặc định `gpt-4.1-mini`.
- **Đang tải / lỗi:** danh sách là hằng số nên không có hai trạng thái này.

## 3. Thay đổi kỹ thuật bắt buộc (không có UI)

Các model đời gpt-5 / gpt-6 là **model reasoning**. Khi gọi qua `chat/completions`:
- Hiện app luôn gửi `temperature` (0.3 cho dịch/phân tích, 0.7 cho chat). Model reasoning có thể **từ chối tham số này (lỗi 400)**.
- Nếu không đặt `reasoning_effort`, model mặc định suy nghĩ ở mức `medium`. Như vậy từ điển và dịch sẽ chậm và tốn token hơn.

Cách xử lý:
- Model khớp mẫu `gpt-5*`, `gpt-6*`, `o1*`, `o3*`, `o4*` (kể cả có tiền tố như `openai/gpt-5`) thì **không gửi `temperature`** và gửi `reasoning_effort: "low"`.
- Chọn `low` vì đây là mức mà mọi model trong danh sách đều hỗ trợ (gpt-6.1-sol và gpt-6-astra không nhận `none`/`minimal`).
- gpt-4.1 / gpt-4o giữ nguyên như hiện tại.

Lưu ý thêm:
- Token suy nghĩ (reasoning) cũng bị tính tiền như output. Vì vậy chi phí thực của model reasoning cao hơn con số trong bảng.
- Sheet sẽ ghi chú thêm một dòng nhỏ: *"Model gpt-5 trở lên tính thêm token suy nghĩ"*.

## 4. Test dự kiến

- **Unit:**
  - Catalog: không trùng id, mặc định nằm trong danh sách.
  - `isReasoningModel` đúng/sai cho các mẫu tên.
  - Chat client: không gửi `temperature` mà gửi `reasoning_effort` khi dùng model reasoning; giữ nguyên với gpt-4.1.
- **Widget:**
  - Bấm ô Model mở sheet; chọn model thì giá hiện dưới ô và nút Lưu sáng.
  - Nhập model tuỳ chỉnh thì hiện dòng "không có thông tin giá".
  - Model đã lưu không có trong danh sách vẫn hiển thị đúng.
- **Tay:** emulator, mở sheet trên màn hình hẹp, kiểm tra cả giao diện tiếng Việt.
