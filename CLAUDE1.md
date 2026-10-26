## CLAUDE.md - Quy chuẩn làm việc của Claude Code

### 1. Nguyên tắc cốt lõi

Bạn là Claude Code, hỗ trợ thực hiện các tác vụ phát triển phần mềm trong repository này. Mục tiêu hàng đầu là triển khai công việc ổn định theo kế hoạch và đảm bảo mọi thay đổi đều có thể kiểm chứng.

1. Quản lý dựa trên file — Ghi các quyết định vào `PLAN.md` / `TASKS.md`, không phụ thuộc vào bộ nhớ hội thoại.
2. Tập trung một tác vụ — Mỗi lần chỉ làm một việc, hoàn thành rồi mới chuyển sang việc tiếp theo.
3. Kiểm thử trước — Viết test để xác định hành vi mong đợi trước khi triển khai code, đảm bảo tính chính xác.
4. Tách biệt chức năng — Mỗi module phải có thể kiểm thử độc lập, không phụ thuộc vào logic không liên quan. Mỗi file tối đa 500 dòng, mỗi function tối đa 50 dòng.
5. Kiểm chứng từng bước — Sau mỗi thay đổi, code phải chạy được và kiểm tra được ngay. Không tích lũy các thay đổi lớn.
6. Comment đầy đủ — File, function và logic cốt lõi phải có comment tài liệu bằng tiếng Việt, tuân thủ chuẩn Dart doc comment.
7. Đồng bộ tài liệu — Sau khi chỉnh sửa code, lập tức cập nhật `TASKS.md` (đánh dấu hoàn thành, ghi thời gian) và `PLAN.md` (tiến độ milestone).
8. Thay đổi tối thiểu — Chỉ chỉnh sửa file và code liên quan đến tác vụ hiện tại, không refactor ngoài phạm vi.
9. An toàn kiểu dữ liệu — Tránh `dynamic`, ép kiểu `as` và toán tử khẳng định không null `!`. Ưu tiên cách viết đảm bảo type safety.
10. Logging phục vụ chẩn đoán — Ghi log tại các điểm quan trọng để thuận tiện phát hiện và điều tra lỗi.

## 2. Nguyên tắc phát triển ứng dụng Flutter

### 2.1. Nguyên tắc cốt lõi

1. Ưu tiên cấu trúc code rõ ràng, tránh thiết kế quá mức.
2. Phân chia thành phần theo trách nhiệm, không dựa trên hình thức giao diện.
3. Duy trì luồng dữ liệu một chiều: UI kích hoạt action, controller cập nhật state, UI render dựa trên state.
4. Tách biệt UI và business logic. Widget không chứa business logic phức tạp.
5. Ưu tiên giải pháp đơn giản, trực tiếp và ổn định.

### 2.2. Trách nhiệm của từng tầng kiến trúc

6. Screen/Page: Tổ chức các thành phần trang, xử lý tham số routing, đọc provider và phân phối callback.
7. Widget: Hiển thị giao diện và xử lý tương tác cục bộ, cố gắng giữ widget thuần.
8. Provider/Notifier: Quản lý state và business logic.
9. Repository: Truy xuất và lưu trữ dữ liệu, không điều phối quy trình nghiệp vụ.
10. Model và State: Model biểu diễn dữ liệu nghiệp vụ, State biểu diễn trạng thái hoạt động của giao diện. Model không phụ thuộc State, nhưng State có thể chứa Model.

### 2.3. Quản lý trạng thái

11. Chia Provider theo miền chức năng, không theo số lượng component hoặc hình thức giao diện.
12. Nếu state chỉ được sử dụng trong một widget tree và không cần chia sẻ giữa các component, sử dụng local state; ngược lại sử dụng provider.
13. Mỗi trạng thái thực tế chỉ có một nguồn dữ liệu duy nhất (Single Source of Truth), tránh duy trì cùng một state ở nhiều nơi.
14. Tập trung các điểm thay đổi state, chỉ cho phép thay đổi thông qua những method được định nghĩa rõ ràng.
15. Với quy trình phức tạp, tách logic điều phối thành class Dart thuần để có thể kiểm thử và tái sử dụng. Provider kết nối tầng điều phối với UI.

### 2.4. Thiết kế Widget

16. Page chịu trách nhiệm tổ chức, component chịu trách nhiệm hiển thị.
17. Không tạo component đa năng với quá nhiều câu lệnh `if` và cờ chuyển đổi chế độ. Nếu component có hơn 10 tham số, đó là dấu hiệu trách nhiệm quá rộng và nên được tách nhỏ.
18. Method `build` chỉ mô tả UI, không thực hiện request, thay đổi state hoặc kích hoạt side effect.
19. Widget con chỉ đọc phần state thực sự cần thiết, tránh khiến toàn bộ trang rebuild không cần thiết.

### 2.5. Độ tin cậy

