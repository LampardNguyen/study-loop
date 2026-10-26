# Kế hoạch dự án Echo Loop

> Cập nhật lần cuối: 2026-09-21 (khởi tạo dữ liệu cục bộ thất bại thì hạ cấp về trang chủ và giữ lối vào xem log)
> Trọng tâm hiện tại: chức năng ghi âm + nhận dạng; vướng mắc lớn nhất là ASR offline trên Android crash khi kết thúc ghi âm

## Mục tiêu sản phẩm

Echo Loop là ứng dụng học tiếng Anh xoay quanh “đầu vào âm thanh + học theo câu + ôn tập ngắt quãng + hỗ trợ AI”. Mục tiêu cốt lõi:

- Giúp người dùng hoàn thành lần học đầu và các lần ôn tập sau đó dựa trên tài liệu âm thanh thật.
- Giữ vòng học chính miễn phí; AI và gói đăng ký chỉ nâng cao trải nghiệm, không chặn luồng cốt lõi.
- Ưu tiên đảm bảo trình phát, luồng học, tính nhất quán trạng thái và độ ổn định đa nền tảng.

## Trạng thái hiện tại

Các năng lực đã ra mắt ổn định:

- Nhập âm thanh, quản lý phụ đề, chỉnh sửa phụ đề, trình phát tự do.
- Luồng chính học lần đầu: nghe mù toàn bài, nghe kỹ từng câu, nhại theo câu khó, kể lại đoạn văn.
- Hệ thống yêu thích: câu, từ, cụm ý, ôn tập mục yêu thích.
- Hệ thống từ điển: từ điển cục bộ, từ điển AI, từ điển web, chuyển đổi nhiều nguồn, panel không modal.
- Năng lực AI: dịch, phân tích câu, phân tích sâu từ vựng, chuyển văn bản (transcribe).
- Xuất PDF: xuất tài liệu học thành PDF có thể in.
- Hệ thống đăng ký: nhận diện nền tảng/kênh, RevenueCat native, thanh toán Paddle trực tiếp qua backend, backend phân xử hạn mức AI.

Rủi ro chính hiện tại:

- ASR offline trên Android gây crash native trên một số dòng máy sau khi kết thúc ghi âm, vẫn chưa xác định được root cause cuối cùng.
- Luồng chính của đăng ký đã thông, nhưng vẫn cần tiếp tục xác minh theo kênh, hồi quy và hoàn thiện cấu hình production.
- Khởi động nguội đã đưa các khởi tạo nặng ra khỏi đường đi của frame đầu tiên, và dùng Riverpod `AsyncValue` để quản lý thống nhất trạng thái khởi tạo dữ liệu cục bộ; khi dữ liệu cục bộ lỗi sẽ không còn chặn khung điều hướng, trang chủ cung cấp lối thử lại và xem log. Vẫn cần dùng log khởi động trên máy iOS thật bị ảnh hưởng để xác minh nguyên nhân migration thất bại và thời gian thực tế của frame đầu.

## Milestone hiện tại

### ✅ Milestone 1: Trình phát cơ bản

Đã hoàn thành. Bao gồm nhập âm thanh, ba chế độ phát toàn bài/từng câu/yêu thích, đồng bộ phụ đề, yêu thích và điều khiển phát cơ bản.

### 🚧 Milestone 2: Engine luồng học

Phần chính đã xong, phần hoàn thiện còn lại tập trung vào độ ổn định của ghi âm nhận dạng:

- Đã xong: luồng học lần đầu, chuyển đổi trạng thái giai đoạn, học tiếp từ điểm dừng, sắp xếp bài luyện theo độ khó.
- Đã xong: luyện bổ sung câu khó, ôn tập yêu thích, khung dùng chung cho nghe mù và kể lại.
- Chưa xong: xác định root cause và sửa lỗi crash ASR offline trên Android; kể lại đoạn văn tiếp tục dùng lại module ghi âm nhận dạng thống nhất.

### ✅ Milestone 3: Hệ thống yêu thích và chú thích

Đã hoàn thành. Bao gồm Favorites, yêu thích câu/từ/cụm ý, ôn tập yêu thích, liên kết từ điển và hiển thị nội dung chú thích.

### 🚧 Milestone 4: Tối ưu trải nghiệm và sẵn sàng production

Đang tiếp tục:

- Tối ưu hiệu năng và độ ổn định.
- Đồng bộ trải nghiệm đa nền tảng (iOS / Android / macOS).
- Mài giũa trải nghiệm các luồng dùng thường xuyên như phát, từ điển, PDF, chỉnh sửa phụ đề.
- Hoàn thiện độ ổn định của luồng CI / Release / cập nhật.
- Trợ lý hội thoại AI (component chatbot dùng chung): trợ lý AI hội thoại nhiều lượt, một bộ component có thể cắm vào nhiều vị trí khác nhau (điểm tích hợp đầu tiên là trang giải thích câu; từ 2026-07-23 AppBar của 4 trang tác vụ cấp câu là nghe kỹ từng câu / nhại theo câu khó / ôn câu khó / ôn yêu thích cũng được tích hợp, dùng chung `SentenceChatButton` làm nguồn lối vào duy nhất), tái sử dụng luồng streaming NDJSON và cổng hạn mức 402 hiện có. Việc phát hành được điều khiển bởi hai công tắc `kChatbotEnabled` + remote config. Đặc tả xem [docs/chatbot-implementation-plan.md](./docs/chatbot-implementation-plan.md).

