# AGENTS.md - Quy chuẩn làm việc của Codex

## 1. Mục tiêu và phạm vi

Bạn là Codex, hỗ trợ thực hiện các tác vụ phát triển phần mềm trong repository này. Mục tiêu là triển khai công việc một cách ổn định và đảm bảo mọi thay đổi đều có thể kiểm chứng.

**Các quy định bắt buộc:**

- Không chỉnh sửa các file thuộc hệ thống Claude Code: `CLAUDE.md`, `.claude/settings.json`, `.claude/settings.local.json`.
- Mỗi lần chỉ thực hiện một tác vụ, tránh tiện tay refactor những phần không liên quan.
- Chỉ chỉnh sửa các file liên quan trực tiếp đến tác vụ hiện tại, đảm bảo phạm vi thay đổi nhỏ nhất có thể.

## 2. Quy trình bắt đầu phiên làm việc (bắt buộc)

Trước khi bắt đầu bất kỳ công việc lập trình nào, phải thực hiện lần lượt:

1. Đọc `PLAN.md` để xác định milestone và giai đoạn hiện tại.
2. Đọc `TASKS.md` để xác định các công việc cần thực hiện và mức độ ưu tiên.
3. Giải thích ngắn gọn, dễ hiểu về tác vụ sẽ thực hiện.

## 3. Các ràng buộc khi phát triển

- **Ưu tiên kiểm thử:** Các chức năng và luồng xử lý quan trọng phải có test tương ứng.
- **An toàn kiểu dữ liệu:** Tránh sử dụng `dynamic`, ép kiểu bằng `as` và toán tử khẳng định không null `!`.
- **Thay đổi từng bước nhỏ:** Mỗi lần thay đổi phải đảm bảo code vẫn có thể chạy và kiểm tra được.
- **Quy chuẩn comment:** Logic cốt lõi được thêm mới hoặc chỉnh sửa phải có comment tiếng Trung rõ ràng, sử dụng Dart doc comment.
- **Quyền hạn và câu lệnh:** Tuân thủ nguyên tắc chỉ thực thi những câu lệnh tối thiểu cần thiết. Nghiêm cấm thực thi các câu lệnh có tính phá hủy (ví dụ: xóa hoặc reset khi chưa được cấp quyền).

## 4. Quy trình hoàn tất tác vụ (bắt buộc)

Sau khi hoàn thành tác vụ hiện tại, phải thực hiện lần lượt:

1. Kiểm tra tính đầy đủ của các bài test (unit / widget / integration).
2. Dọn dẹp dead code, bao gồm cả code test không còn được sử dụng.
3. Kiểm tra chất lượng comment của code mới thêm hoặc đã chỉnh sửa.
4. Mặc định chỉ chạy các bước kiểm tra liên quan trực tiếp đến thay đổi lần này:
   - `flutter analyze <các file liên quan đến thay đổi>`
   - `flutter test <các file test liên quan đến thay đổi>`
   - Nếu thay đổi ảnh hưởng đến ranh giới tích hợp giữa các thành phần, chạy thêm các integration test tương ứng.
   - Nếu thay đổi ảnh hưởng đến UI, routing hoặc luồng khởi động lần đầu, đồng thời có sẵn emulator hoặc thiết bị thật có thể sử dụng, cần chạy kiểm thử:
     - **Ưu tiên Android trên thiết bị thật:** Sử dụng `scripts/test_maestro_android.sh` để tự động build, cài đặt và chạy test. Nếu có nhiều thiết bị, sử dụng `--device <adb-serial>` để chọn thiết bị.
     - **Ứng dụng đã được cài đặt hoặc iOS:** Sử dụng `MAESTRO_APP_ID=<tên package mục tiêu> scripts/test_maestro.sh`.
     - Nếu không chạy được, phải nêu rõ nguyên nhân bị chặn do thiết bị hoặc công cụ CLI.
5. Chỉ chạy `scripts/check.sh` trong các trường hợp:
   - Chuẩn bị phát hành phiên bản.
   - Refactor trên phạm vi lớn.
   - Thay đổi ảnh hưởng đến nhiều module cốt lõi.
   - Người dùng yêu cầu rõ ràng.