20. Phòng tránh race condition: Khi bắt đầu thao tác bất đồng bộ, ghi nhận định danh (`token/sessionId`). Khi callback được gọi, kiểm tra định danh còn hợp lệ hay không; nếu hết hiệu lực thì bỏ qua kết quả.
21. Quản lý vòng đời tài nguyên: Thành phần nào tạo tài nguyên thì thành phần đó chịu trách nhiệm giải phóng. Vòng đời tài nguyên phải gắn với đối tượng sở hữu, không được quản lý ngầm từ bên ngoài.
22. Quản lý side effect: Network request, file I/O và platform call phải được inject thông qua interface hoặc callback, không gọi trực tiếp trong class xử lý business logic.
23. Xử lý lỗi bất đồng bộ: Mọi điểm gọi async phải xem xét trường hợp thất bại. Âm thầm bỏ qua exception được xem là bug; phải xử lý rõ ràng hoặc truyền lên tầng trên.
24. Thiết kế trạng thái đầy đủ: Phải xử lý rõ ràng error, loading và empty state, không chỉ triển khai success state.

### 2.6. Khả năng bảo trì

25. Ưu tiên tên gọi rõ ràng hơn kỹ thuật phức tạp. Tên phải thể hiện trực tiếp trách nhiệm.
26. Ưu tiên tổ chức thư mục theo feature, sau đó phân tầng bên trong từng feature.
27. Chấp nhận một lượng nhỏ code trùng lặp ban đầu, chỉ abstraction khi pattern đã ổn định. Abstraction quá sớm có thể gây hại hơn việc lặp code.
28. Ưu tiên kiểm thử quá trình chuyển đổi state và business logic, không chỉ kiểm tra bề ngoài UI.

### 2.7. Yêu cầu kiểm thử

29. Viết những bài test thực sự có giá trị cho các hành vi được thêm mới hoặc chỉnh sửa.
30. Kiểm thử hành vi, không kiểm thử chi tiết triển khai.
31. Không kiểm thử những chi tiết UI không quan trọng như kích thước font chính xác, màu sắc, khoảng cách hoặc các hằng số style khác, trừ khi đó là yêu cầu sản phẩm rõ ràng hoặc lỗi hồi quy.
32. Bao phủ các edge case quan trọng và failure path, không chỉ kiểm thử happy path.
33. Ưu tiên sử dụng component thật khi khả thi, tránh lạm dụng Mock.
34. Khi sửa bug, phải bổ sung regression test. Test phải thất bại trước khi sửa và thành công sau khi sửa.
35. Test phải ổn định và có thể chạy lặp lại. Không thêm delay tùy ý chỉ để async test thành công.
36. Không làm suy yếu, bỏ qua hoặc xóa test hiện có chỉ nhằm khiến bộ test chạy thành công.
37. Ưu tiên một số lượng nhỏ test có giá trị cao thay vì nhiều test hời hợt.
38. Không thêm test chỉ để tăng code coverage. Mỗi test phải bảo vệ hành vi quan trọng hoặc phát hiện lỗi hồi quy có khả năng xảy ra thực tế.
39. Trước khi hoàn thành tác vụ, phải chạy các test liên quan và đảm bảo tất cả đều thành công.

Phiên bản tài liệu: v4.4

Ngày cập nhật: 2026-06-27

## 3. Quy trình bắt đầu phiên làm việc (bắt buộc)

Trước khi bắt đầu bất kỳ công việc nào, phải thực hiện lần lượt các bước sau:

1. Đọc `PLAN.md` để nắm giai đoạn hiện tại và kế hoạch tổng thể của dự án.
2. Đọc `TASKS.md` để nắm danh sách công việc và mức độ ưu tiên.
3. Giải thích bằng ngôn ngữ đơn giản tác vụ cần thực hiện.

## 4. Quy trình hoàn tất tác vụ (bắt buộc)

Sau khi hoàn thành tác vụ hiện tại, phải thực hiện lần lượt các bước sau.

### Bước 1: Kiểm tra tính đầy đủ của test

Xác nhận mức độ bao phủ của các loại test:

- Unit Test: Kiểm thử logic thuần như model, service và utility class, không liên quan UI.
- Widget Test: Kiểm thử UI ở cấp component.
- Integration Test: Kiểm thử end-to-end (E2E), xác minh toàn bộ luồng sử dụng.

### Bước 2: Xóa dead code

Kiểm tra code không còn được sử dụng, bao gồm cả code trong test, và xóa nếu có.

### Bước 3: Kiểm tra comment và tài liệu

Đảm bảo code mới thêm hoặc chỉnh sửa có comment tiếng Trung rõ ràng.

### Bước 4: Chạy các lệnh kiểm chứng

```
flutter analyze
flutter test
flutter test integration_test -d macos
```

### Bước 5: Cập nhật TASKS.md

Bắt buộc:

1. Đánh dấu các tác vụ đã hoàn thành bằng `- [x]`.
2. Thêm thông tin hoàn thành bên dưới tác vụ.

```
**Thời gian hoàn thành**: 2026-01-31
```

### Bước 6: Cập nhật PLAN.md (nếu cần)

Nếu tác vụ làm thay đổi tiến độ milestone, phải cập nhật trạng thái milestone tương ứng trong `PLAN.md`.

### Bước 7: Xuất báo cáo tổng kết

```
**Tác vụ đã thực hiện**: [Tiêu đề tác vụ]

**Các file đã chỉnh sửa** (X file):
- path/to/file.dart (+50 -10)

**Các bài test tương ứng**:
- path/to/test_file.dart

**Đề xuất bước tiếp theo**:
- Hướng dẫn người dùng kiểm chứng kết quả
- Xác định tác vụ tiếp theo
```