### 🚧 Milestone 5: Thanh toán đăng ký (Echo Loop Premium)

Trạng thái hiện tại:

- Đã xong: tích hợp RevenueCat phía client, trang đăng ký, nhận diện nền tảng/kênh, direct Paddle Checkout và Customer Portal, backend phân xử hạn mức AI, inject kênh khi release, refactor P0 nguồn quyền lợi duy nhất (backend `/api/entitlements` là nguồn có thẩm quyền duy nhất + forceReconcile hội tụ khi giao dịch thành công, xem [docs/subscription-single-source-plan.md](./docs/subscription-single-source-plan.md)).
- Cần tiếp tục: xác minh trên môi trường production thật (hồi quy thủ công hội viên Paddle trên bản phát hành qua store, xem plan §11; P0+P1 cần backend deploy đồng bộ), xử lý hoàn tiền/thu hồi, xác minh nhiều thiết bị/đổi máy, hồi quy thêm kênh. Làm mới thông minh P1 (E7/E6/E8) đã hoàn thành toàn bộ (2026-07-23); push Realtime E9 là tùy chọn, chưa triển khai.

Tài liệu tham khảo:

- [Cấu hình đăng ký và hướng dẫn phát hành](./docs/subscription-setup.md)

## Trọng tâm giai đoạn gần

1. Giải quyết crash ASR offline trên Android.
2. Hoàn tất xác minh thủ công snapshot quyền khi khởi động (tracking).
3. Tiếp tục thu hẹp ranh giới tái sử dụng của module ghi âm nhận dạng.
4. Duy trì tính nhất quán của luồng release / kênh / đăng ký.

## Ràng buộc kiến trúc (bản rút gọn)

- Luồng dữ liệu một chiều: UI kích hoạt hành động, provider / controller đổi trạng thái, UI render thụ động.
- Trang chịu trách nhiệm lắp ghép, component chịu trách nhiệm hiển thị, luồng phức tạp đưa xuống tầng điều phối Dart thuần có thể test.
- Side effect được inject qua service / repository, không rải lời gọi mạng, file, nền tảng vào UI.
- Luồng bất đồng bộ phải có guard session / token / generation, tránh callback cũ làm bẩn trạng thái mới.
- Luồng ghi thống kê học tập mới được dùng cho mọi tác vụ học (nghe tự do, ôn yêu thích, nghe kỹ từng câu, nhại theo câu khó, nghe mù toàn bài, kể lại đoạn văn và luyện bổ sung câu khó):
  Trang → Provider → StudySessionTimer → hàng đợi FIFO StudyTimeService → StudyStatisticsDao trong một transaction;
  bộ đếm giờ được tạo/hủy theo vòng đời trang, sự kiện phát xong ghi vào thống kê đầu vào, sự kiện ghi âm xong ghi vào thống kê đầu ra, người dùng không hoạt động quá
  2 phút mới tạm dừng tổng thời gian học. Các tác vụ học không còn giữ luồng ghi riêng StudyEventRecorder, StudyStatisticsRecorder hay kiểu ghi tăng dần add* cũ.
- Các năng lực thống kê theo ngày, thống kê theo giai đoạn và transaction dạng từ mà luồng mới sử dụng được giữ triển khai tập trung, tránh bên gọi mới đi vòng qua
  lối ghi thống nhất.
- Năng lực mới ưu tiên bổ sung test chuyển đổi trạng thái và test hồi quy quan trọng.

## Chỉ mục ADR chính

- Tách media engine và foreground engine: tránh phiên media màn hình khóa và nghe thử foreground làm bẩn lẫn nhau.
- Kiến trúc TTS thống nhất: tổng hợp → file → cache → phát, hỗ trợ TTS nền tảng và TTS cục bộ Kokoro.
- Chuyển văn bản offline và model cục bộ: tái sử dụng năng lực xử lý âm thanh và tải model thống nhất.
- Nhận diện thống nhất nền tảng + kênh: `platform + distribution` quyết định cách triển khai thanh toán và chính sách hạn mức backend.
- Hạ tầng lập lịch ghi nhớ dùng chung: mô hình hóa bằng snapshot lập lịch độc lập và sự kiện ôn tập chỉ ghi nối thêm; tầng trên phụ thuộc vào interface riêng của app, FSRS chỉ nằm trong adapter, cố định Profile theo từng mục để đảm bảo khả năng di chuyển và kiểm toán (xem [memory-scheduler-infrastructure-plan.md](./docs/memory-scheduler-infrastructure-plan.md)).

Lịch sử chi tiết và tài liệu dài bản cũ đã được lưu trữ:

- [Snapshot toàn bộ kế hoạch 2026-07-12](./docs/plan-archive/plan-2026-07-12-full.md)

Khi làm việc hằng ngày hãy kết hợp với:

- [TASKS.md](./TASKS.md)
- [AGENTS.md](./AGENTS.md)
