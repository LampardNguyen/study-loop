# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Người dùng chính là người học nói tiếng Trung muốn luyện nghe và nói tiếng Anh một cách bài bản qua âm thanh thật. Sản phẩm ưu tiên dùng trên di động, đồng thời hỗ trợ đa nền tảng.

## Product Purpose

Echo Loop là ứng dụng học tiếng Anh xây dựng quanh đầu vào âm thanh, học theo câu và ôn tập ngắt quãng. Ứng dụng giúp người học biến tài liệu âm thanh thật thành bài luyện nghe nói có thể hoàn thành và duy trì lâu dài, với trình phát, luồng học và tính nhất quán trạng thái ổn định làm nền cho việc luyện tập hằng ngày.

## Positioning

Echo Loop tự động sắp xếp vòng khép kín hoàn chỉnh “nghe kỹ → nhại theo → nghe mù → kể lại → ôn tập ngắt quãng”, dựa vào luồng học để dẫn dắt người dùng lần lượt hoàn thành luyện tập và ôn tập; người dùng không cần tự mò phương pháp, kiểm soát số lượt luyện hay lên kế hoạch nhịp ôn tập.

## Operating Context

Người dùng nhập hoặc chọn tài liệu âm thanh, dùng phụ đề, từ điển, yêu thích và bài luyện theo câu để hoàn thành lần học đầu; sau đó tiếp tục ôn tập theo lịch ứng dụng sắp xếp. Sản phẩm bao phủ các tình huống dùng thường xuyên như nhập âm thanh, phát, ghi âm nhận dạng, chỉnh sửa phụ đề, tra từ điển, dữ liệu học tập và nhắc nhở.

## Capabilities and Constraints

- Hỗ trợ iOS, Android và macOS; ưu tiên trải nghiệm di động.
- Vòng học chính miễn phí; AI và gói đăng ký dùng để nâng cao trải nghiệm, không chặn luồng học cốt lõi.
- Sản phẩm dùng Flutter, Riverpod và lưu trữ dữ liệu cục bộ, nhấn mạnh khả năng offline và độ ổn định đa nền tảng.
- Trọng tâm kỹ thuật hiện tại là độ ổn định của ASR offline trên Android sau khi kết thúc ghi âm.
- Ứng dụng hỗ trợ giao diện tiếng Trung và tiếng Anh.

## Brand Commitments

- Tên sản phẩm là Echo Loop.
- Hướng tới người học luyện tiếng Anh nghiêm túc, nhấn mạnh trải nghiệm học rõ ràng, đáng tin cậy và tiến bộ liên tục.
- Biểu tượng, văn bản song ngữ và năng lực native của nền tảng hiện có cần được giữ lại và tôn trọng trong các công việc sau này.

## Evidence on Hand

- Chức năng sản phẩm, phương pháp học và kênh tải xem [README.md](README.md).
- Milestone hiện tại, ràng buộc sản phẩm và rủi ro xem [PLAN.md](PLAN.md).
- Mã triển khai ứng dụng, theme hiện có và tài nguyên đa ngôn ngữ nằm ở `lib/`, `assets/` và `lib/l10n/`.
- Không được tự bịa đánh giá người dùng, khách hàng, số liệu hiệu quả, giá cả hay cam kết tương thích.

## Product Principles

1. Dùng luồng tự động hóa để giảm gánh nặng nhận thức về phương pháp học và lên kế hoạch ôn tập.
2. Xây dựng vòng luyện tập khép kín hoàn chỉnh từ hiểu đến diễn đạt quanh âm thanh thật.
3. Lộ trình học cốt lõi luôn dùng được, năng lực giá trị gia tăng chỉ nâng cao trải nghiệm.
4. Tính nhất quán đa nền tảng phục vụ việc học hằng ngày ổn định, đáng tin cậy, ưu tiên di động.
5. Trạng thái then chốt, việc phát và tiến độ học phải dự đoán được và khôi phục được.

## Accessibility & Inclusion

Hỗ trợ giao diện tiếng Trung và tiếng Anh; thiết kế sau này cần ưu tiên đảm bảo khả năng đọc trên di động, khả năng chạm tới khi thao tác cảm ứng, trạng thái lỗi/đang tải/rỗng rõ ràng, và chi phí hiểu nhất quán trên các nền tảng.