## 5. Quy tắc lưu trữ TASKS.md

Bắt buộc thực hiện lưu trữ (archive) khi đáp ứng ít nhất một điều kiện:

1. Hoàn thành milestone: Một milestone trong `PLAN.md` đã hoàn thành toàn bộ.
2. File quá lớn: `TASKS.md` vượt quá 200 dòng.
3. Quá nhiều tác vụ: Số lượng tác vụ hoàn thành vượt quá 30.
4. Yêu cầu thủ công: Người dùng yêu cầu archive rõ ràng.

Quy trình archive:

1. Tạo file `docs/tasks-archive/milestone-X-completed.md`.
2. Di chuyển các tác vụ đã hoàn thành vào file archive.
3. Dọn dẹp `TASKS.md`, chỉ giữ lại tác vụ chưa hoàn thành.
4. Thêm liên kết đến file archive ở đầu `TASKS.md`.
5. Cập nhật trạng thái milestone trong `PLAN.md`.

## 6. Quy chuẩn lập trình

### 6.1. Quy ước Dart / Flutter

- Sử dụng `flutter_lints` để phân tích tĩnh, cấu hình trong `analysis_options.yaml`.
- Format code bằng `dart format .`.
- Quốc tế hóa (i18n): Sử dụng `flutter_localizations` và file ARB trong `lib/l10n/`. File template là `app_en.arb`, hiện hỗ trợ `en` / `zh`.

### 6.2. Quy ước kiểm thử

- Framework: `flutter_test` + `mocktail`.
- Tên file theo mẫu `*_test.dart`, đặt trong thư mục con tương ứng của `test/`.
- Mỗi tính năng mới hoặc bug fix đều phải có test tương ứng.

### 6.3. Sinh code Riverpod

- Provider sử dụng `riverpod_generator` để generate code, file phải có khai báo `part 'xxx.g.dart';`.
- Sau khi chỉnh sửa Provider, chạy:

```
dart run build_runner build
```

### 6.4. Lưu ý về mạng trên iOS

- `HttpClient` của Flutter `dart:io` bỏ qua network stack native của iOS, vì vậy không kích hoạt hộp thoại xin quyền mạng của hệ thống.
- Cần gọi `URLSession` native của iOS thông qua Method Channel để kích hoạt hộp thoại này.
- Giải pháp hiện tại: Khi ứng dụng khởi động, gửi native request thông qua channel `top.echo-loop/network` (xem `AppDelegate.swift` và `main.dart`).

## 7. Troubleshooting – Các vấn đề và kinh nghiệm đã ghi nhận

Ghi lại các lỗi điển hình đã được sửa và những ràng buộc thiết kế để tránh tái diễn.

> Đây là phiên bản rút gọn. Bản đầy đủ nằm tại `docs/reference/claude-2026-07-12-full.md`.

### 7.1. Nhận dạng giọng nói iOS: Callback bất đồng bộ làm hỏng session mới

- Callback từ `cancel()` của session cũ có thể chạy bất đồng bộ và làm ảnh hưởng session mới.
- Quy tắc: Sử dụng generation counter. Không trực tiếp dọn dẹp tài nguyên trong nhánh xử lý lỗi.

### 7.2. flutter_tts: Gọi stop → speak quá nhanh khiến awaitSpeakCompletion mất hiệu lực

- Callback đến muộn của `stop()` có thể hoàn thành completer của thao tác mới.
- Quy tắc: Không phụ thuộc vào cơ chế báo hoàn thành nội bộ của plugin để phân tách các thao tác. Phải tự quản lý trạng thái in-flight.

### 7.3. Android versionCode phải tăng đơn điệu trên toàn bộ phiên bản, độc lập với versionName

- Android chỉ dựa vào `versionCode` để xác định khả năng nâng cấp ứng dụng.
- Quy tắc: Git tag sử dụng SemVer thuần; `versionCode` sử dụng commit count và không được giảm.

### 7.4. Offline ASR: sherpa-onnx Silero VAD native bị abort trên một số thiết bị (chưa giải quyết)

- Đã xác nhận vấn đề tập trung ở quá trình native inference của Silero VAD.
- Quy tắc: Không thể xử lý native crash bằng `try/catch`. Phải sử dụng `logcat` và `/data/tombstones` để xác định nguyên nhân.

### 7.5. Xóa cache nhầm vào URLCache hệ thống gây disk I/O error

- Không được xóa trực tiếp thư mục gốc `Library/Caches`.
- Quy tắc: Chỉ xóa thư mục cache do ứng dụng tự tạo. Cache của hệ thống hoặc framework phải được dọn dẹp thông qua API tương ứng.

### 7.6. just_audio: Đếm số lần lặp toàn bộ bài bằng sự kiện completed không đáng tin cậy

- Sự kiện `completed` có thể xuất hiện lặp lại hoặc đến muộn; `playing` vẫn có thể là `true` sau khi phát xong.
- Quy tắc: Với số lần lặp hữu hạn, sử dụng coroutine `await playToEnd` có tính xác định, không điều khiển bằng sự kiện `completed`.

