# Design T12.3 — Cắt đầu/cuối audio trước khi tạo phụ đề

> Trạng thái: **Đã duyệt 2026-10-27**. Mockup bấm thử được: [design-audio-trim.html](design-audio-trim.html) (mở bằng trình duyệt).

Mục đích: bỏ quảng cáo ở đầu/cuối tập podcast (hoặc bất kỳ audio nào) để phụ đề và câu học không bị thừa, đồng thời đỡ tốn chi phí Whisper.

## 1. Lối vào — sheet "Quản lý phụ đề"

```
┌───────────────────────────────────────────┐
│ Quản lý phụ đề                            │
│                                           │
│ ✂  Cắt đoạn audio                       › │  ← mới, nằm trên khối tạo phụ đề
│    Bỏ quảng cáo đầu/cuối trước khi tạo    │
│    phụ đề · 32:15                         │
│───────────────────────────────────────────│
│ ☁  Tạo phụ đề (AI)                        │
│ 📱 Tạo phụ đề trên máy                    │
│ ...                                       │
└───────────────────────────────────────────┘
```
- Nút chỉ hiện khi audio đã được tải về, không phải video, và không có tác vụ tạo phụ đề nào đang chạy.
- Nếu bài **đã có phụ đề**, bấm nút sẽ hiện dialog:

```
┌───────────────────────────────────────────┐
│ Cắt audio sẽ xóa phụ đề                   │
│                                           │
│ Thời gian trong phụ đề sẽ bị lệch sau khi │
│ cắt. Phụ đề, câu yêu thích và tiến độ học │
│ của bài này sẽ bị xóa. Bạn có thể tạo lại │
│ phụ đề sau khi cắt.                       │
│                                           │
│                 [Hủy]   [ Tiếp tục ]      │
└───────────────────────────────────────────┘
```
Bấm "Tiếp tục" chỉ để mở màn cắt. Phụ đề **chỉ bị xóa khi bấm Lưu**; nếu thoát màn cắt mà không lưu thì phụ đề vẫn còn.

## 2. Màn "Cắt audio" (toàn màn hình)

```
┌───────────────────────────────────────────┐
│ ←  Cắt audio                     [ Lưu ]  │
│                                           │
│ 6 Minute English – Why do we yawn?        │
│                                           │
│ ░░░░┃▁▃▇▅▂▆█▃▅▇▂▄▆▃▇▅▂▆▃▅▇▂▄▆▃▅┃░░░░░░  │  waveform cả bài
│ ░░░░┃          │ (playhead)    ┃░░░░░░  │  vùng ░ = bị cắt (mờ)
│    [S]                        [E]         │  tay kéo Start / End
│ 0:00                                32:15 │
│                                           │
│ ▶ ────────●──────────────  05:12 / 32:15  │  Play/Pause + vị trí
│                                           │
│ ┌─ Điểm đầu ───────────┐ ┌─ Điểm cuối ──┐ │
│ │      00:45.0         │ │   31:40.0    │ │
│ │  [-1s] [+1s]         │ │ [-1s] [+1s]  │ │
│ │  [⤓ Đặt tại đây]     │ │ [⤓ Đặt tại …]│ │
│ │  [▶ Nghe từ đây]     │ │ [▶ Nghe đến…]│ │
│ └──────────────────────┘ └──────────────┘ │
│                                           │
│ Độ dài mới: 30:55  (bỏ 1:20)              │
│ [ ▶ Nghe bản đã cắt ]                     │
└───────────────────────────────────────────┘
```

### Nghe thử (để biết cắt đúng chỗ chưa)
| Nút / thao tác | Hành vi |
|---|---|
| ▶/⏸ thanh phát | Phát hoặc dừng ở vị trí hiện tại. Playhead chạy trên waveform. |
| Chạm vào waveform | Tua tới chỗ chạm (không đổi Start/End). |
| ▶ Nghe từ đây (Điểm đầu) | Phát 5s bắt đầu từ Start, rồi dừng. |
| ▶ Nghe đến đây (Điểm cuối) | Phát 5s ngay trước End, dừng đúng tại End. |
| Kéo tay S hoặc E | Khi thả tay: tự phát 3s quanh điểm vừa kéo (S: từ S; E: 3s trước E). |
| ⤓ Đặt tại đây | Đặt Start/End = vị trí đang phát. Cách hợp lý: nghe tới lúc hết quảng cáo, bấm Đặt tại đây. |
| ▶ Nghe bản đã cắt | Phát đoạn giữ lại từ đầu đến cuối (`setClip(start, end)`), giống file sau khi lưu. |

### Ràng buộc
- Start < End, đoạn giữ lại tối thiểu 1s. Kéo vượt thì dừng ở giới hạn.
- Nút Lưu bị disable khi Start = 0 và End = độ dài bài (chưa cắt gì).
- Bấm ← khi đã chỉnh mà chưa lưu: hỏi "Bỏ thay đổi?".

## 3. Trạng thái

| Trạng thái | Hiển thị |
|---|---|
| Đang tải waveform | Thanh xám nhấp nháy (skeleton) ở vị trí waveform. Phát và chỉnh ±1s vẫn dùng được. |
| Không tạo được waveform | Thay waveform bằng thanh thời gian đơn giản có 2 tay kéo, kèm dòng nhỏ "Không hiển thị được dạng sóng". |
| Đang cắt (sau khi bấm Lưu) | Lớp phủ mờ, vòng xoay "Đang cắt audio…", chặn mọi thao tác và nút back. |
| Lỗi khi cắt | Snackbar "Cắt audio thất bại, file gốc vẫn giữ nguyên". Ở lại màn cắt. |
| Thành công | Đóng màn, quay về sheet, snackbar "Đã cắt audio · độ dài mới 30:55". Phụ đề cũ (nếu có) đã bị xóa, nút tạo phụ đề sẵn sàng. |