6. Cập nhật `TASKS.md` (đánh dấu tác vụ đã hoàn thành và ghi lại thời gian hoàn thành).
7. Nếu trạng thái milestone thay đổi, cập nhật `PLAN.md`.
8. Xuất báo cáo tổng kết hoàn thành, bao gồm: tác vụ, các file đã thay đổi, kết quả kiểm thử và đề xuất bước tiếp theo.

## 5. Yêu cầu về báo cáo kết quả

Sau mỗi tác vụ hoàn thành, báo cáo phải bao gồm tối thiểu:

- Tiêu đề tác vụ đã triển khai.
- Danh sách các file đã chỉnh sửa.
- Các bài test đã thực hiện và kết quả tương ứng.
- Có chạy `scripts/check.sh` hay không. Nếu không chạy, phải giải thích lý do.
- Cách kiểm chứng tiếp theo mà người dùng có thể trực tiếp thực hiện.

## 6. Nguyên tắc phát triển Flutter

### 6.1. Nguyên tắc cốt lõi

1. Ưu tiên cấu trúc code rõ ràng, tránh thiết kế quá mức (over-engineering).
2. Phân chia thành phần dựa trên trách nhiệm, không dựa trên hình thức giao diện.
3. Duy trì luồng dữ liệu một chiều: UI kích hoạt action, controller cập nhật state, UI render dựa trên state.
4. Tách biệt UI và business logic. Widget không được chứa business logic phức tạp.
5. Ưu tiên các giải pháp đơn giản, trực tiếp và ổn định.
6. Thiết kế function phải tuân thủ nguyên tắc đơn trách nhiệm (Single Responsibility Principle).
7. Tuân thủ nguyên tắc DRY (Don't Repeat Yourself), ưu tiên tái sử dụng code, component và utility function đã có trong dự án. Không triển khai lại những chức năng đã tồn tại, tránh tạo ra nhiều nguồn xử lý logic cho cùng một chức năng, đảm bảo hành vi nhất quán và giảm chi phí bảo trì.

### 6.2. Trách nhiệm của từng tầng kiến trúc

1. **Screen/Page:** Chịu trách nhiệm tổ chức và kết hợp các thành phần của trang, xử lý tham số routing, đọc provider và phân phối callback.
2. **Widget:** Chịu trách nhiệm hiển thị và xử lý tương tác cục bộ, cố gắng giữ widget thuần (pure).
3. **Provider/Notifier:** Chịu trách nhiệm quản lý state và business logic.
4. **Repository:** Chịu trách nhiệm truy xuất và lưu trữ dữ liệu, không chịu trách nhiệm điều phối các quy trình nghiệp vụ.
5. **Model và State:** Model biểu diễn dữ liệu nghiệp vụ, State biểu diễn trạng thái hoạt động của giao diện. Model không phụ thuộc vào State, nhưng State có thể chứa Model.

### 6.3. Quản lý trạng thái (State Management)

1. Chia Provider theo từng miền chức năng (functional domain), không chia theo số lượng component hoặc hình thức giao diện.
2. Nếu state chỉ được sử dụng trong một widget tree và không cần chia sẻ giữa các component, hãy sử dụng local state. Ngược lại, sử dụng provider.
3. Mỗi trạng thái thực tế chỉ được có một nguồn dữ liệu duy nhất (Single Source of Truth), tránh duy trì cùng một state ở nhiều nơi.
4. Tập trung các điểm thay đổi state. State chỉ được thay đổi thông qua những method được định nghĩa rõ ràng.
5. Với các quy trình phức tạp, tách logic điều phối thành các class Dart thuần để dễ kiểm thử và tái sử dụng. Provider chịu trách nhiệm kết nối tầng điều phối với UI.

### 6.4. Thiết kế Widget

1. Page chịu trách nhiệm tổ chức các thành phần, Widget chịu trách nhiệm hiển thị.
2. Không tạo các component đa năng xử lý quá nhiều trường hợp bằng hàng loạt câu lệnh `if` hoặc các cờ chuyển đổi chế độ. Nếu một component có hơn 10 tham số, đó là dấu hiệu phạm vi trách nhiệm quá rộng và nên được tách nhỏ.
3. Method `build` chỉ được dùng để mô tả UI, không thực hiện request, thay đổi state hoặc kích hoạt side effect.
4. Widget con chỉ nên đọc những phần state mà nó thực sự quan tâm, tránh khiến toàn bộ trang rebuild không cần thiết.

### 6.5. Độ tin cậy (Reliability)

1. **Chống race condition:** Các thao tác bất đồng bộ phải có cơ chế phòng tránh race condition. Khi bắt đầu, ghi nhận định danh (`token/sessionId`); khi callback được gọi, kiểm tra định danh còn hợp lệ hay không. Nếu đã hết hiệu lực, bỏ qua kết quả.
2. **Quản lý vòng đời tài nguyên:** Thành phần nào tạo ra tài nguyên thì thành phần đó chịu trách nhiệm giải phóng. Vòng đời của tài nguyên phải gắn với đối tượng sở hữu, không được phụ thuộc vào việc quản lý ngầm từ bên ngoài.
3. **Quản lý side effect:** Các tác vụ có side effect như network request, file I/O hoặc platform call phải được inject thông qua interface hoặc callback, không gọi trực tiếp trong class xử lý business logic.
4. **Xử lý lỗi bất đồng bộ:** Mỗi điểm gọi async đều phải xem xét trường hợp thất bại. Việc âm thầm bỏ qua exception được xem là bug. Exception phải được xử lý rõ ràng hoặc truyền lên tầng phía trên.
5. **Thiết kế đầy đủ trạng thái:** Phải thiết kế rõ ràng các trạng thái error, loading và empty, không chỉ xử lý trường hợp thành công.
6. **Logging:** Ghi log tại các bước xử lý quan trọng để thuận tiện cho việc theo dõi, phát hiện và điều tra lỗi.

### 6.6. Khả năng bảo trì (Maintainability)

1. **Ưu tiên tên gọi rõ ràng hơn kỹ thuật phức tạp:** Tên biến, function và class phải thể hiện trực tiếp trách nhiệm của chúng.
2. **Tổ chức thư mục:** Ưu tiên tổ chức thư mục theo feature, sau đó phân tầng kiến trúc bên trong từng feature.
3. **Tránh trừu tượng hóa quá sớm:** Chấp nhận một lượng nhỏ code trùng lặp ban đầu. Chỉ tiến hành abstraction khi đã xác định được pattern ổn định. Abstraction quá sớm có thể gây hại nhiều hơn việc lặp code.
4. **Ưu tiên kiểm thử có giá trị:** Tập trung kiểm thử quá trình chuyển đổi state và business logic. Không cần bổ sung những test có giá trị thấp, chẳng hạn kiểm tra nội dung văn bản hiển thị.

### 6.7. Yêu cầu kiểm thử (Testing)

1. Viết những bài test thực sự có giá trị cho các hành vi được thêm mới hoặc chỉnh sửa.
2. Kiểm thử hành vi (behavior), không kiểm thử chi tiết triển khai (implementation details).
3. Không kiểm thử những chi tiết UI không quan trọng như kích thước font chính xác, màu sắc, khoảng cách hoặc các hằng số style khác, trừ khi chúng là yêu cầu sản phẩm rõ ràng hoặc liên quan đến lỗi hồi quy.
4. Bao phủ các trường hợp biên quan trọng (edge cases) và các luồng thất bại (failure paths), không chỉ kiểm thử happy path.
5. Ưu tiên sử dụng component thật khi khả thi, tránh lạm dụng Mock.
6. Khi sửa bug, phải bổ sung regression test. Bài test này phải thất bại trước khi sửa và chạy thành công sau khi sửa.
7. Test phải ổn định và có thể chạy lặp lại với kết quả nhất quán. Không thêm các khoảng delay tùy ý chỉ để khiến async test chạy thành công.
8. Không làm suy yếu, bỏ qua hoặc xóa các test hiện có chỉ nhằm mục đích khiến bộ test chạy thành công.
9. Ưu tiên một số lượng nhỏ các bài test có giá trị cao thay vì viết quá nhiều test hời hợt.
10. Không thêm test chỉ để tăng tỷ lệ code coverage. Mỗi bài test phải bảo vệ một hành vi quan trọng hoặc có khả năng phát hiện những lỗi hồi quy thực tế có thể xảy ra.
11. Trước khi hoàn thành tác vụ, hãy được cho tôi lệnh chạy test case khi tôi chạy xong sẽ báo lại kết quả