### 7.7. Màn hình khóa: Báo completed khiến thanh tiến trình đôi khi bị kẹt ở cuối

- Khi system media session nhận trạng thái `completed`, thanh tiến trình có thể bị cố định ở cuối.
- Quy tắc: Không báo `completed` cho màn hình khóa. Logic nội bộ đọc trực tiếp trạng thái gốc của player.

### 7.8. Resource shrinking ở bản release xóa notification icon khiến toàn bộ media control biến mất

- Android resource được tham chiếu bằng chuỗi tại runtime có thể bị resource shrinking xóa nhầm trong bản release.
- Quy tắc: Các resource này phải được thêm vào danh sách giữ lại trong `res/raw/keep.xml`.

### 7.9. Ba vấn đề khi ẩn media control trên màn hình khóa đối với tác vụ ghi âm

Liên quan đến channel `MediaItem` / `position` của iOS và thứ tự “load trước, suppress sau” trên Android.

- Vấn đề này đã được thay thế về mặt kiến trúc bởi giải pháp tách engine tại mục 7.12.
- Quy tắc: Nếu tác vụ ghi âm vẫn sử dụng cơ chế suppress, phải suppress trước khi load và chặn cả hai channel `mediaItem` và `playbackState`.

### 7.10. Phát âm thanh nền cho tác vụ học: Âm lượng giữ hoạt động phải là 1.0

- Cơ chế giữ hoạt động bằng âm thanh im lặng trên iOS và callback chuyển câu từ màn hình khóa đều có yêu cầu về thứ tự thời điểm thực thi.
- Quy tắc: Giữ âm lượng theo giá trị đã xác định. Callback chuyển câu từ màn hình khóa chỉ được bind một lần cho mỗi tác vụ.

### 7.11. Tác vụ ghi âm vẫn xuất hiện trên màn hình khóa

Nguyên nhân: `suppress(false)` khi ở trạng thái `idle` phát lại `MediaItem`, tạo media card còn sót không thể xóa.

- Phát lại `MediaItem` trong trạng thái `idle` có thể để lại media card không thể xóa.
- Quy tắc: Việc xóa card phải dựa trên vòng đời chuyển trạng thái hợp lệ từ non-idle sang idle. Không phát bổ sung `MediaItem` khi đang idle.

### 7.12. Tách media engine và foreground engine

Biến việc “có xuất hiện trên màn hình khóa hay không” thành thuộc tính kiến trúc thay vì runtime switch.

- Đây là giải pháp chính thức hiện tại để tách biệt phát thử ở foreground và điều khiển trên màn hình khóa.
- Quy tắc: Phát thử ở foreground phải tách biệt vật lý với system media session, không tiếp tục phụ thuộc vào suppress switch để xử lý.

### 7.13. Phát âm thanh theo đoạn: Đăng ký position tracking trước khi seek(0) hoàn tất

Hậu quả: Highlight nhảy sai và vị trí tiếp tục phát bị ghi đè thành câu đầu tiên.

- Việc đăng ký subscription trước khi seek hoàn tất có thể khiến sự kiện vị trí cũ làm sai lệch trạng thái hiện tại.
- Quy tắc: Chỉ bắt đầu position tracking sau khi seek hoàn tất, tránh sự kiện cũ ghi đè state mới.

### 7.14. Dùng stop để ngắt trong phiên nghe thụ động khiến media session liên tục bị tạo lại

- Nếu dùng `stop` để ngắt trong cùng session, system media session sẽ liên tục bị hủy và tạo lại.
- Quy tắc: Ưu tiên `pause` thay vì `stop` khi tạm ngắt trong cùng session.

### 7.15. Phát audio theo clip khiến tiến trình màn hình khóa về 0 khi chuyển câu

- Không thể chỉ báo vị trí tương đối của clip.
- Quy tắc: Luôn báo vị trí tuyệt đối và tổng thời lượng toàn bộ audio cho màn hình khóa.

### 7.16. Thanh tiến trình vẫn chạy khi đang đếm ngược thời gian tạm dừng

- Nếu vẫn báo tốc độ phát bình thường trong lúc đếm ngược, hệ thống sẽ tiếp tục tăng vị trí phát.
- Quy tắc: Trong giai đoạn tạm dừng, báo rõ `speed=0` để đóng băng tiến trình.

### 7.17. Flatten route trang chi tiết lên cấp cao nhất khiến nút Back quay lùi thừa một cấp

Ví dụ: Từ trang kế hoạch học tập quay về thư viện tài nguyên.

- Flatten route cấp cao nhất làm mất cấu trúc navigation stack.
- Khi framework phân tích lại URI với null-state (chẳng hạn Android Activity được OS tạo lại), URI đã flatten không chứa thông tin phân cấp của entry stack. Navigation stack có thể bị thu gọn về shell root, khiến Back quay lùi thừa một cấp.

Quy tắc bắt buộc:

- Mọi trang fullscreen được push từ nested stack phải được khai báo là nested child route của trang entry.
- URL phải tự biểu diễn đầy đủ cấu trúc navigation stack.
- Trang fullscreen mới phải sử dụng `AppRoutes.pushNested(context, segment)` để nối segment tương đối vào `matchedLocation` hiện tại.
- Nếu thiếu khai báo child route, hệ thống phải báo lỗi `no route` ngay thay vì âm thầm làm hỏng navigation stack.
- `extra` của child page có thể bị mất sau khi route được phân tích lại vì không thể serialize.
- Builder phải có fallback, tham khảo `_RestoredRoutePopper`: nếu `extra` rỗng, pop về entry page đã được khôi phục ở frame đầu tiên.

Đã áp dụng cho bảy trang audio như plan/player/blind/retell (1.0.21), cùng `sentence-detail` và `pdf-preview`.

Regression test: `test/router/app_router_test.dart`.

### 7.18. TTS thống nhất: Component phát âm nhúng không được truy cập platform/database trong provider build

- Truy cập platform hoặc database trong quá trình build provider sẽ gây side effect trong lúc khởi tạo trang.
- Quy tắc: Khởi tạo khả năng phát âm theo cơ chế lazy initialization, không thực hiện side effect trong provider build.

### 7.19. macOS flutter_tts: synthesizeToFile không thiết lập voice

- Plugin macOS trước đây không thiết lập voice chính xác, khiến file âm thanh giọng Anh-Anh và Anh-Mỹ được tổng hợp giống hệt nhau.
- Quy tắc: Với luồng này, tiếp tục ưu tiên giải pháp tổng hợp giọng nói native tự triển khai.

### 7.20. Tích hợp Echo Loop TTS (Kokoro / sherpa-onnx)

Ràng buộc thiết kế, xem `PLAN.md` ADR-9.

- Tích hợp TTS local liên quan đến tải model, cache và tính nhất quán của luồng phát.
- Quy tắc: Tích hợp theo kiến trúc TTS thống nhất, không tạo nhánh xử lý phát âm thanh chính riêng biệt.

### 7.21. Đóng gói Kokoro bằng tar trên macOS gây FormatException

- `tar` trên macOS có thể thêm PAX extended header, trong khi bộ giải nén không nhất thiết hỗ trợ.
- Quy tắc: Tạo archive model theo định dạng tương thích đã được quy định.

### 7.22. Nghe thử và warm-up giọng TTS

- Nếu preview và warm-up bỏ qua render pipeline thống nhất, cache và accent có thể bị lẫn.
- Quy tắc: Truyền voice rõ ràng qua config vào `synthesize`, và luôn sử dụng render pipeline thống nhất.

### 7.23. Preview accent của platform TTS: engine.stop() làm gián đoạn synthesizeToFile

- `engine.stop()` có thể ngắt `synthesizeToFile` đang chạy, khiến Future bị treo vĩnh viễn.
- Quy tắc: Dừng player trước, sau đó chờ render hoàn tất. Không gọi stop engine tùy tiện khi còn synthesize in-flight.

### 7.24. macOS Platform TTS tự triển khai synthesizeToFile bằng native channel

- macOS đã được bổ sung khả năng tổng hợp file và cache bằng native channel.
- Quy tắc: Khả năng tổng hợp giọng nói trên macOS phải dựa trên native implementation do dự án tự triển khai.

### 7.25. Tương tác từ điển: Panel cố định non-modal và selection handle theo từ

- Giải pháp chính thức hiện tại là panel cố định được nhúng trong `Stack`, kết hợp selection handle tự căn theo ranh giới từ.
- Quy tắc: Những trường hợp mới cho phép nhấn vào từ phải tái sử dụng `SelectableSentenceText`. Khi nhấn ngoài panel để đóng, phải có vùng hit-test được miễn trừ.

### 7.26. AI Dictionary streaming bằng NDJSON partial object snapshot

- Streaming dictionary đã chuyển sang NDJSON và xử lý các trường hợp hủy, cache và ranh giới error body.
- Quy tắc: Không để luồng logging hoặc serialization dùng chung vô tình consume stream response.

### 7.27. Streaming AI Dictionary: Chuyển từ cumulative snapshot sang field-level increment

- Giao thức hiện tại sử dụng cơ chế thiết lập giá trị leaf theo path, tránh việc gửi lại dữ liệu với độ phức tạp O(n²).
- Quy tắc: Những đối tượng streaming có cấu trúc sau này phải ưu tiên incremental leaf protocol, không quay lại gửi snapshot toàn bộ object.

### 7.28. Kiến trúc selection ba tầng: Selection model riêng và platform handle renderer

Thay thế `SelectableText`.

Nguyên nhân gốc:

Hai cơ chế selection chính thức của Flutter đều xóa vùng chọn khi mất focus:

- `material/selectable_text.dart` — `_handleFocusChanged`
- `widgets/selectable_region.dart` — `_handleFocusChanged`

Ngoài ra, khi `textSpan` thay đổi, `SelectableText.didUpdateWidget` tạo lại controller và reset selection vì `_TextSpanEditingController._textSpan` là `final`.

Điều này xung đột trực tiếp với yêu cầu: người dùng chọn văn bản, sau đó tra từ, chuyển nguồn hoặc lưu từ trong panel ngay trên trang mà selection vẫn phải được giữ nguyên.

Các giải pháp trước đó chỉ có thể khắc phục bằng cách đồng bộ ngược trạng thái selection, dẫn đến bảy bản vá trong một đêm ngày 29/07/2026.

Quy tắc kiến trúc:

Khi selection cần tồn tại xuyên suốt các tương tác, cần ranh giới từ tùy chỉnh hoặc toolbar tùy chỉnh, phải sử dụng:

Selection model riêng + bộ vẽ handle `TextSelectionControls` của platform.

Không sử dụng `SelectableText` hoặc `SelectionArea`.

Kiến trúc chia ba tầng:

- L1 – Session: Single Source of Truth, chỉ lưu khoảng ký tự và định danh nội dung, không chứa khái niệm focus. Có ba trạng thái `idle/selecting/active`.
- L2 – Presentation: Platform handle, tight highlight, toolbar và magnifier.
- L3 – SelectionBackend: Xử lý hit-test, ranh giới từ, geometry và trích xuất text. Đây là điểm khác biệt duy nhất giữa selection một đoạn và selection nhiều block.

Một nguồn xác định ranh giới từ:

- Khi nhấn chọn từ, luôn sử dụng tokenizer nghiệp vụ của dự án.
- Không sử dụng `selectWord()` hoặc ranh giới ICU.
- ICU tách `co-op` thành `co` / `-` / `op` và `e.g.` thành `e` / `.` / `g`, khiến highlight, truy vấn và hai điểm lưu từ có thể sử dụng các từ khác nhau.

Toolbar phải được mount ở page-level host:

- Toolbar có thể tràn khỏi render box của nội dung.
- Ancestor giới hạn hit-test theo box riêng, khiến phần toolbar tràn khỏi `Stack` không nhận được thao tác.
- `UnboundedHitStack` chỉ bỏ giới hạn tại chính tầng của nó, đủ cho handle nhưng không đủ cho toolbar.
- Root Overlay lại có thể che panel bên trong trang.

Thứ tự layer chính xác:

`Nội dung → Barrier đóng panel → Toolbar → Panel`

Khả năng hiển thị và tương tác được quyết định hoàn toàn bằng thứ tự layer, không cần đồng bộ geometry.

- Anchor được truyền bằng tọa độ global, host chịu trách nhiệm chuyển đổi.
- Không chuyển đổi ngay trong lần build đầu của layer vì `findRenderObject()` vẫn có thể là `null`.
- Toolbar nằm ngoài Scrollable, nên phải chủ động ẩn khi nội dung cuộn khỏi viewport bằng `rectsVisibleInViewport`.

Không sử dụng `SelectionOverlay`:

- `SelectionOverlay` gắn handle vào Overlay gần nhất chứa context.
- Handle có thể bị đưa lên root Overlay, khiến việc che phủ và theo dõi scroll phải tính toán thủ công.
- Thay vào đó, đặt handle như widget thông thường trong content Stack.

Đồng bộ hành vi theo platform:

- Long-press drag selection trên Android/Fuchsia/Linux/Windows hoạt động theo từ.
- Trên iOS/macOS, selection hoạt động theo ký tự, tương tự `selectWordsInRange` / `selectPositionAt` của framework.
- Kéo selection handle luôn hoạt động theo ký tự trên mọi platform.
- Hit area của handle được tính từ `getHandleAnchor` / `getHandleSize` rồi mở rộng thành 36dp; framework sử dụng 48dp.

Tight highlight:

- Protocol `Selectable` hardcode `boxHeightStyle: max` trong `rendering/paragraph.dart`.
- Khi không sử dụng protocol này, backend một đoạn và nhiều block có thể trực tiếp đọc paragraph geometry để dùng tight highlight nhất quán.

Phải tự bổ sung tương tác desktop:

Những hành vi `SelectableText` cung cấp sẵn nhưng custom implementation phải tự triển khai:

- Mouse drag-select bằng `PanGestureRecognizer`, giới hạn `PointerDeviceKind.mouse`.
- Bắt buộc sử dụng `DragStartBehavior.down`.
- Nếu dùng `.start` mặc định, vị trí bắt đầu được ghi nhận tại thời điểm gesture được nhận diện, khiến selection anchor lệch và phần di chuyển kích hoạt gesture không được gửi qua `onUpdate`.
- Xử lý trường hợp chuột rung nhẹ khi click: mouse slop chỉ là 1 logical pixel (`kPrecisePointerHitSlop`), nên rung 2px có thể khiến pan thắng tap. Nếu pan kết thúc mà không tạo selection, phải xử lý như click.
- I-beam cursor.
- Double-click chọn từ.
- Shift+click mở rộng selection.
- Shift+phím mũi tên mở rộng selection.
- Cmd+C.

Các tính năng trên được hoàn thiện ngày 30/07/2026.

Chưa triển khai: triple-click chọn đoạn, Cmd+A và kéo văn bản đã chọn.

Không sử dụng `DoubleTapGestureRecognizer`:

- Recognizer này giữ gesture arena, khiến single-click phải đợi hết thời gian double-click khoảng 300ms.
- Điều đó khiến thao tác nhấn từ để tra cứu bị chậm.
- Thay vào đó, tự nhận diện double-click trong tap bằng time window và slop (`TapCadence`), đảm bảo single-click không có độ trễ.

Mở rộng selection bằng bàn phím không có caret state:

- Implementation chỉ có selection, không có caret.
- Khi chưa có selection, Shift+phím mũi tên không thực hiện gì.
- Nếu thu selection về đầu cố định khiến khoảng chọn bằng 0, xử lý như kết thúc session.
- Di chuyển lên/xuống phải dựa trên caret geometry (`caretRectAt` + `offsetAt`), không giả định cấu trúc dòng, để hỗ trợ di chuyển giữa các block.
- Cmd/Ctrl+C giữ nguyên selection theo hành vi chuẩn platform.
- Hành động “copy và kết thúc session” trên toolbar là hành vi nghiệp vụ riêng.
- Focus chỉ dùng để điều hướng keyboard event.
- Chỉ gọi `requestFocus` khi tương tác bằng chuột, vì gọi trên touchscreen có thể đóng bàn phím ảo.

Long-press vào khoảng trắng giữa các từ:

- Không được return trực tiếp vì sẽ tạo gesture không có phản hồi.
- Đặt anchor tại ký tự tương ứng; khi kéo vượt qua ký tự đầu tiên thì mới tạo selection session.

Cross-block backend cho AI response không sử dụng `SelectionContainer` / `Selectable`:

Ngoài vấn đề max highlight và mất selection khi mất focus, registry chính thức có thể gặp reentrant modification khi các child node được thêm hoặc xóa ở cuối frame streaming Markdown, gây `ConcurrentModificationError` (đã sửa ở T16).

Giải pháp: Đọc trực tiếp render tree và xây dựng không gian ký tự phẳng.

Ba điểm cần lưu ý:

1. Thứ tự tài liệu phải được xác định đệ quy theo placeholder. `gpt_markdown` render toàn bộ đoạn thành root `RichText`. Các block như heading, list, quote, table là placeholder `WidgetSpan`, bên trong lại chứa `RichText`. Vì vậy child block nằm trong parent paragraph. Không thể sắp xếp theo thứ tự duyệt render tree. Phải chia parent text tại placeholder và chèn child block vào đúng vị trí. Thứ tự placeholder child của `RenderParagraph` tương ứng với thứ tự trong span.
2. Hit-test phải dựa trên rectangle của text thuộc chính paragraph, không dùng paragraph box. Trong cấu trúc lồng nhau, parent box có thể bao phủ child block và gây hit-test nhầm.
3. Bổ sung newline giữa hai paragraph liền kề nếu không có khoảng trắng hoặc xuống dòng, chẳng hạn các ô table liên tiếp. Newline này chiếm offset trong không gian ký tự phẳng nhưng không thuộc paragraph nào.

Thông báo content change hoặc unmount phải trì hoãn một frame:

- Gọi trực tiếp `onHideToolbar` hoặc `onSessionEnded` trong `didUpdateWidget` / `dispose` có thể kích hoạt `setState` ở ancestor host trong lúc build, gây lỗi `markNeedsBuild called during build`.
- AI response streaming có thể đi qua luồng này ở mỗi frame.

Khi toàn bộ content bị unmount cũng phải ẩn toolbar:

- Không chỉ xử lý trong `didUpdateWidget` mà cả `dispose`.
- Khi tạo cuộc hội thoại mới, Chat có thể xóa toàn bộ message và unmount AI response, khiến toolbar bị bỏ lại trên trang trống.
- Callback ẩn toolbar phải mang thông tin owner, không phụ thuộc `currentState` / `context` vì cả hai không còn hợp lệ sau unmount.
- Host phải kiểm tra `mounted` khi show/hide vì callback trì hoãn có thể chạy sau khi host bị dispose.

Trừu tượng hóa điểm mount toolbar:

Sử dụng `SelectionToolbarMount` và `SelectionToolbarScope`.

- Trang tra từ sử dụng `DictionaryPanelHost`, với thứ tự layer: nội dung → barrier → toolbar → panel.
- Trang không có panel, chẳng hạn `ChatView`, sử dụng `SelectionToolbarHost` dùng chung.
- Content component chỉ phụ thuộc interface, không cần biết mình đang nằm trong loại trang nào.

Đánh đổi đã được chấp nhận:

- Không cung cấp accessibility semantics của system selection.
- Bản thân sentence text vẫn có thể được screen reader đọc.
- Toàn bộ API phụ thuộc đều là public API: `RenderParagraph` geometry, `TextSelectionControls`, `TextMagnifier`, `DefaultSelectionStyle`.
- Không phụ thuộc private state.

Code liên quan:

Thư mục chính: `lib/widgets/selection/`.

- Core: `selectable_content` (kết hợp L1+L2 và gesture semantics), `text_selection_session` (L1).
- L2: `selection_presentation`, `selection_gesture_detector`, `selection_extend`, `selection_keyboard`, `platform_selection_handles`, `selection_highlight`, `selection_magnifier`, `selection_toolbar(_layer/_host)`, `selection_geometry`, `unbounded_hit_stack`.
- L3: `selection_backend`, `paragraph_selection_backend` (một đoạn), `multi_paragraph_selection_backend` (nhiều block).
- Component tổng hợp: `app_selectable_text`.
- Wrapper nghiệp vụ tra từ: `lib/widgets/practice/selectable_sentence_text.dart`.
- Wrapper AI response: `lib/features/chatbot/widgets/selectable_assistant_markdown.dart`.
- Toolbar mount và `isPanelOpenOf`: `lib/widgets/dictionary/dictionary_panel_host.dart`.

Test liên quan:

- `test/widgets/selection/` (`text_selection_session_test`, `selectable_content_desktop_test`).
- `test/widgets/practice/selectable_sentence_text_test.dart`.
- `test/features/chatbot/widgets/selectable_assistant_markdown_test.dart`.

Những nơi vẫn sử dụng `SelectableText` có chủ đích:

Trang cài đặt, trang debug, thông tin podcast và các văn bản chỉ đọc khác.

Những nơi này không cần duy trì selection xuyên tương tác với panel, không cần ranh giới từ tùy chỉnh và không cần toolbar tùy chỉnh, nên sử dụng implementation của hệ thống sẽ đơn giản hơn.

Thời gian hoàn thành: 2026-07-30 (kiến trúc ba tầng, bổ sung desktop và chuyển đổi AI response).

### 7.29. Merge nhánh dài hạn ghi đè nội dung tiếng Anh trên main

`app_en.arb` có 256 key âm thầm bị khôi phục về giá trị cũ, sau đó việc “sửa” test tiếp tục củng cố sai sót.

Nguyên nhân gốc:

- Nhánh `video` được fork từ ngày 21/07 và phát triển đến 05/08 mới merge.
- Trong thời gian đó đã nhiều lần `rebase onto main`.
- Ngày 29/07, nhánh có một commit ghi lại toàn bộ `app_en.arb`, kéo theo việc generate lại toàn bộ `app_localizations_en.dart` và `app_localizations.dart`.
- Nguồn nội dung của commit này cũ hơn lần cải thiện bản dịch tiếng Anh trên main ngày 28/07 (`ece1a4da`).
- Vì các file codegen thay đổi gần như mọi dòng, cơ chế three-way merge và phát hiện conflict theo dòng gần như mất tác dụng.
- Kết quả: 256 nội dung tiếng Anh được chỉnh sửa trong `ece1a4da` bị đưa về giá trị cũ.
- Khi merge ngày 05/08, không ai kiểm tra từng dòng của diff lớn này.

Sai sót được củng cố lần thứ hai:

- Sau merge, chạy toàn bộ `flutter test` xuất hiện nhiều assertion failure do nội dung văn bản không khớp.
- Một commit sau đó đã “sửa” các assertion để khớp với nội dung sai đã bị rollback, thay vì điều tra vì sao nội dung thay đổi.
- Bản ghi “dọn dẹp assertion lỗi thời” ngày 06/08 trong `TASKS.md` chính là lần củng cố sai sót này.
- Sau đó toàn bộ test đều xanh, vô tình che giấu vấn đề.

Quy tắc:

- File template i18n (`app_en.arb`) và codegen output không phù hợp để một nhánh dài hạn duy trì các commit ghi lại toàn bộ file rồi rebase.
- Nhánh dài hạn nên đồng bộ với main thường xuyên, không đợi đến trước khi merge mới rebase một lần.
- Khi conflict liên quan đến file codegen được generate toàn bộ, bắt buộc kiểm tra từng key dựa trên source file `.arb`.
- Không được chấp nhận nguyên toàn bộ file từ một phía.
- Nếu `flutter test` thất bại hàng loạt do nội dung văn bản không khớp, phải xác định nội dung thật sự bị sai hay test cần cập nhật.
- Không được mặc định chỉnh assertion chỉ để test chuyển sang trạng thái xanh.

Vấn đề bổ sung được phát hiện:

Trong `step_complete_dialog.dart`, business logic sử dụng chuỗi đã localize `l10n.firstStudy` để quyết định hiển thị “hoàn thành vòng đầu” hay “hoàn thành ôn tập”.

Khi bản dịch `firstStudy` đổi thành `"First Round"`, nó vô tình trùng với chuỗi placeholder `stageName` trong một widget test, qua đó làm lộ vấn đề kiến trúc nghiêm trọng hơn:

Business logic không được dựa vào chuỗi văn bản hiển thị đã dịch để đưa ra quyết định.

Vấn đề này đã được ghi nhận trong `TASKS.md` ngày 06/07 nhưng chưa được refactor. Hiện tại chỉ thay đổi placeholder trong test để tránh trùng lặp.

Phương pháp khôi phục: So sánh ba phiên bản

Lấy ba bản ARB:

1. Trước khi thay đổi: `ece1a4da^`.
2. Giá trị mong muốn: `ece1a4da`.
3. Phiên bản hiện tại: `HEAD`.

So sánh diff theo từng key.

Nếu:

```
HEAD == ece1a4da^
```

và key đó đã được thay đổi trong `ece1a4da`, thì xác định key đã bị âm thầm rollback.

Khôi phục giá trị theo `ece1a4da`.

Phương pháp này có thể mở rộng để phát hiện những thay đổi độc lập trên main bị ghi đè khi merge nhánh dài hạn, không chỉ giới hạn ở localization.

Thời gian hoàn thành: 2026-08-06.
