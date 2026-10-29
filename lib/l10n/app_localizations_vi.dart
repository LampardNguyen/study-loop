// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get startupLocalDataErrorTitle => 'Rất tiếc, đã xảy ra lỗi';

  @override
  String get startupLocalDataErrorMessage =>
      'Không thể tải dữ liệu của bạn bình thường. Vui lòng thử lại. Nếu sự cố vẫn tiếp diễn, hãy liên hệ với chúng tôi.';

  @override
  String get startupLocalDataContactUs => 'Liên hệ chúng tôi';

  @override
  String get startupLocalDataViewLogs => 'Xem nhật ký';

  @override
  String get playbackFailedTitle => 'Phát lại thất bại';

  @override
  String get playbackFailedMessage => 'Vui lòng thử lại sau.';

  @override
  String get appTitle => 'Study Loop';

  @override
  String get premiumTitle => 'Study Loop Premium';

  @override
  String get premiumTagline => 'AI không giới hạn để học hiệu quả hơn';

  @override
  String get aiQuotaExceededGenericTitle =>
      'Hạn mức AI miễn phí tháng này đã hết';

  @override
  String aiQuotaExceededTitle(String feature) {
    return 'Hạn mức $feature miễn phí tháng này đã hết';
  }

  @override
  String get aiQuotaFeatureTranslation => 'dịch bằng AI';

  @override
  String get aiQuotaFeatureAnalysis => 'phân tích câu bằng AI';

  @override
  String get aiQuotaFeatureSenseGroup => 'chia cụm nghĩa bằng AI';

  @override
  String get aiQuotaFeatureWordAnalysis => 'phân tích từ bằng AI';

  @override
  String get aiQuotaFeatureTranscription => 'phiên âm phụ đề bằng AI';

  @override
  String get aiQuotaFeatureChat => 'trợ lý AI';

  @override
  String get aiQuotaFeatureRetellReview => 'đánh giá kể lại bằng AI';

  @override
  String get aiQuotaExceededMessage =>
      'Nâng cấp để có thêm quyền dùng AI và nhiều tính năng hơn.';

  @override
  String get aiQuotaUnsupportedGenericTitle =>
      'Gói miễn phí không hỗ trợ tính năng AI này';

  @override
  String aiQuotaUnsupportedTitle(String feature) {
    return 'Gói miễn phí không hỗ trợ $feature';
  }

  @override
  String get aiQuotaUnsupportedMessage =>
      'Nâng cấp để mở khóa tính năng này và nhiều tính năng AI khác.';

  @override
  String get aiQuotaExceededCta => 'Nâng cấp lên Premium';

  @override
  String get aiQuotaExceededDismiss => 'Đã hiểu';

  @override
  String get aiQuotaExceededSubscribe => 'Nâng cấp ngay';

  @override
  String get premiumEntryTitle => 'Gói đăng ký';

  @override
  String get premiumUnavailableOnPlatform => 'Nền tảng này chưa hỗ trợ đăng ký';

  @override
  String get premiumEntryBadgeActive => 'Premium';

  @override
  String get premiumEntryBadgeUpgrade => 'Nâng cấp';

  @override
  String get premiumActive => 'Bạn đang dùng gói Premium.';

  @override
  String get premiumBenefitTranslation => 'Dịch bằng AI không giới hạn';

  @override
  String get premiumBenefitAnalysis => 'Phân tích câu bằng AI không giới hạn';

  @override
  String get premiumBenefitWordAnalysis =>
      'Giải thích từ và cụm từ bằng AI không giới hạn';

  @override
  String get premiumBenefitTranscription => 'Thêm lượt phiên âm phụ đề bằng AI';

  @override
  String get premiumBenefitAiAssistant =>
      'Trò chuyện với trợ lý AI không giới hạn';

  @override
  String get premiumBenefitPrioritySupport => 'Hỗ trợ ưu tiên';

  @override
  String get premiumBenefitSenseGroups =>
      'Chia cụm nghĩa bằng AI không giới hạn';

  @override
  String get premiumBenefitRetellReview =>
      'Đánh giá kể lại bằng AI không giới hạn';

  @override
  String get premiumSubscribe => 'Đăng ký';

  @override
  String get premiumBuyOneYear => 'Mua gói một năm';

  @override
  String premiumStartTrial(int days) {
    return 'Dùng thử miễn phí $days ngày';
  }

  @override
  String get premiumRestore => 'Khôi phục giao dịch mua';

  @override
  String get premiumManage => 'Quản lý gói đăng ký';

  @override
  String get premiumCurrentPlan => 'Gói hiện tại';

  @override
  String get premiumPlanMonthly => 'Gói tháng';

  @override
  String get premiumPlanYearly => 'Gói năm';

  @override
  String get premiumPlanYearlyOneTime => 'Gói một năm';

  @override
  String get premiumPlanLifetime => 'Gói trọn đời';

  @override
  String get premiumPlanGeneric => 'Gói thành viên';

  @override
  String get premiumStatusActive => 'Đang hoạt động';

  @override
  String get premiumStatusExpiring => 'Sắp hết hạn';

  @override
  String get premiumStatusFixedTerm => 'Mua một lần';

  @override
  String get premiumStatusLifetime => 'Trọn đời';

  @override
  String premiumRenewsOn(String date) {
    return 'Gia hạn vào $date';
  }

  @override
  String premiumExpiresOn(String date) {
    return 'Hết hạn vào $date';
  }

  @override
  String premiumValidUntil(String date) {
    return 'Có hiệu lực đến $date';
  }

  @override
  String get premiumLifetimeAccessNote => 'Dùng trọn đời, không cần gia hạn';

  @override
  String get premiumNoPlans => 'Hiện chưa có gói nào. Vui lòng thử lại sau.';

  @override
  String get premiumLoginRequired => 'Vui lòng đăng nhập trước khi đăng ký.';

  @override
  String get premiumPurchaseLoginRequired =>
      'Vui lòng đăng nhập trước khi mua.';

  @override
  String get premiumRestoreLoginRequired =>
      'Vui lòng đăng nhập trước khi khôi phục giao dịch mua.';

  @override
  String get premiumPurchaseFailed => 'Mua thất bại. Vui lòng thử lại.';

  @override
  String get premiumRestoreAccountMismatch =>
      'Gói đăng ký này đã liên kết với một tài khoản Study Loop khác. Hãy đăng nhập tài khoản gốc rồi thử lại.';

  @override
  String get premiumRestoreNone => 'Không tìm thấy giao dịch mua để khôi phục.';

  @override
  String get premiumRestored => 'Đã khôi phục giao dịch mua.';

  @override
  String get premiumWebCheckoutCta => 'Tiếp tục thanh toán bảo mật';

  @override
  String get premiumUseWebCheckoutFallback =>
      'Thanh toán qua cửa hàng không được? Dùng thanh toán web';

  @override
  String get premiumUseStoreCheckout => 'Tiếp tục thanh toán qua cửa hàng';

  @override
  String get premiumWebVerifying => 'Đang chờ xác nhận thanh toán…';

  @override
  String get premiumWebOpenFailed =>
      'Không mở được trang thanh toán. Vui lòng thử lại.';

  @override
  String get premiumRefresh => 'Làm mới';

  @override
  String get premiumRefreshStatus => 'Làm mới trạng thái Premium';

  @override
  String get premiumPurchasePendingSync =>
      'Mua thành công. Gói của bạn đang được đồng bộ và sẽ sớm có hiệu lực.';

  @override
  String get premiumCheckingEntitlement =>
      'Đang kiểm tra trạng thái gói của bạn…';

  @override
  String get premiumEntitlementCheckFailed =>
      'Không thể xác nhận trạng thái gói của bạn. Hãy thử lại trước khi mua.';

  @override
  String get premiumEntitlementUpdated =>
      'Trạng thái gói của bạn đã được cập nhật.';

  @override
  String get premiumAlreadyEntitledSyncFailed =>
      'Đã tìm thấy gói đăng ký còn hiệu lực nhưng đồng bộ thất bại. Hãy nhấn Khôi phục giao dịch mua ở góc trên bên phải.';

  @override
  String get premiumPeriodMonthly => 'Theo tháng';

  @override
  String get premiumPeriodYearly => 'Theo năm';

  @override
  String get premiumPeriodYearlyOneTime => '1 năm · Mua một lần';

  @override
  String get premiumPeriodLifetime => 'Trọn đời';

  @override
  String get premiumPriceSuffixMonth => '/tháng';

  @override
  String get premiumPriceSuffixYear => '/năm';

  @override
  String get premiumPriceSuffixFirstYear => '/năm đầu';

  @override
  String get premiumPriceSuffixFirstMonth => '/tháng đầu';

  @override
  String get premiumPriceSuffixLifetime => 'Một lần';

  @override
  String get premiumOneTimeYearAccess =>
      'Thanh toán một lần, dùng 1 năm, không tự động gia hạn';

  @override
  String premiumSavePercent(int percent) {
    return 'Tiết kiệm $percent%';
  }

  @override
  String premiumPerMonthEquivalent(String price) {
    return '≈ $price/tháng';
  }

  @override
  String premiumIntroFirstYear(String price) {
    return 'Năm đầu $price';
  }

  @override
  String premiumIntroFirstMonth(String price) {
    return 'Tháng đầu $price';
  }

  @override
  String premiumRenewalPricePerYear(String price) {
    return '$price/năm';
  }

  @override
  String premiumRenewalPricePerMonth(String price) {
    return '$price/tháng';
  }

  @override
  String premiumRenewalPricePerPeriod(String price) {
    return '$price';
  }

  @override
  String premiumTryFreeThen(int days, String renewal) {
    return 'Dùng thử miễn phí $days ngày, sau đó $renewal';
  }

  @override
  String premiumOfferThen(String intro, String renewal) {
    return '$intro, sau đó $renewal';
  }

  @override
  String premiumSpecialOfferPercent(int percent, String period) {
    return 'Ưu đãi sớm: giảm $percent% cho $period đầu tiên';
  }

  @override
  String premiumSpecialOfferIntro(String intro, String renewal) {
    return 'Ưu đãi sớm: $intro, sau đó $renewal';
  }

  @override
  String get premiumOfferPeriodYear => 'năm';

  @override
  String get premiumOfferPeriodMonth => 'tháng';

  @override
  String get premiumTermsShort => 'Điều khoản';

  @override
  String get premiumPrivacyShort => 'Quyền riêng tư';

  @override
  String get practiceControlModeAuto => 'Tự động';

  @override
  String get practiceControlModeManual => 'Thủ công';

  @override
  String get player => 'Trình phát';

  @override
  String get account => 'Tài khoản';

  @override
  String get chinaRoutingIndicatorTooltip =>
      'Đang dùng định tuyến dịch vụ khu vực Trung Quốc';

  @override
  String get settings => 'Cài đặt';

  @override
  String get addAudio => 'Thêm âm thanh';

  @override
  String get noAudioYet => 'Chưa có tệp âm thanh';

  @override
  String get tapToAdd => 'Nhấn + để thêm âm thanh đầu tiên';

  @override
  String get added => 'Đã thêm';

  @override
  String get transcript => 'Phụ đề';

  @override
  String get playing => 'Lần trước';

  @override
  String get delete => 'Xóa';

  @override
  String get deleteAudio => 'Xóa âm thanh';

  @override
  String deleteConfirm(String name) {
    return 'Bạn có chắc muốn xóa \"$name\" không?';
  }

  @override
  String get cancel => 'Hủy';

  @override
  String get add => 'Thêm';

  @override
  String get importAction => 'Nhập';

  @override
  String get selectAudioFile => 'Chọn tệp âm thanh';

  @override
  String get subtitlePairedBadge => 'Đã khớp phụ đề, sẽ nhập cùng nhau';

  @override
  String get audioFilePickerCloudDriveHint =>
      'Trước khi chọn tệp từ bộ nhớ đám mây, hãy cài đặt và đăng nhập ứng dụng đó. Một số ứng dụng có thể không hỗ trợ chọn tệp trực tiếp từ trình chọn tệp.';

  @override
  String get selectTranscript => 'Chọn phụ đề (tùy chọn)';

  @override
  String get noTranscript => 'Không có phụ đề';

  @override
  String get noBookmarked => 'Chưa có câu đã lưu';

  @override
  String get tapToBookmark => 'Nhấn ⭐ trên câu để đánh dấu';

  @override
  String get playbackMode => 'Chế độ phát';

  @override
  String get fullArticle => 'Toàn bài';

  @override
  String get singleSentence => 'Từng câu';

  @override
  String get bookmarkedOnly => 'Chỉ câu đã lưu';

  @override
  String get playbackSettings => 'Cài đặt phát lại';

  @override
  String get waveformZoom => 'Thu phóng';

  @override
  String waveformLoading(int progress) {
    return 'Đang tải dạng sóng $progress%';
  }

  @override
  String get waveformLoadFailed =>
      'Không có dạng sóng. Bạn vẫn có thể chỉnh sửa phụ đề bên dưới.';

  @override
  String get waveformAudioMissing =>
      'Không tìm thấy âm thanh. Bạn vẫn có thể chỉnh sửa phụ đề bên dưới.';

  @override
  String get waveformRetry => 'Thử lại';

  @override
  String get playbackSpeed => 'Tốc độ phát';

  @override
  String get loopPlayback => 'Phát lặp lại';

  @override
  String get loopCount => 'Số lần lặp';

  @override
  String get pauseInterval => 'Khoảng tạm dừng';

  @override
  String get applySettings => 'Áp dụng cài đặt';

  @override
  String get play => 'Phát';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get stop => 'Dừng';

  @override
  String get previousSentence => 'Câu trước';

  @override
  String get nextSentence => 'Câu tiếp theo';

  @override
  String get removeBookmark => 'Bỏ đánh dấu';

  @override
  String get addBookmark => 'Đánh dấu';

  @override
  String get appearance => 'Giao diện';

  @override
  String get themeMode => 'Chủ đề';

  @override
  String get themeModeSystem => 'Theo hệ thống';

  @override
  String get themeModeLight => 'Chế độ sáng';

  @override
  String get themeModeDark => 'Chế độ tối';

  @override
  String get language => 'Ngôn ngữ ứng dụng';

  @override
  String get languageDescription => 'Ngôn ngữ dùng cho giao diện ứng dụng';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get nativeLanguage => 'Ngôn ngữ mẹ đẻ';

  @override
  String get nativeLanguageDescription =>
      'Ngôn ngữ dùng cho bản dịch và phân tích';

  @override
  String get about => 'Giới thiệu';

  @override
  String get version => 'Phiên bản';

  @override
  String get save => 'Lưu';

  @override
  String get enableLoop => 'Bật lặp lại';

  @override
  String get loopSettings => 'Cài đặt lặp lại';

  @override
  String get wholeTextLoop => 'Lặp lại toàn bộ';

  @override
  String get singleSentenceLoop => 'Lặp lại từng câu';

  @override
  String get displaySettings => 'Cài đặt hiển thị';

  @override
  String get showTranscript => 'Hiện phụ đề';

  @override
  String get shortcutKey => 'Phím tắt';

  @override
  String get seconds => 'giây';

  @override
  String get infinite => '∞';

  @override
  String get singleSentenceMode => 'Nghe kỹ';

  @override
  String get singleSentenceModeDesc => 'Chỉ hiện câu đang phát';

  @override
  String get autoPlayNextSentence => 'Tự phát câu tiếp theo';

  @override
  String get repeatCount => 'Số lần lặp lại';

  @override
  String get infiniteRepeat => 'Vô hạn ∞';

  @override
  String get intervalTime => 'Thời lượng khoảng nghỉ';

  @override
  String get times => 'lần';

  @override
  String loopCountValue(int count) {
    return '$count lần';
  }

  @override
  String loopIntervalValue(int seconds) {
    return '$seconds giây';
  }

  @override
  String get sleepTimer => 'Hẹn giờ tắt';

  @override
  String sleepTimerMinutes(int count) {
    return '$count phút';
  }

  @override
  String get sleepTimerRemaining => 'Thời gian còn lại';

  @override
  String get sleepTimerOff => 'Tắt hẹn giờ';

  @override
  String sleepTimerA11yActive(String time) {
    return 'Hẹn giờ tắt, còn $time, nhấn để điều chỉnh';
  }

  @override
  String get fullText => 'Toàn bài';

  @override
  String get bookmarked => 'Đã lưu';

  @override
  String get noSubtitle => 'Không có phụ đề';

  @override
  String get noSentenceSelected => 'Chưa chọn câu';

  @override
  String get noBookmarkedSentences => 'Chưa có câu đã lưu';

  @override
  String get tapBookmarkIcon => 'Nhấn biểu tượng đánh dấu để lưu';

  @override
  String get noBookmarksHint =>
      'Chưa có câu nào được đánh dấu. Nhấn biểu tượng đánh dấu bên cạnh câu để thêm.';

  @override
  String get bookmarksEmptyReturned =>
      'Không còn câu nào được đánh dấu. Đã chuyển về Toàn bài.';

  @override
  String get removeBookmarkTip => 'Bỏ đánh dấu';

  @override
  String get addBookmarkTip => 'Đánh dấu';

  @override
  String get listMode => 'Chế độ danh sách';

  @override
  String get copy => 'Sao chép';

  @override
  String get copied => 'Đã sao chép vào bộ nhớ tạm';

  @override
  String get hotkeyReplay => 'R: Phát lại';

  @override
  String get hotkeyPlayPause => 'Space: Phát/Tạm dừng';

  @override
  String get hotkeyToggleTranscript => '↑: Hiện/Ẩn phụ đề';

  @override
  String get hotkeyNavigation => '←/→: Câu trước/Câu tiếp theo';

  @override
  String get noAudioLoaded => 'Chưa tải âm thanh';

  @override
  String get enableAutoScroll => 'Bật tự cuộn';

  @override
  String get disableAutoScroll => 'Tắt tự cuộn';

  @override
  String get audioFileNotFound =>
      'Không tìm thấy tệp âm thanh. Tệp có thể đã bị xóa.';

  @override
  String get pickAudioFileFailed => 'Chọn tệp âm thanh thất bại';

  @override
  String get addAudioFailed => 'Thêm âm thanh thất bại';

  @override
  String audioUnsupportedFormat(String ext) {
    return 'Định dạng âm thanh không được hỗ trợ: $ext. Chỉ hỗ trợ MP3, WAV, M4A, AAC, FLAC.';
  }

  @override
  String get audioErrorUnsupportedTitle =>
      'Định dạng âm thanh không được hỗ trợ';

  @override
  String get audioErrorNoAudioTitle => 'Chưa chọn tệp âm thanh';

  @override
  String get audioNoAudioSelected =>
      'Phụ đề được nhập cùng với âm thanh. Hãy chọn cả tệp âm thanh — MP3, WAV, M4A, AAC, FLAC.';

  @override
  String get audioErrorGenericTitle => 'Thêm âm thanh thất bại';

  @override
  String get pickTranscriptFileFailed => 'Chọn tệp phụ đề thất bại';

  @override
  String subtitleUnsupportedFormat(String ext) {
    return 'Định dạng phụ đề không được hỗ trợ: .$ext. Chỉ hỗ trợ tệp SRT và VTT.';
  }

  @override
  String get subtitleFormatInvalid =>
      'Định dạng phụ đề không hợp lệ. Chỉ hỗ trợ tệp SRT và VTT chuẩn.';

  @override
  String get subtitleFileEmpty =>
      'Tệp phụ đề trống hoặc bị hỏng — không tìm thấy mục phụ đề nào.';

  @override
  String get subtitleErrorUnsupportedTitle =>
      'Định dạng phụ đề không được hỗ trợ';

  @override
  String get subtitleErrorInvalidTitle => 'Định dạng phụ đề không hợp lệ';

  @override
  String get subtitleErrorEmptyTitle => 'Không tìm thấy mục phụ đề';

  @override
  String get subtitleErrorGenericTitle => 'Tải lên thất bại';

  @override
  String get fileExists => 'Tệp đã tồn tại';

  @override
  String fileExistsMessage(String name) {
    return 'Đã có tệp âm thanh tên \"$name\". Vui lòng xóa âm thanh gốc trước.';
  }

  @override
  String get back => 'Quay lại';

  @override
  String get ok => 'OK';

  @override
  String addedOn(String date) {
    return 'Đã thêm: $date';
  }

  @override
  String updatedOn(String date) {
    return 'Cập nhật $date';
  }

  @override
  String get collections => 'Bộ sưu tập';

  @override
  String get collection => 'Bộ sưu tập';

  @override
  String get createCollection => 'Tạo bộ sưu tập';

  @override
  String get newCollectionOptionTitle => 'Bộ sưu tập mới';

  @override
  String get newCollectionOptionDescription => 'Thêm âm thanh hoặc video';

  @override
  String get collectionName => 'Tên bộ sưu tập';

  @override
  String get enterCollectionName => 'Nhập tên bộ sưu tập';

  @override
  String get noCollectionsYet => 'Chưa có bộ sưu tập';

  @override
  String get tapToCreateCollection => 'Nhấn + để tạo bộ sưu tập đầu tiên';

  @override
  String get deleteCollection => 'Xóa bộ sưu tập';

  @override
  String deleteCollectionConfirm(String name) {
    return 'Bạn có chắc muốn xóa \"$name\" không?';
  }

  @override
  String get deleteCollectionAlsoDeleteAudio => 'Xóa cả tệp âm thanh?';

  @override
  String deleteCollectionKeepAudioHint(int count) {
    return '$count tệp âm thanh trong bộ sưu tập này sẽ được giữ lại.';
  }

  @override
  String deleteCollectionDeleteAudioHint(int count) {
    return '$count tệp âm thanh trong bộ sưu tập này cũng sẽ bị xóa.';
  }

  @override
  String get renameCollection => 'Đổi tên';

  @override
  String get pinCollection => 'Ghim lên đầu';

  @override
  String get unpinCollection => 'Bỏ ghim';

  @override
  String get pinAudio => 'Ghim lên đầu';

  @override
  String get unpinAudio => 'Bỏ ghim';

  @override
  String get sortByNameAsc => 'Tên (A-Z)';

  @override
  String get sortByNameDesc => 'Tên (Z-A)';

  @override
  String get sortByDateAsc => 'Cũ nhất trước';

  @override
  String get sortByDateDesc => 'Mới nhất trước';

  @override
  String get sortDefault => 'Mặc định';

  @override
  String get sortByOriginalDateAsc => 'Phát hành cũ nhất';

  @override
  String get sortByOriginalDateDesc => 'Phát hành mới nhất';

  @override
  String publishedOn(String date) {
    return 'Phát hành $date';
  }

  @override
  String get discoverEntryTitleA => 'Khám phá tài nguyên';

  @override
  String get discoverEntrySubtitleA =>
      'Podcast, TOEFL, IELTS, CET-4/6, Phiên dịch...';

  @override
  String get communityCollectionEmpty => 'Bộ sưu tập này chưa có âm thanh';

  @override
  String communityCollectionAuthor(String nickname) {
    return 'Tác giả: $nickname';
  }

  @override
  String get communityCollectionUnknownAuthor => 'Tác giả không rõ';

  @override
  String communityCollectionUploader(String nickname) {
    return 'Tải lên bởi $nickname';
  }

  @override
  String get communityCollectionUnknownUploader => 'Người tải lên không rõ';

  @override
  String get communityCollectionUnknownPublishDate => 'Chưa rõ ngày';

  @override
  String communityCollectionCover(String name) {
    return 'Ảnh bìa $name';
  }

  @override
  String get communityCollectionShowMore => 'Xem thêm';

  @override
  String get communityCollectionShowLess => 'Thu gọn';

  @override
  String get sortCollections => 'Sắp xếp';

  @override
  String get gridView => 'Dạng lưới';

  @override
  String get listView => 'Dạng danh sách';

  @override
  String audioCount(int count) {
    return '$count mục';
  }

  @override
  String get collectionNameEmpty => 'Tên bộ sưu tập không được để trống';

  @override
  String get collectionNameExists => 'Đã có bộ sưu tập trùng tên';

  @override
  String get addAudioToCollection => 'Thêm âm thanh hoặc video';

  @override
  String get removeFromCollection => 'Xóa khỏi bộ sưu tập';

  @override
  String removeFromCollectionConfirm(String name) {
    return 'Xóa \"$name\" khỏi bộ sưu tập này?';
  }

  @override
  String get permanentlyDeleteAudio => 'Xóa vĩnh viễn âm thanh';

  @override
  String get permanentlyDeleteAudioHint =>
      'Xóa âm thanh khỏi tất cả bộ sưu tập.';

  @override
  String audioBelongsToCollections(String names) {
    return 'Cũng có trong: $names';
  }

  @override
  String get audioNotInOtherCollections =>
      'Không có trong bộ sưu tập nào khác — có thể xóa an toàn.';

  @override
  String selectedCount(int count) {
    return 'Đã chọn $count';
  }

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get deselectAll => 'Bỏ chọn tất cả';

  @override
  String removeFromCollectionBatch(int count) {
    return 'Xóa $count khỏi bộ sưu tập';
  }

  @override
  String permanentlyDeleteBatch(int count) {
    return 'Xóa vĩnh viễn $count âm thanh';
  }

  @override
  String get permanentlyDeleteBatchHint =>
      'Xóa âm thanh khỏi tất cả bộ sưu tập.';

  @override
  String get removeFromCollectionBatchHint =>
      'Chỉ xóa khỏi bộ sưu tập này; tệp âm thanh vẫn được giữ lại.';

  @override
  String get emptyCollection => 'Bộ sưu tập này chưa có nội dung';

  @override
  String get renameAudio => 'Đổi tên';

  @override
  String get audioName => 'Tên âm thanh';

  @override
  String get audioAlreadyInCollection => 'Âm thanh trùng lặp';

  @override
  String audioAlreadyInCollectionMessage(String name) {
    return 'Bộ sưu tập này đã có âm thanh tên \"$name\".';
  }

  @override
  String get audioAlreadyInLibrary => 'Âm thanh trùng lặp';

  @override
  String audioAlreadyInLibraryMessage(String name) {
    return 'Thư viện đã có âm thanh tên \"$name\".';
  }

  @override
  String get study => 'Học';

  @override
  String get favorites => 'Đã lưu';

  @override
  String get profile => 'Cá nhân';

  @override
  String get studyComingSoon => 'Tính năng học sắp ra mắt';

  @override
  String get favoritesComingSoon => 'Tính năng lưu sắp ra mắt';

  @override
  String get learningPlanProgress => 'Tiến độ học';

  @override
  String get learningPlanNotStarted => 'Chưa bắt đầu';

  @override
  String get firstStudy => 'Vòng đầu';

  @override
  String get review => 'Ôn tập';

  @override
  String stepProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String get stepBlindListening => 'Nghe không phụ đề';

  @override
  String get stepBlindListeningDesc =>
      'Nghe toàn bộ âm thanh/video không có phụ đề. Nắm ý chính.';

  @override
  String get stepIntensiveListening => 'Nghe từng câu';

  @override
  String get stepIntensiveListeningDesc =>
      'Nghe từng câu với thời gian dừng tự động. Với câu khó, chạm “Chưa rõ” để lưu và xem phân tích AI.';

  @override
  String get stepShadowing => 'Nghe và nhắc lại';

  @override
  String get stepShadowingDesc =>
      'Nhắc lại các câu bạn đã lưu. Mặc định mỗi câu được phát ba lần.';

  @override
  String get stepRetelling => 'Nghe và kể lại';

  @override
  String get stepRetellingDesc =>
      'Nghe và kể lại từng đoạn. Bám theo bản ghi gốc hoặc kể bằng lời của bạn';

  @override
  String get stepFullTextRetelling => 'Kể lại toàn bộ văn bản';

  @override
  String get warmUpCardTitle => 'Nghe khởi động';

  @override
  String get warmUpCardSubtitle =>
      'Nghe một lần để nắm ý chính. Bạn không cần bắt được từng từ.';

  @override
  String get warmUpCardBadge => 'Nên làm trước';

  @override
  String get reviewRound0 => 'Ôn tập 1';

  @override
  String get reviewRound1 => 'Ôn tập 2';

  @override
  String get reviewRound2 => 'Ôn tập 3';

  @override
  String get reviewRound4 => 'Ôn tập 4';

  @override
  String get reviewRound7 => 'Ôn tập 5';

  @override
  String get reviewRound14 => 'Ôn tập 6';

  @override
  String get reviewRound28 => 'Ôn tập 7';

  @override
  String reviewUnlockIn(int days) {
    return 'Mở khóa sau $days ngày';
  }

  @override
  String reviewUnlockInHours(int hours) {
    return 'Mở khóa sau $hours giờ';
  }

  @override
  String get reviewUnlocked => 'Đã mở khóa';

  @override
  String get unlockReviewNow => 'Mở khóa ngay';

  @override
  String get startLearning => 'Bắt đầu luyện tập';

  @override
  String get continueLearning => 'Tiếp tục luyện tập';

  @override
  String get learningInProgress => 'Đang thực hiện';

  @override
  String get learningCompleted => 'Đã hoàn thành';

  @override
  String get reviewReady => 'Sẵn sàng ôn tập';

  @override
  String reviewCountdown(int days) {
    return 'Mở khóa sau $days ngày';
  }

  @override
  String reviewCountdownHours(int hours) {
    return 'Mở khóa sau $hours giờ';
  }

  @override
  String get blindListenBriefingTitle => 'Nghe không phụ đề';

  @override
  String get blindListenBriefingSubtitle => 'Vòng đầu - Nghe không phụ đề';

  @override
  String blindListenBriefingReviewSubtitle(int round) {
    return 'Ôn tập $round - Nghe không phụ đề';
  }

  @override
  String get blindListenBriefingTip =>
      'Thử thách bản thân: nghe không phụ đề và nắm ý chính';

  @override
  String get startPractice => 'Bắt đầu luyện tập';

  @override
  String get blindListenAppBarTitle => 'Nghe không phụ đề';

  @override
  String blindListenPassLabel(int count) {
    return 'Lượt $count';
  }

  @override
  String get blindListenComplete => 'Hoàn thành nghe không phụ đề';

  @override
  String blindListenPassInfo(int count) {
    return 'Đã nghe $count lần';
  }

  @override
  String get selectDifficulty => 'Bạn thấy độ khó thế nào?';

  @override
  String get selectDifficultyRequired => 'Chọn mức độ khó để tiếp tục';

  @override
  String get listenAgain => 'Nghe lại';

  @override
  String get practiceAgain => 'Luyện lại';

  @override
  String get nextStage => 'Tiếp';

  @override
  String get difficultyVeryEasy => 'Rất dễ';

  @override
  String get difficultyEasy => 'Dễ';

  @override
  String get difficultyMedium => 'Vừa';

  @override
  String get difficultyHard => 'Khó';

  @override
  String get difficultyVeryHard => 'Rất khó';

  @override
  String get countdownNextPlay => 'Lượt phát tiếp theo sau';

  @override
  String get skipCountdown => 'Bỏ qua';

  @override
  String audioDuration(String duration) {
    return 'Thời lượng: $duration';
  }

  @override
  String estimatedMinutes(int minutes) {
    return 'Ước tính $minutes phút';
  }

  @override
  String get estimatedLessThanOneMinute => 'Ước tính < 1 phút';

  @override
  String get exitBlindListenTitle => 'Thoát nghe?';

  @override
  String get exitBlindListenMessage =>
      'Âm thanh vẫn đang phát. Bạn có chắc muốn thoát?';

  @override
  String get confirmExit => 'Thoát';

  @override
  String get library => 'Thư viện';

  @override
  String get myLibrary => 'Thư viện của tôi';

  @override
  String get libraryShowAll => 'Tất cả';

  @override
  String get collectionsTab => 'Bộ sưu tập';

  @override
  String get audioTab => 'Âm thanh';

  @override
  String get uncategorized => 'Chưa phân loại';

  @override
  String get manageCollections => 'Quản lý bộ sưu tập';

  @override
  String get noAudioItems => 'Chưa có tệp âm thanh';

  @override
  String get noAudioItemsHint => 'Nhập tệp âm thanh để bắt đầu luyện tập';

  @override
  String audioWillBeKept(int count) {
    return '$count tệp âm thanh trong bộ sưu tập này sẽ được giữ lại trong thư viện';
  }

  @override
  String get done => 'Xong';

  @override
  String get sortAudio => 'Sắp xếp';

  @override
  String deleteAudioConfirm(String name) {
    return 'Xóa vĩnh viễn \"$name\"?';
  }

  @override
  String deleteAudioConfirmKeepFile(String name) {
    return 'Bạn có chắc muốn xóa \"$name\"? Tệp âm thanh được dùng chung với mục khác nên sẽ được giữ lại.';
  }

  @override
  String get uploadTranscript => 'Tải lên phụ đề';

  @override
  String get replaceTranscriptTitle => 'Thay thế phụ đề';

  @override
  String get replaceTranscriptMessage =>
      'Đã có tệp phụ đề. Bạn có muốn thay thế không?';

  @override
  String get replace => 'Thay thế';

  @override
  String sentenceCountLabel(int count) {
    return '$count câu';
  }

  @override
  String wordCountLabel(int count) {
    return '$count từ';
  }

  @override
  String get noTranscriptWarning => 'Âm thanh này chưa có phụ đề';

  @override
  String get intensiveListenAppBarTitle => 'Nghe từng câu';

  @override
  String intensiveListenProgress(int current, int total) {
    return 'Câu $current/$total';
  }

  @override
  String intensiveListenPlayCount(int current, int total) {
    return 'Lượt $current/$total';
  }

  @override
  String get intensiveListenPeek => 'Xem lén phụ đề';

  @override
  String get intensiveListenHideSubtitle => 'Ẩn phụ đề';

  @override
  String get intensiveListenCantUnderstand => 'Chưa rõ';

  @override
  String get intensiveListenAutoMarkedDifficult =>
      'Tự động lưu, chạm để hoàn tác';

  @override
  String get intensiveListenMarkedDifficult => 'Bỏ lưu';

  @override
  String get intensiveListenNotDifficult => 'Lưu';

  @override
  String get aiTranslation => 'Bản dịch';

  @override
  String get aiAnalysis => 'Phân tích';

  @override
  String get aiLoadFailed => 'Tải thất bại, chạm để thử lại';

  @override
  String get aiTranslationFailed => 'Dịch thất bại, vui lòng thử lại';

  @override
  String get aiAnalysisFailed => 'Phân tích thất bại, vui lòng thử lại';

  @override
  String get aiRetry => 'Thử lại';

  @override
  String get aiGrammar => 'Ngữ pháp';

  @override
  String get aiVocabulary => 'Từ vựng chính';

  @override
  String get aiListening => 'Mẹo nghe';

  @override
  String get intensiveListenWordDictNotFound =>
      'Không tìm thấy từ trong từ điển';

  @override
  String get intensiveListenContinue => 'Tiếp';

  @override
  String get intensiveListenReplayingWithSubtitle => 'Nghe lại để nhớ lâu hơn';

  @override
  String intensiveListenPauseBetweenPlays(int seconds) {
    return 'Phát tiếp sau $seconds giây';
  }

  @override
  String intensiveListenPauseBetweenSentences(int seconds) {
    return 'Câu tiếp theo sau $seconds giây';
  }

  @override
  String get intensiveListenCompleteTitle => 'Hoàn thành nghe từng câu';

  @override
  String get intensiveListenCompleteHint =>
      'Tiếp tục ôn tập theo lịch lặp lại ngắt quãng để nắm vững hoàn toàn.';

  @override
  String get intensiveListenCompleteNext => 'Bước tiếp theo';

  @override
  String get statSentences => 'Câu';

  @override
  String get statDifficultSentences => 'câu khó';

  @override
  String get statParagraphs => 'Đoạn';

  @override
  String get exitIntensiveListenTitle => 'Thoát nghe từng câu?';

  @override
  String get exitIntensiveListenMessage =>
      'Tiến độ của bạn sẽ được lưu. Bạn có thể tiếp tục từ chỗ đã dừng.';

  @override
  String get intensiveListenBriefingTitle => 'Nghe từng câu';

  @override
  String get intensiveListenBriefingTip =>
      'Nghe từng câu. Chạm \'Chưa rõ\' để xem bản ghi và phân tích.';

  @override
  String intensiveListenBriefingSentenceCount(int count) {
    return '$count câu';
  }

  @override
  String get intensiveListenNoSubtitle => 'Không có phụ đề';

  @override
  String get intensiveListenNoSubtitleMessage =>
      'Âm thanh này không có phụ đề. Vui lòng tải lên tệp phụ đề trước.';

  @override
  String get intensiveListenSettings => 'Cài đặt';

  @override
  String get intensiveListenRepeatCount => 'Số lần lặp mỗi câu';

  @override
  String get intensiveListenAnnotationReplayUsesRepeatCount =>
      'Lặp ở trang giải thích';

  @override
  String intensiveListenRepeatCountValue(int count) {
    return '$count lần';
  }

  @override
  String get intensiveListenPauseLabel => 'Dừng giữa các câu';

  @override
  String get intensiveListenPauseSmart => 'Tự động';

  @override
  String get intensiveListenPauseFixed => 'Cố định';

  @override
  String get intensiveListenPauseMultiplierMode => 'Hệ số';

  @override
  String get intensiveListenSettingsTemporaryHint =>
      'Cài đặt sẽ được ghi nhớ cho lần sau';

  @override
  String get intensiveListenPauseSmartDesc =>
      'Tự điều chỉnh theo độ khó, độ dài câu và giai đoạn học';

  @override
  String get intensiveListenControlModeAutoDesc =>
      'Tự lặp, tự dừng, tự chuyển câu';

  @override
  String get intensiveListenControlModeManualDesc =>
      'Lặp theo cấu hình, chạm để chuyển câu';

  @override
  String intensiveListenPauseFixedUnit(int seconds) {
    return '$seconds giây';
  }

  @override
  String intensiveListenPauseMultiplierValue(String value) {
    return '${value}x';
  }

  @override
  String get intensiveListenPauseMultiplierLabel => 'Hệ số';

  @override
  String blindListenCountdown(int seconds) {
    return 'Phát tiếp sau $seconds giây';
  }

  @override
  String difficultyLabel(String difficulty) {
    return 'Mức độ khó: $difficulty';
  }

  @override
  String continueToStep(String step) {
    return 'Tiếp tục: $step';
  }

  @override
  String get completeFirstStudy => 'Hoàn thành vòng đầu';

  @override
  String get completeReview => 'Hoàn thành ôn tập';

  @override
  String stepProgressLabel(int current, int total, String stage) {
    return 'Giai đoạn $current/$total ($stage)';
  }

  @override
  String get manageTags => 'Quản lý thẻ';

  @override
  String get noTagsYet => 'Chưa có thẻ nào';

  @override
  String get createTag => 'Tạo thẻ';

  @override
  String get tagName => 'Tên thẻ';

  @override
  String get enterTagName => 'Nhập tên thẻ';

  @override
  String get selectColor => 'Chọn màu';

  @override
  String get deleteTag => 'Xóa thẻ';

  @override
  String deleteTagConfirm(String name) {
    return 'Bạn có chắc muốn xóa \"$name\"? Thẻ sẽ bị gỡ khỏi tất cả tệp âm thanh.';
  }

  @override
  String get listenAndRepeatAppBarTitle => 'Nghe và nhắc lại';

  @override
  String listenAndRepeatProgress(int current, int total) {
    return 'Câu $current/$total';
  }

  @override
  String listenAndRepeatPlayCount(int current, int total) {
    return 'Lượt $current/$total';
  }

  @override
  String listenAndRepeatPauseBetweenPlays(int seconds) {
    return 'Thời gian nhắc lại $seconds giây';
  }

  @override
  String listenAndRepeatPauseBetweenSentences(int seconds) {
    return 'Câu tiếp theo sau $seconds giây';
  }

  @override
  String get listenAndRepeatListenHint => 'Nghe, rồi nhắc lại';

  @override
  String get listenAndRepeatYourTurnHint => 'Nhắc lại';

  @override
  String get listenAndRepeatRecordButton => 'Ghi âm';

  @override
  String get listenAndRepeatStopRecordingButton => 'Dừng';

  @override
  String get listenAndRepeatPlayRecordingButton => 'Nghe bản ghi âm';

  @override
  String get listenAndRepeatRecordingInProgress => 'Đang ghi âm...';

  @override
  String get listenAndRepeatStartSpeaking => 'Bắt đầu nói';

  @override
  String get listenAndRepeatAnalyzing => 'Đang phân tích...';

  @override
  String get listenAndRepeatTapToRecord => 'Chạm để ghi âm';

  @override
  String get listenAndRepeatRatingPerfect => 'Hoàn hảo!';

  @override
  String get listenAndRepeatRatingExcellent => 'Xuất sắc';

  @override
  String get listenAndRepeatRatingGood => 'Tốt';

  @override
  String get listenAndRepeatRatingFair => 'Khá';

  @override
  String get listenAndRepeatRatingKeepGoing => 'Cố lên';

  @override
  String get listenAndRepeatAwaitingFinalTranscript =>
      'Đang xác nhận bản ghi cuối cùng...';

  @override
  String get listenAndRepeatYourTakeLabel => 'Bản ghi của bạn';

  @override
  String get listenAndRepeatRecognitionInProgress =>
      'Đang kiểm tra bản ghi âm của bạn...';

  @override
  String listenAndRepeatRecognitionPassed(int percent) {
    return 'Khớp $percent% số từ mục tiêu.';
  }

  @override
  String listenAndRepeatRecognitionBelowThreshold(int percent) {
    return 'Khớp $percent% số từ mục tiêu.';
  }

  @override
  String get listenAndRepeatRecognitionNoEnglish =>
      'Không phát hiện tiếng Anh được nói';

  @override
  String get listenAndRepeatRecognitionPermissionDenied =>
      'Cần cấp quyền micro hoặc nhận dạng giọng nói.';

  @override
  String get listenAndRepeatRecognitionUnavailable =>
      'Thiết bị này không hỗ trợ nhận dạng giọng nói.';

  @override
  String get listenAndRepeatRecognitionError => 'Lỗi nhận dạng';

  @override
  String get listenAndRepeatRecordingOnly => 'Ghi âm';

  @override
  String get listenAndRepeatCompleteTitle => 'Hoàn thành Nghe và nhắc lại';

  @override
  String get exitListenAndRepeatTitle => 'Thoát Nghe và nhắc lại?';

  @override
  String get exitListenAndRepeatMessage =>
      'Tiến độ của bạn sẽ được lưu. Bạn có thể tiếp tục từ chỗ đã dừng.';

  @override
  String get listenAndRepeatBriefingTitle => 'Nghe và nhắc lại';

  @override
  String get listenAndRepeatBriefingTip =>
      'Nghe trước, rồi nhắc lại trong lúc dừng. Mặc định mỗi câu đã lưu sẽ được phát ba lần.';

  @override
  String get listenAndRepeatScopeLabel => 'Phạm vi nhắc lại';

  @override
  String get listenAndRepeatScopeFullText => 'Toàn bộ văn bản';

  @override
  String get listenAndRepeatScopeDifficultOnly => 'Chỉ câu đã lưu';

  @override
  String get listenAndRepeatNoSavedSentencesNoNeed => 'Không có câu đã lưu';

  @override
  String listenAndRepeatBriefingSentenceCount(int count) {
    return '$count câu';
  }

  @override
  String listenAndRepeatBriefingDifficultCount(int count) {
    return '$count câu đã lưu';
  }

  @override
  String listenAndRepeatBriefingPlayCount(int count) {
    return 'Phát $count lần mỗi câu';
  }

  @override
  String get listenAndRepeatRemoveDifficult =>
      'Đã tự động lưu, chạm để hoàn tác';

  @override
  String get listenAndRepeatSettings => 'Cài đặt nhắc lại';

  @override
  String get listenAndRepeatSettingsTemporaryHint =>
      'Cài đặt chỉ áp dụng cho phiên này';

  @override
  String get listenAndRepeatControlModeLabel => 'Chế độ điều khiển';

  @override
  String get listenAndRepeatControlModeAuto => 'Tự động';

  @override
  String get listenAndRepeatControlModeManual => 'Thủ công';

  @override
  String get listenAndRepeatControlModeAutoDesc =>
      'Tự ghi âm, tự dừng, tự phát câu tiếp theo';

  @override
  String get listenAndRepeatControlModeManualDesc =>
      'Chạm để ghi âm, chạm để dừng, chạm để phát câu tiếp theo';

  @override
  String get listenAndRepeatPauseSmartDesc =>
      'Tự điều chỉnh theo độ khó, độ dài câu và giai đoạn học';

  @override
  String sentenceDuration(String duration) {
    return '$duration giây';
  }

  @override
  String difficultSentenceCount(int count) {
    return '$count câu khó';
  }

  @override
  String intensiveListenPassInfo(int count) {
    return 'Đã luyện $count lần';
  }

  @override
  String shadowingPassInfo(int count) {
    return 'Đã luyện $count lần';
  }

  @override
  String get retellBriefingTitle => 'Nghe và kể lại';

  @override
  String get retellBriefingSubtitle =>
      'Nghe và kể lại từng đoạn. Bám theo bản ghi gốc hoặc dùng lời của bạn. Các từ hiển thị giúp bạn nhớ lại điều đã nghe.';

  @override
  String get retellBriefingTargetDuration => 'độ dài đoạn';

  @override
  String retellBriefingParagraphCount(int count) {
    return 'Chia thành $count đoạn';
  }

  @override
  String retellBriefingSeconds(int seconds) {
    return '$seconds giây';
  }

  @override
  String get retellBriefingSentenceLevel => 'Theo từng câu';

  @override
  String retellBriefingSentenceCount(int count) {
    return 'Tổng $count câu';
  }

  @override
  String get retellTitle => 'Nghe và kể lại';

  @override
  String retellParagraphProgress(int current, int total) {
    return 'Đoạn $current/$total';
  }

  @override
  String retellParagraphDuration(String duration) {
    return '$duration giây';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes phút $seconds giây';
  }

  @override
  String get retellPreListenHint => 'Nghe trước, rồi kể lại';

  @override
  String get retellListeningPhase => 'Đang nghe kỹ...';

  @override
  String get retellPromptToRetell => 'Kể lại những gì bạn đã nghe';

  @override
  String retellRetellingCountdown(int seconds) {
    return 'Kể lại $seconds giây';
  }

  @override
  String retellRepeatInfo(int current, int total) {
    return 'Lượt $current/$total';
  }

  @override
  String get retellCompleteFirstStudy => 'Hoàn thành vòng đầu';

  @override
  String get retellCompleteReview => 'Hoàn thành ôn tập';

  @override
  String get retellCompleteFreePlay => 'Hoàn thành luyện tập';

  @override
  String get retellCompleteTitle => 'Hoàn thành Nghe và kể lại';

  @override
  String get retellPracticeAgain => 'Luyện lại';

  @override
  String get retellExitConfirmTitle => 'Thoát Nghe và kể lại?';

  @override
  String get retellExitConfirmMessage => 'Tiến độ đoạn hiện tại sẽ được lưu.';

  @override
  String get retellDisplayKeywordsOnly => 'Một phần';

  @override
  String get retellDisplayShowAll => 'Hiện';

  @override
  String get retellDisplayHideAll => 'Ẩn';

  @override
  String get retellSettingsTitle => 'Cài đặt kể lại';

  @override
  String get retellAutoPlaybackPromptTitle =>
      'Tự động phát bản ghi âm sau khi kể lại?';

  @override
  String get retellAutoPlaybackPromptMessage =>
      'Khi bật, bản ghi âm của bạn sẽ tự phát sau mỗi lần kể lại để bạn nghe lại phát âm ngay. Bạn có thể đổi bất cứ lúc nào trong Cài đặt.';

  @override
  String get retellAutoPlaybackKeepOff => 'Để sau';

  @override
  String get retellAutoPlaybackEnable => 'Bật';

  @override
  String get retellRepeatCount => 'Số lần lặp mỗi đoạn';

  @override
  String get retellPauseMode => 'Dừng giữa các đoạn';

  @override
  String retellPassInfo(int count) {
    return 'Đã luyện $count lần';
  }

  @override
  String get retellNoDifficultSentences =>
      'Không có câu để kể lại. Hãy nghe từng câu trước.';

  @override
  String get retellKeywordMethod => 'Từ hiển thị';

  @override
  String get retellKeywordMethodOff => 'Tắt';

  @override
  String get retellKeywordMethodRandom => 'Ngẫu nhiên';

  @override
  String get retellKeywordMethodAi => 'AI';

  @override
  String get retellKeywordMethodAiComingSoon => 'Sắp ra mắt';

  @override
  String get retellKeywordRatio => 'Từ hiển thị';

  @override
  String get pauseModeSmart => 'Tự động';

  @override
  String get pauseModeFixed => 'Cố định';

  @override
  String get pauseModeMultiplier => 'Hệ số';

  @override
  String get fixedPauseSeconds => 'Thời gian dừng cố định';

  @override
  String get pauseMultiplier => 'Hệ số';

  @override
  String get settingsSessionOnly => 'Cài đặt chỉ áp dụng cho phiên hiện tại';

  @override
  String get reviewDifficultPracticeTitle => 'Luyện các câu đã lưu';

  @override
  String get reviewBlindListenDesc =>
      'Nghe lại để cảm nhận khả năng hiểu của bạn đã tiến bộ thế nào';

  @override
  String get reviewDifficultPracticeDesc =>
      'Nghe lại các câu đã lưu và nhắc lại những câu bạn còn thấy khó';

  @override
  String get reviewRetellParagraphDesc =>
      'Kể lại lần nữa để hiểu và diễn đạt tốt hơn';

  @override
  String get reviewRetellSummaryDesc =>
      'Tóm tắt toàn bộ nội dung, nắm mạch chung và kiểm tra mức độ bạn đã học được.';

  @override
  String get reviewBriefingTipDifficultPractice =>
      'Hãy nghe không phụ đề trước, rồi luyện thêm các câu bạn còn thấy khó.';

  @override
  String get reviewBriefingTipRetellSummary =>
      'Tóm tắt toàn bộ audio trong 3-5 câu.';

  @override
  String reviewDifficultPracticeProgress(int current, int total) {
    return 'Câu $current/$total';
  }

  @override
  String get reviewDifficultPracticeBlindListen => 'Đang nghe...';

  @override
  String get reviewDifficultPracticeCompleteTitle =>
      'Đã luyện xong các câu đã lưu';

  @override
  String get reviewDifficultPracticeNone =>
      'Không có câu đã lưu cần luyện. Đã tự động hoàn thành.';

  @override
  String get exitReviewDifficultPracticeTitle => 'Thoát luyện tập?';

  @override
  String get exitReviewDifficultPracticeMessage =>
      'Tiến độ của bước này sẽ không được lưu.';

  @override
  String get exitReviewDifficultPracticeConfirmMessage =>
      'Tiến độ sẽ được lưu và bạn có thể tiếp tục lần sau.';

  @override
  String reviewDifficultPracticeAdvancing(int seconds) {
    return 'Câu tiếp theo sau ${seconds}s';
  }

  @override
  String get aiSectionTitle => 'AI';

  @override
  String get speechRecognition => 'Nhận dạng giọng nói';

  @override
  String get speechRecognitionNotConfigured => 'Chưa thiết lập';

  @override
  String get speechRecognitionEnabled => 'Đã bật';

  @override
  String get speechRecognitionDisabled => 'Đã tắt';

  @override
  String get speechRecognitionDescription =>
      'Nhận dạng giọng nói dùng để chấm điểm luyện tập và phiên âm cục bộ sau này. Hãy chọn mô hình phù hợp với thiết bị của bạn.';

  @override
  String get asrEngine => 'Công cụ giọng nói';

  @override
  String get asrBackendPlatform => 'Apple AI';

  @override
  String get asrBackendPlatformDescription =>
      'Dùng nhận dạng giọng nói tích hợp sẵn của hệ thống. Không cần tải về';

  @override
  String get asrBackendOffline => 'Study Loop AI';

  @override
  String get asrBackendOfflineDescription =>
      'Dùng mô hình AI của ứng dụng. Dùng được ngoại tuyến sau khi tải về';

  @override
  String asrModelTier(String tier) {
    return 'Mô hình: $tier (tự chọn theo thiết bị của bạn)';
  }

  @override
  String get asrModelFastDescription =>
      'Nhanh nhất. Phù hợp thiết bị cấu hình thấp.';

  @override
  String get asrModelBalancedDescription =>
      'Cân bằng giữa độ chính xác và tốc độ.';

  @override
  String get asrModelAccurateDescription =>
      'Chính xác hơn, nhưng nặng và chậm hơn.';

  @override
  String get localSpeechRecognition => 'Nhận dạng giọng nói cục bộ';

  @override
  String speechModelSize(String size) {
    return 'Dung lượng mô hình: ~$size';
  }

  @override
  String speechModelApproxSize(String size) {
    return '~$size';
  }

  @override
  String speechModelReady(String size) {
    return 'Sẵn sàng · $size';
  }

  @override
  String get speechModelStatusReady => 'Sẵn sàng';

  @override
  String get speechModelStatusNeedsDownload => 'Tải về';

  @override
  String speechModelDownloading(String progress) {
    return 'Đang tải... $progress';
  }

  @override
  String get speechModelDownloadFailed => 'Tải thất bại. Chạm để thử lại.';

  @override
  String get downloadErrorStorage =>
      'Không đủ dung lượng. Hãy giải phóng bộ nhớ rồi thử lại.';

  @override
  String get downloadErrorNetwork =>
      'Lỗi mạng. Hãy kiểm tra kết nối rồi thử lại.';

  @override
  String get downloadErrorCorrupted =>
      'Xác minh tệp đã tải thất bại. Vui lòng thử lại.';

  @override
  String deleteModel(String size) {
    return 'Xóa mô hình ($size)';
  }

  @override
  String get deleteModelAction => 'Xóa mô hình';

  @override
  String get deleteModelConfirmTitle => 'Xóa mô hình?';

  @override
  String deleteModelConfirmMessage(String size) {
    return 'Việc này sẽ giải phóng $size dung lượng.';
  }

  @override
  String get disableSpeechRecognitionTitle => 'Tắt nhận dạng giọng nói?';

  @override
  String get disableSpeechRecognitionMessage =>
      'Sẽ không thể chấm điểm giọng nói.';

  @override
  String get alsoDeleteModel => 'Xóa luôn mô hình đã tải';

  @override
  String get disableAction => 'Tắt';

  @override
  String get speechRecognitionRequiredMessage =>
      'Nhận dạng giọng nói được dùng để tự động đánh giá phát âm và phần kể lại của bạn. Cần tải mô hình trước khi bắt đầu.';

  @override
  String get asrModelDownloadRequiredTitle => 'Cần mô hình nhận dạng giọng nói';

  @override
  String asrModelDownloadEstimate(String size) {
    return 'Dung lượng tải ước tính: ~$size';
  }

  @override
  String get asrModelDownloadSettingsHint =>
      'Bạn cũng có thể chọn mô hình nhận dạng giọng nói khác trong Cài đặt.';

  @override
  String get asrModelDownloadingTitle => 'Đang tải mô hình nhận dạng giọng nói';

  @override
  String asrModelDownloadingMessage(String size) {
    return 'Dung lượng tải ước tính: ~$size';
  }

  @override
  String asrModelDownloadProgress(String progress) {
    return 'Đã xong $progress';
  }

  @override
  String get asrModelDownloadFailedTitle =>
      'Tải mô hình nhận dạng giọng nói thất bại';

  @override
  String asrModelDownloadFailedMessage(String size) {
    return 'Chưa tải xong. Dung lượng tải ước tính: ~$size';
  }

  @override
  String get asrDownloadModel => 'Tải mô hình';

  @override
  String get downloadNow => 'Tải ngay';

  @override
  String get later => 'Để sau';

  @override
  String get speechRecognitionNotEnabled =>
      'Chưa bật nhận dạng giọng nói. Hãy bật trong Cài đặt.';

  @override
  String get retryDownload => 'Thử lại';

  @override
  String get developer => 'Nhà phát triển';

  @override
  String get developerOptionsEnabled => 'Đã bật tùy chọn nhà phát triển';

  @override
  String get developerOptionsDisable => 'Tắt tùy chọn nhà phát triển';

  @override
  String get timeMachine => 'Cỗ máy thời gian';

  @override
  String get timeMachineUseSystemTime => 'Dùng giờ hệ thống';

  @override
  String get timeMachineCurrentTime => 'Giờ gỡ lỗi';

  @override
  String get timeMachineSelectDate => 'Chọn ngày';

  @override
  String get timeMachineSelectTime => 'Chọn giờ';

  @override
  String get timeMachineReset => 'Dùng giờ hệ thống';

  @override
  String get manageSubtitles => 'Quản lý phụ đề';

  @override
  String get localUpload => 'Tải lên từ máy';

  @override
  String get aiTranscription => 'Phiên âm đám mây';

  @override
  String get aiTranscriptionSubtitle => 'Chính xác hơn, cần mạng và đăng nhập';

  @override
  String get offlineTranscription => 'Phiên âm trên thiết bị';

  @override
  String get offlineTranscriptionSubtitle =>
      'Ngoại tuyến, riêng tư, không cần đăng nhập';

  @override
  String get transcriptionModelTier => 'Mô hình nhận dạng';

  @override
  String get localTranscriptionDecoding => 'Đang giải mã audio...';

  @override
  String get localTranscriptionForegroundHint =>
      'Hãy giữ ứng dụng mở và hiển thị trên màn hình cho đến khi xong — quá trình phiên âm sẽ tạm dừng nếu bạn chuyển ứng dụng hoặc khóa màn hình.';

  @override
  String localTranscriptionProgressPercent(int percent) {
    return 'Đã xong $percent%';
  }

  @override
  String get localTranscriptionModelRequiredTitle => 'Cần mô hình giọng nói';

  @override
  String localTranscriptionModelRequiredMessage(String modelName) {
    return 'Phiên âm trên thiết bị cần tải mô hình giọng nói $modelName một lần (sau đó dùng ngoại tuyến).';
  }

  @override
  String get deleteSubtitle => 'Xóa phụ đề';

  @override
  String get startTranscription => 'Bắt đầu phiên âm';

  @override
  String get alreadyTranscribedWithOption => 'Đã phiên âm bằng tùy chọn này';

  @override
  String get transcriptionUploading => 'Đang tải lên...';

  @override
  String get transcriptionCompressing => 'Đang nén audio...';

  @override
  String get transcriptionProcessing => 'Đang phiên âm...';

  @override
  String get transcriptionComplete => 'Xong!';

  @override
  String get transcriptionFailed => 'Phiên âm thất bại';

  @override
  String get transcriptionErrorConnection => 'Không thể kết nối máy chủ';

  @override
  String get transcriptionErrorTimeout =>
      'Yêu cầu hết thời gian, vui lòng thử lại';

  @override
  String get transcriptionErrorServer => 'Hãy kiểm tra audio rồi thử lại sau';

  @override
  String get transcriptionErrorUnknown => 'Hãy kiểm tra audio rồi thử lại sau';

  @override
  String get transcriptionErrorCompression =>
      'Nén audio thất bại. Hãy kiểm tra audio rồi thử lại.';

  @override
  String get transcriptionErrorCompressedFileTooLarge =>
      'Tệp sau khi nén vẫn vượt quá 25MB';

  @override
  String get transcriptionErrorAudioNotFound =>
      'Không tìm thấy audio đã tải lên. Vui lòng thử lại.';

  @override
  String get transcriptionErrorAudioExpired =>
      'Audio đã tải lên đã hết hạn. Vui lòng thử lại.';

  @override
  String get transcriptionErrorRequestInvalid =>
      'Yêu cầu phiên âm không hợp lệ. Hãy cập nhật ứng dụng rồi thử lại.';

  @override
  String get transcriptionErrorApiDeprecated =>
      'Phiên bản ứng dụng này không còn được hỗ trợ. Hãy cập nhật ứng dụng.';

  @override
  String get transcriptionEmptyResult => 'Không phát hiện giọng nói';

  @override
  String get transcriptionEmptyResultHint =>
      'Audio có thể có quá nhiều tiếng ồn nền.';

  @override
  String transcriptionErrorFileTooLarge(int maxMb) {
    return 'Tệp quá lớn (tối đa ${maxMb}MB)';
  }

  @override
  String transcriptionErrorTooLong(int maxMin) {
    return 'Audio quá dài (tối đa $maxMin phút)';
  }

  @override
  String get deleteSubtitleConfirm => 'Bạn có chắc muốn xóa phụ đề?';

  @override
  String get deleteSubtitleWarning =>
      'Xóa phụ đề cũng sẽ xóa toàn bộ câu đã lưu và tiến độ học của audio này.';

  @override
  String get languageAutoDetect => 'Tự động nhận diện';

  @override
  String get mixedLanguageNotSupported => 'Chưa hỗ trợ audio nhiều ngôn ngữ';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get autoMergeShortSentences => 'Tự động gộp câu ngắn';

  @override
  String get autoMergeShortSentencesHint =>
      'Mục tiêu 4-7 giây; tắt để giữ các câu ngắn hơn';

  @override
  String get overwriteExistingSubtitle => 'Ghi đè phụ đề hiện có?';

  @override
  String get overwriteExistingSubtitleMessage =>
      'Việc này sẽ thay thế phụ đề hiện tại. Tiếp tục?';

  @override
  String get overwrite => 'Ghi đè';

  @override
  String get audioContentEmptyWarning => 'Có thể trống';

  @override
  String get audioContentDamagedWarning => 'Audio có vấn đề';

  @override
  String get audioContentSilentWarning => 'Có thể im lặng';

  @override
  String get transcriptionDamagedConfirmTitle => 'Audio có thể bị hỏng';

  @override
  String get transcriptionDamagedConfirmMessage =>
      'Audio này có thể bị hỏng hoặc có định dạng không tương thích. Vẫn phiên âm?';

  @override
  String get transcriptionSilentConfirmTitle => 'Audio có thể trống';

  @override
  String get transcriptionSilentConfirmMessage =>
      'Audio này dường như im lặng, không có giọng nói. Vẫn phiên âm?';

  @override
  String get transcriptionSilentConfirmProceed => 'Vẫn phiên âm';

  @override
  String transcriptionAudioFileSize(Object size) {
    return 'Dung lượng tệp: $size';
  }

  @override
  String transcriptionAudioDuration(Object duration) {
    return 'Thời lượng: $duration';
  }

  @override
  String get transcriptionAudioUnknown => 'Không xác định được';

  @override
  String get currentSubtitleExists => 'Hiện tại: Có phụ đề';

  @override
  String get currentSubtitleLocal => 'Hiện tại: Tải lên từ máy';

  @override
  String currentSubtitleAi(String language) {
    return 'Hiện tại: AI ($language)';
  }

  @override
  String get noSubtitleYet => 'Chưa có phụ đề';

  @override
  String get addSubtitlePromptTitle => 'Thêm phụ đề?';

  @override
  String get addSubtitlePromptMessage => 'Thêm phụ đề ngay để học?';

  @override
  String get selectCollection => 'Bộ sưu tập (tùy chọn)';

  @override
  String get noCollection => 'Không';

  @override
  String get addSubtitle => 'Thêm phụ đề';

  @override
  String get retryTranscription => 'Thử lại';

  @override
  String transcriptionFailedMessage(String message) {
    return 'Lỗi: $message';
  }

  @override
  String todayStudyTime(String time) {
    return 'Hôm nay: $time';
  }

  @override
  String studyTimeMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String studyTimeHoursMinutes(int hours, int minutes) {
    return '${hours}g ${minutes}p';
  }

  @override
  String get studyTasks => 'Nhiệm vụ học';

  @override
  String get continueLearningHero => 'Tiếp tục học';

  @override
  String get startButton => 'Bắt đầu';

  @override
  String get continueButton => 'Tiếp tục';

  @override
  String streakDays(int count) {
    return 'Chuỗi $count ngày';
  }

  @override
  String get todayStudyTimeShort => 'Hôm nay';

  @override
  String get weekStudyTimeShort => 'Tuần này';

  @override
  String readyToReview(int count) {
    return 'Sẵn sàng ôn tập ($count)';
  }

  @override
  String upcomingReviews(int count) {
    return 'Sắp mở khóa ($count)';
  }

  @override
  String upcomingReviewsSummary(int count) {
    return '$count nhiệm vụ ôn tập sẽ mở khóa sau';
  }

  @override
  String get recommendedForYou => 'Gợi ý cho bạn';

  @override
  String completedSection(int count) {
    return 'Tài liệu đã học xong ($count)';
  }

  @override
  String get noStudyTasks => 'Chưa có nhiệm vụ học';

  @override
  String get noStudyTasksHint => 'Hãy nhập tệp audio để bắt đầu luyện tập.';

  @override
  String get goToLibrary => 'Đến Thư viện';

  @override
  String get allDoneTitle => 'Tạm xong hết rồi!';

  @override
  String get allDoneHint => 'Làm tốt lắm! Hãy quay lại sau để ôn tập.';

  @override
  String overdueDays(int count) {
    return 'Quá hạn $count ngày';
  }

  @override
  String overdueHours(int count) {
    return 'Quá hạn $count giờ';
  }

  @override
  String get reviewDue => 'Đến hạn ôn tập';

  @override
  String availableInDays(int count) {
    return 'sau $count ngày';
  }

  @override
  String availableInHours(int count) {
    return 'sau $count giờ';
  }

  @override
  String subStageLabelFirstLearn(String subStage) {
    return 'Vòng đầu - $subStage';
  }

  @override
  String subStageLabelReview(String reviewName, String subStage) {
    return '$reviewName - $subStage';
  }

  @override
  String get favoritesSentences => 'Câu';

  @override
  String get favoritesVocabulary => 'Từ vựng';

  @override
  String get favoritesNoSentences => 'Chưa có câu đã lưu';

  @override
  String get favoritesNoSentencesHint =>
      'Đánh dấu các câu khó khi nghe kỹ từng câu hoặc nhắc lại';

  @override
  String get favoritesNoVocabulary => 'Chưa có từ vựng đã lưu';

  @override
  String get favoritesNoVocabularyHint => 'Chạm vào một từ để tra cứu và lưu';

  @override
  String favoritesBookmarkCount(int count) {
    return '$count câu';
  }

  @override
  String get favoritesVocabularySaved => 'Đã lưu';

  @override
  String get favoritesVocabularyRemoved => 'Đã bỏ';

  @override
  String get favoritesBookmarkRemoved => 'Đã bỏ đánh dấu';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get favoritesSaveVocabulary => 'Lưu';

  @override
  String get favoritesUnsaveVocabulary => 'Bỏ lưu';

  @override
  String get bookmarkReviewTitle => 'Ôn tập câu đã lưu';

  @override
  String get bookmarkReviewStart => 'Bắt đầu ôn tập';

  @override
  String bookmarkReviewStartCount(int count) {
    return 'Bắt đầu ôn tập ($count)';
  }

  @override
  String bookmarkReviewDueCount(int count) {
    return '$count đến hạn ôn tập';
  }

  @override
  String get bookmarkReviewNothingToReview => 'Xong hết rồi!';

  @override
  String favoriteVocabularyReviewDueCount(int count) {
    return '$count đến hạn ôn tập';
  }

  @override
  String get favoriteReviewNothingToReview => 'Xong hết rồi!';

  @override
  String get bookmarkReviewComplete => 'Hoàn thành ôn tập';

  @override
  String get bookmarkReviewAgain => 'Ôn lại';

  @override
  String get bookmarkReviewAudioSkipped => 'Không có audio, bỏ qua câu này';

  @override
  String bookmarkReviewFromAudio(String name) {
    return 'Từ: $name';
  }

  @override
  String get favoriteSourceMaterialNotFound => 'Không tìm thấy tài liệu nguồn';

  @override
  String get bookmarkReviewUnsave => 'Bỏ lưu';

  @override
  String get bookmarkReviewTapReplay => 'Nghe rồi nhớ lại';

  @override
  String get bookmarkReviewLoadingAudio => 'Đang tải audio…';

  @override
  String get bookmarkReviewPlaying => 'Đang phát';

  @override
  String get bookmarkReviewPlayOriginal => 'Nghe lại';

  @override
  String get bookmarkReviewTapRetry => 'Chạm để thử lại';

  @override
  String get bookmarkReviewListenPrompt => 'Chạm để phát lại từ đầu';

  @override
  String get bookmarkReviewReadyTitle => 'Lật khi đã sẵn sàng';

  @override
  String get bookmarkReviewRevealHint => 'Chạm để xem đáp án';

  @override
  String get bookmarkReviewCompleted => 'Xong hết rồi!';

  @override
  String get bookmarkReviewUnsaveFailed =>
      'Không thể bỏ lưu câu này. Vui lòng thử lại.';

  @override
  String get bookmarkReviewSettingsPlaceholderTitle => 'Cài đặt ôn tập';

  @override
  String get bookmarkReviewSettingsPlaceholderBody =>
      'Thêm tùy chọn ôn tập sẽ có trong bản cập nhật sau.';

  @override
  String get bookmarkReviewSettingsTitle => 'Cài đặt ôn tập';

  @override
  String get bookmarkReviewShowNextReviewTime =>
      'Hiện thời gian ôn tập tiếp theo';

  @override
  String get favoriteReviewAutoPlayFront => 'Tự phát mặt trước';

  @override
  String get favoriteReviewAutoPlayBack => 'Tự phát mặt sau';

  @override
  String get favoriteReviewShowVocabularyOnFront => 'Hiện từ vựng ở mặt trước';

  @override
  String get bookmarkReviewDailyGoal => 'Mục tiêu ôn tập hằng ngày';

  @override
  String get favoriteReviewSentenceSettings => 'Ôn tập câu đã lưu';

  @override
  String get favoriteReviewVocabularySettings => 'Ôn tập từ vựng đã lưu';

  @override
  String get favoriteReviewSentenceDailyGoal => 'Mục tiêu ôn câu hằng ngày';

  @override
  String get favoriteReviewVocabularyDailyGoal =>
      'Mục tiêu ôn từ vựng hằng ngày';

  @override
  String get bookmarkReviewUnlimited => 'Không giới hạn';

  @override
  String get bookmarkReviewOrder => 'Thứ tự ôn tập';

  @override
  String get bookmarkReviewOrderSmart => 'Tự động';

  @override
  String get bookmarkReviewOrderDueAt => 'Đến hạn sớm nhất trước';

  @override
  String get bookmarkReviewOrderRandom => 'Ngẫu nhiên';

  @override
  String get bookmarkReviewRatingAgain => 'Chưa nghe ra';

  @override
  String get bookmarkReviewRatingGood => 'Nghe ra rồi';

  @override
  String get favoriteVocabularyReviewTitle => 'Ôn tập từ vựng đã lưu';

  @override
  String get favoriteVocabularyReviewCompleted => 'Xong hết rồi!';

  @override
  String get favoriteVocabularyReviewTapReplay => 'Chạm để phát lại';

  @override
  String get favoriteVocabularyReviewLoadingAudio => 'Đang tải audio…';

  @override
  String get favoriteVocabularyReviewPlaying => 'Đang phát';

  @override
  String get favoriteVocabularyReviewTapRetry => 'Chạm để thử lại';

  @override
  String get favoriteVocabularyReviewAudioSkipped =>
      'Không có audio, chạm để thử lại';

  @override
  String get favoriteVocabularyReviewReadyTitle => 'Lật khi đã sẵn sàng';

  @override
  String get favoriteVocabularyReviewRevealHint => 'Chạm để xem mặt sau';

  @override
  String get favoriteVocabularyReviewBackPlaceholder => 'Mặt sau sắp ra mắt';

  @override
  String get bookmarkReviewRatingEasy => 'Dễ';

  @override
  String get difficultPracticeSettings => 'Cài đặt luyện tập';

  @override
  String get difficultPracticeSettingsHint =>
      'Cài đặt chỉ áp dụng cho buổi này';

  @override
  String get difficultPracticeBlindListenRepeat => 'Số lần nghe không phụ đề';

  @override
  String get difficultPracticeShadowReadingRepeat => 'Số lần nghe và nhắc lại';

  @override
  String get inputWordsShort => 'Đầu vào';

  @override
  String get outputWordsShort => 'Đầu ra';

  @override
  String listenTimeWords(String time, String words) {
    return 'Nghe: $time · $words';
  }

  @override
  String speakTimeWords(String time, String words) {
    return 'Nói: $time · $words';
  }

  @override
  String get learnedWordFormsShort => 'Từ vựng';

  @override
  String get todayNewShort => 'Hôm nay';

  @override
  String get learnedWordsEmptyHint =>
      'Chưa học từ nào. Hãy hoàn thành một buổi nghe trước.';

  @override
  String get learnedWordsSortTimeAsc => 'Học sớm nhất';

  @override
  String get learnedWordsSortTimeDesc => 'Học gần đây';

  @override
  String bookmarkReviewProgress(int current, int total) {
    return 'Câu $current/$total';
  }

  @override
  String get flashcardTitle => 'Thẻ ghi nhớ';

  @override
  String get flashcardViewAnswer => 'Sẵn sàng? Xem đáp án';

  @override
  String get flashcardTapToFlip => 'Chạm để lật lại';

  @override
  String get flashcardUnsaveHint => 'Bỏ lưu khi đã thuộc';

  @override
  String flashcardProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get flashcardComplete => 'Hoàn thành ôn tập';

  @override
  String flashcardWordsReviewed(int count) {
    return 'Đã ôn $count từ';
  }

  @override
  String flashcardWordsRemoved(int count) {
    return 'Đã bỏ lưu $count từ';
  }

  @override
  String get flashcardPracticeAgain => 'Luyện lại';

  @override
  String get flashcardFinish => 'Xong';

  @override
  String get flashcardSettingsTitle => 'Cài đặt thẻ ghi nhớ';

  @override
  String get flashcardSettingsSubtitle => 'Cài đặt được lưu tự động';

  @override
  String get flashcardControlModeLabel => 'Chế độ điều khiển';

  @override
  String get flashcardControlModeAuto => 'Tự động';

  @override
  String get flashcardControlModeManual => 'Thủ công';

  @override
  String get flashcardControlModeAutoDesc => 'Tự lật, tự chuyển thẻ';

  @override
  String get flashcardControlModeManualDesc => 'Lật và chuyển thẻ thủ công';

  @override
  String get flashcardTimerMode => 'Thời gian chuyển thẻ';

  @override
  String get flashcardTimerSmart => 'Tự động';

  @override
  String get flashcardTimerSmartDesc =>
      'Điều chỉnh theo độ khó của từ và số lần luyện';

  @override
  String get flashcardTimerFixed => 'Cố định';

  @override
  String get flashcardTimerFixedDesc =>
      'Đặt thời gian cố định cho mặt trước và mặt sau';

  @override
  String get flashcardTimerFrontDuration => 'Mặt trước';

  @override
  String get flashcardTimerBackDuration => 'Mặt sau';

  @override
  String get flashcardSortMode => 'Thứ tự danh sách từ';

  @override
  String get flashcardSortAlphaAsc => 'A → Z';

  @override
  String get flashcardSortAlphaDesc => 'Z → A';

  @override
  String get flashcardSortTimeAsc => 'Cũ nhất';

  @override
  String get flashcardSortTimeDesc => 'Mới nhất';

  @override
  String get flashcardSortRandom => 'Ngẫu nhiên';

  @override
  String get flashcardSortSmart => 'Tự động';

  @override
  String get flashcardSortSmartDesc => 'Sắp xếp theo quy luật ghi nhớ';

  @override
  String get flashcardSortRandomDesc => 'Xáo trộn ngẫu nhiên mỗi lần';

  @override
  String get flashcardSortAlphaAscDesc => 'Sắp xếp A đến Z';

  @override
  String get flashcardSortAlphaDescDesc => 'Sắp xếp Z đến A';

  @override
  String get flashcardSortTimeAscDesc => 'Lưu cũ nhất trước';

  @override
  String get flashcardSortTimeDescDesc => 'Lưu mới nhất trước';

  @override
  String get flashcardNoDefinition => 'Chưa có định nghĩa';

  @override
  String get flashcardStartQuiz => 'Bắt đầu ôn tập';

  @override
  String get flashcardTts => 'Phát âm';

  @override
  String get flashcardAutoPlaySentence => 'Tự phát câu';

  @override
  String get flashcardAutoPlayWord => 'Tự phát từ';

  @override
  String get freePlay => 'Nghe theo ý bạn';

  @override
  String get wordAiAnalysis => 'Phân tích AI';

  @override
  String get wordAiContextMeaning => 'Nghĩa theo ngữ cảnh';

  @override
  String get wordAiCollocations => 'Cụm từ đi kèm';

  @override
  String get wordAiUsage => 'Ghi chú cách dùng';

  @override
  String get wordAiWordFamily => 'Họ từ';

  @override
  String get storage => 'Khác';

  @override
  String get clearCache => 'Xóa bộ nhớ đệm';

  @override
  String get clearCacheConfirm =>
      'Thao tác này xóa bộ nhớ đệm tạm để giải phóng dung lượng. Bản ghi học tập và mục yêu thích của bạn không bị ảnh hưởng, dữ liệu sẽ được tạo lại khi cần. Tiếp tục?';

  @override
  String get clearCacheSuccess => 'Đã xóa bộ nhớ đệm';

  @override
  String clearCacheSuccessWithSize(String size) {
    return 'Đã xóa bộ nhớ đệm, giải phóng $size';
  }

  @override
  String get clearCacheEmpty => 'Bộ nhớ đệm đã trống';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get autoCompletedNoDifficultReview => '0 câu đã lưu, bỏ qua';

  @override
  String get termsOfService => 'Điều khoản dịch vụ';

  @override
  String get privacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get writeFeedback => 'Gửi phản hồi';

  @override
  String get rateUs => 'Đánh giá ứng dụng';

  @override
  String get joinCommunity => 'Tham gia cộng đồng';

  @override
  String get aboutCommunity => 'Tham gia cộng đồng';

  @override
  String get joinCommunityInviteSubtitle => 'Học hỏi, đặt câu hỏi và chia sẻ';

  @override
  String get networkError =>
      'Không thể kết nối. Vui lòng kiểm tra mạng và thử lại.';

  @override
  String get viewSourceCode => 'Dự án mã nguồn mở';

  @override
  String updateAvailable(String version) {
    return 'Phiên bản mới v$version';
  }

  @override
  String get updateNow => 'Cập nhật ngay';

  @override
  String get updateLater => 'Để sau';

  @override
  String get forceUpdateTitle => 'Cần cập nhật';

  @override
  String get forceUpdateMessage =>
      'Phiên bản hiện tại không còn được hỗ trợ. Vui lòng cập nhật để tiếp tục.';

  @override
  String get releaseNotesTitle => 'Có gì mới';

  @override
  String get copyDownloadLink => 'Sao chép liên kết tải xuống';

  @override
  String get linkCopied => 'Đã sao chép liên kết';

  @override
  String get checkForUpdate => 'Kiểm tra cập nhật';

  @override
  String get alreadyLatest => 'Đã là phiên bản mới nhất';

  @override
  String get checkUpdateFailed => 'Kiểm tra thất bại, vui lòng kiểm tra mạng';

  @override
  String get updateDownloading => 'Đang tải bản cập nhật…';

  @override
  String get updateInstallPermissionHint =>
      'Hãy cho phép cài ứng dụng từ nguồn này, rồi quay lại app';

  @override
  String get updateDownloadFailed =>
      'Tải bản cập nhật thất bại, đang mở trình duyệt…';

  @override
  String get demoMode => 'Chế độ demo';

  @override
  String get demoModeSubtitle => 'Dùng dữ liệu demo để chụp ảnh màn hình';

  @override
  String get practiceRemoveMark => 'Bỏ đánh dấu';

  @override
  String get practiceAddMark => 'Đánh dấu lại';

  @override
  String blindListenSegmentProgress(int current, int total) {
    return 'Đoạn $current/$total';
  }

  @override
  String blindListenSegmentDuration(int duration) {
    return '${duration}s';
  }

  @override
  String get blindListenListeningHint => 'Hãy lắng nghe kỹ...';

  @override
  String get blindListenPreListenHint => 'Nghe trước, sau đó nhớ lại';

  @override
  String blindListenRepeatInfo(int current, int total) {
    return 'Lượt $current/$total';
  }

  @override
  String get blindListenSettingsTitle => 'Cài đặt nghe';

  @override
  String get blindListenPauseBetween => 'Nghỉ giữa các đoạn';

  @override
  String get blindListenTargetDuration => 'Độ dài đoạn';

  @override
  String get blindListenDisplayHideAll => 'Ẩn phụ đề';

  @override
  String get blindListenDisplayShowAll => 'Hiện phụ đề';

  @override
  String get blindListenRecallHint => 'Nhớ lại những gì bạn vừa nghe';

  @override
  String get blindListenControlModeAutoDesc =>
      'Tự lặp lại, tự tạm dừng, tự chuyển tiếp';

  @override
  String get blindListenControlModeManualDesc =>
      'Chạm để nghe lại, chạm để sang tiếp';

  @override
  String get blindListenNoParagraph => 'Chưa chia đoạn';

  @override
  String blindListenParagraphCount(int count) {
    return '$count đoạn';
  }

  @override
  String get resetLearningProgress => 'Đặt lại tiến độ';

  @override
  String get resetLearningProgressConfirmTitle => 'Đặt lại tiến độ học?';

  @override
  String resetLearningProgressConfirmMessage(String name) {
    return 'Thao tác này sẽ xóa toàn bộ tiến độ học của \"$name\". Không thể hoàn tác.';
  }

  @override
  String get resetLearningProgressDone => 'Đã đặt lại tiến độ học';

  @override
  String get pauseLearning => 'Tạm dừng';

  @override
  String get resumeLearning => 'Tiếp tục học';

  @override
  String get pausedChipLabel => 'Đã tạm dừng';

  @override
  String get pauseLearningConfirmTitle => 'Tạm dừng học?';

  @override
  String get pauseLearningConfirmMessage =>
      'Lịch ôn tập cho audio này sẽ dừng lại. Bạn có thể tiếp tục bất cứ lúc nào.';

  @override
  String reviewReminderBody(String audioName, int round) {
    return '$audioName · Đã đến lượt ôn tập $round';
  }

  @override
  String get stageBlindListen => 'Nghe không phụ đề';

  @override
  String get stageIntensiveListen => 'Nghe từng câu';

  @override
  String get stageListenAndRepeat => 'Nghe và nhắc lại';

  @override
  String get stageRetell => 'Nghe và kể lại';

  @override
  String get stageReviewDifficultPractice => 'Luyện các câu đã lưu';

  @override
  String get stageBookmarkReview => 'Ôn tập câu';

  @override
  String get stageFlashcard => 'Ôn tập từ vựng';

  @override
  String stageBreakdownTitle(String date) {
    return '$date';
  }

  @override
  String get stageBreakdownToday => ' (Hôm nay)';

  @override
  String get stageBreakdownTotal => 'Tổng';

  @override
  String get stageBreakdownLessThanOneMin => '<1 phút';

  @override
  String get stageBreakdownListenShort => 'Nghe';

  @override
  String get stageBreakdownSpeakShort => 'Nói';

  @override
  String get stageBreakdownNoStageData =>
      'Dữ liệu chi tiết bắt đầu được ghi từ phiên bản này';

  @override
  String get stageBreakdownNoRecord => 'Không có bản ghi học tập cho ngày này';

  @override
  String get chartLegendListening => 'Nghe';

  @override
  String get chartLegendSpeaking => 'Nói';

  @override
  String get chartLegendOther => 'Khác';

  @override
  String get chartLegendOtherHint => 'Suy nghĩ, tạm dừng, v.v.';

  @override
  String get reminderSectionTitle => 'Nhắc nhở';

  @override
  String get reminderSettings => 'Nhắc ôn tập';

  @override
  String get savedReviewReminderSection => 'Nhắc ôn tập mục “Đã lưu”';

  @override
  String get savedReviewReminderToggle => 'Nhắc nội dung đã lưu';

  @override
  String get savedReviewReminderTime => 'Giờ nhắc hằng ngày';

  @override
  String get savedReviewReminderDescription =>
      'Ôn nội dung đã lưu khi di chuyển hoặc trước khi ngủ để đạt hiệu quả tốt nhất';

  @override
  String get audioReviewReminderSection => 'Nhắc ôn tập audio';

  @override
  String get audioReviewReminderToggle => 'Nhắc audio đến hạn';

  @override
  String get audioReviewReminderDescription =>
      'Nhận thông báo khi đến lúc ôn tập, giúp bạn học đều đặn';

  @override
  String get notificationPromptTitle => 'Ghi nhớ những gì bạn đã học';

  @override
  String get notificationPromptBody =>
      'Trí nhớ bền hơn khi bạn ôn đúng thời điểm. Chúng tôi chỉ nhắc khi thật sự cần.';

  @override
  String get notificationPromptTitleLearning => 'Ôn tập khi còn nhớ rõ';

  @override
  String get notificationPromptBodyLearning =>
      'Bật nhắc nhở — chúng tôi sẽ nhắc đúng lúc để củng cố những gì bạn vừa học.';

  @override
  String get notificationPromptTitleBookmark => 'Đừng quên các mục đã lưu';

  @override
  String get notificationPromptBodyBookmark =>
      'Bật nhắc nhở để ôn nội dung đã lưu theo lịch đều đặn.';

  @override
  String get notificationPromptCtaGrant => 'Bật nhắc nhở';

  @override
  String get notificationPromptCtaDismiss => 'Để sau';

  @override
  String get notificationDisabledBanner =>
      'Thông báo đang tắt. Bạn sẽ không nhận được nhắc ôn tập.';

  @override
  String get notificationDisabledBannerCta => 'Mở Cài đặt';

  @override
  String get notificationNotGrantedBanner =>
      'Cho phép thông báo để nhận nhắc ôn tập hằng ngày.';

  @override
  String get notificationNotGrantedBannerCta => 'Bật';

  @override
  String recentCompletions(int count) {
    return 'Vừa hoàn thành ($count)';
  }

  @override
  String get recentCompletionsSummary => '24 giờ qua';

  @override
  String get timeAgoJustNow => 'Vừa xong';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours giờ trước';
  }

  @override
  String timeFromNowSeconds(int seconds) {
    return 'sau $seconds giây';
  }

  @override
  String get exportAudio => 'Xuất audio';

  @override
  String get exportAudioFile => 'Audio';

  @override
  String get exportVideo => 'Xuất video';

  @override
  String get exportVideoFile => 'Video';

  @override
  String get exportSubtitleFile => 'Phụ đề';

  @override
  String get exportSelectFiles => 'Chọn tệp để xuất';

  @override
  String get exportPdf => 'Xuất PDF';

  @override
  String get pdfExporting => 'Đang tạo PDF…';

  @override
  String pdfExportFailed(String error) {
    return 'Xuất PDF thất bại: $error';
  }

  @override
  String pdfMetaDuration(String duration) {
    return 'Thời lượng $duration';
  }

  @override
  String pdfMetaSentences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count câu',
      one: '1 câu',
    );
    return '$_temp0';
  }

  @override
  String pdfMetaWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count từ',
      one: '1 từ',
    );
    return '$_temp0';
  }

  @override
  String get pdfAppendixTitle => 'Phụ lục · Phân tích câu';

  @override
  String get pdfPreviewTitle => 'Xem trước bản xuất';

  @override
  String get pdfShare => 'Chia sẻ';

  @override
  String get pdfOptionTranslation => 'Bản dịch các câu đã lưu';

  @override
  String get pdfOptionVocab => 'Nghĩa các từ đã lưu';

  @override
  String get pdfOptionAnalysis => 'Phân tích câu trọng tâm';

  @override
  String get pdfExportReminderTitle => 'PDF là ghi chú ôn tập của bạn';

  @override
  String get pdfExportReminderMessage =>
      'Bạn nên xuất PDF sau khi hoàn thành Vòng đầu tiên.\n\nNghe từng câu, nhắc lại và nghe không phụ đề giúp bạn nắm vững những gì đã nghe, còn PDF tổng hợp bản dịch và phân tích của các câu đã lưu cùng các từ đã lưu để ôn lại sau.';

  @override
  String get pdfExportReminderConfirm => 'Đã hiểu';

  @override
  String get exportData => 'Xuất dữ liệu';

  @override
  String get exportDataSubtitle => 'Xuất toàn bộ dữ liệu ra tệp ZIP';

  @override
  String get importData => 'Nhập dữ liệu';

  @override
  String get importDataSubtitle => 'Khôi phục dữ liệu từ tệp sao lưu';

  @override
  String get exporting => 'Đang xuất...';

  @override
  String get importing => 'Đang nhập...';

  @override
  String get exportSuccess => 'Xuất hoàn tất';

  @override
  String get downloadSuccess => 'Tải xuống hoàn tất';

  @override
  String get importSuccess => 'Nhập hoàn tất';

  @override
  String get importConfirmTitle => 'Xác nhận nhập';

  @override
  String get importConfirmMessage =>
      'Thao tác này sẽ thay thế toàn bộ dữ liệu hiện tại, gồm tiến độ học, mục đã lưu và tệp audio. Không thể hoàn tác.';

  @override
  String get backupTime => 'Thời gian sao lưu';

  @override
  String get backupVersion => 'Phiên bản ứng dụng';

  @override
  String get backupFileCount => 'Tệp phương tiện';

  @override
  String get backupSize => 'Tổng dung lượng';

  @override
  String get importIncompatible =>
      'Bản sao lưu này được tạo bằng phiên bản ứng dụng mới hơn. Vui lòng cập nhật ứng dụng trước.';

  @override
  String get importInvalidFile => 'Tệp sao lưu không hợp lệ';

  @override
  String get exportingDatabase => 'Đang xuất cơ sở dữ liệu...';

  @override
  String get exportingPreferences => 'Đang xuất tùy chọn...';

  @override
  String get exportingMedia => 'Đang xuất tệp phương tiện...';

  @override
  String get exportingPacking => 'Đang đóng gói tệp sao lưu...';

  @override
  String get importingExtracting => 'Đang giải nén bản sao lưu...';

  @override
  String get importingMedia => 'Đang khôi phục tệp phương tiện...';

  @override
  String get importingDatabase => 'Đang khôi phục cơ sở dữ liệu...';

  @override
  String get importingPreferences => 'Đang khôi phục tùy chọn...';

  @override
  String get backupAndRestore => 'Sao lưu & Khôi phục';

  @override
  String get backupAndRestoreSubtitle =>
      'Khôi phục dữ liệu học sau khi cài lại hoặc đổi thiết bị';

  @override
  String get backupData => 'Sao lưu';

  @override
  String get backupDataSubtitle =>
      'Sao lưu dữ liệu học, phương tiện và từ điển ngoại tuyến';

  @override
  String get restoreData => 'Khôi phục';

  @override
  String get restoreDataSubtitle =>
      'Khôi phục toàn bộ dữ liệu từ tệp sao lưu cục bộ';

  @override
  String get backupReadyTitle => 'Tệp sao lưu đã sẵn sàng';

  @override
  String get backupFileName => 'Tên tệp';

  @override
  String get restoreOverwriteTitle => 'Ghi đè và khôi phục toàn bộ dữ liệu?';

  @override
  String get restoreOverwriteMessage =>
      'Thao tác này sẽ ghi đè dữ liệu học, cài đặt, tệp audio, phụ đề và từ điển trên thiết bị này. Không thể hoàn tác.';

  @override
  String get restoreOverwriteAction => 'Ghi đè & Khôi phục';

  @override
  String get exportingResources => 'Đang sao lưu từ điển ngoại tuyến...';

  @override
  String get importingResources => 'Đang khôi phục từ điển ngoại tuyến...';

  @override
  String backupFailed(String error) {
    return 'Sao lưu thất bại: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Khôi phục thất bại: $error';
  }

  @override
  String get activityCalendar => 'Lịch hoạt động';

  @override
  String get noActivityThisMonth => 'Tháng này chưa có hoạt động học';

  @override
  String get studyDurationNoRecords => 'Chưa có bản ghi học tập';

  @override
  String monthlySummaryTitle(String month) {
    return 'Thống kê $month';
  }

  @override
  String get monthlyTotal => 'Tổng';

  @override
  String get monthlyActiveDays => 'Ngày hoạt động';

  @override
  String get monthlyAvgPerDay => 'TB/ngày';

  @override
  String get monthlyBestStreak => 'Chuỗi dài nhất';

  @override
  String daysSuffix(int days) {
    return '$days ngày';
  }

  @override
  String activeDaysFraction(int active, int total) {
    return '$active/$total ngày';
  }

  @override
  String get senseGroupSplit => 'Chia thành cụm nghĩa';

  @override
  String get senseGroupLoading => 'Đang chia...';

  @override
  String get senseGroupSingleGroup => 'Câu này chỉ có một cụm nghĩa';

  @override
  String get senseGroupSave => 'Lưu';

  @override
  String get senseGroupSaved => 'Đã lưu';

  @override
  String get annotationBtnSenseGroup => 'Cụm nghĩa';

  @override
  String get annotationBtnSenseGroupMedium => 'Cụm lớn hơn';

  @override
  String get annotationBtnSenseGroupFine => 'Cụm nhỏ hơn';

  @override
  String get annotationBtnTranslation => 'Bản dịch';

  @override
  String get annotationBtnAnalysis => 'Phân tích';

  @override
  String get senseGroupLoadFailed =>
      'Chia cụm nghĩa thất bại, vui lòng thử lại';

  @override
  String get senseGroupSignInRequiredTitle => 'Đăng nhập để dùng tính năng AI';

  @override
  String get senseGroupSignInRequiredMessage =>
      'Vui lòng đăng nhập trước khi dùng tính năng AI.';

  @override
  String get senseGroupSyntheticTimingNoticeTitle =>
      'Thời gian có thể không chính xác';

  @override
  String get senseGroupSyntheticTimingNoticeMessage =>
      'Thời gian phát cụm nghĩa này được ước tính từ phụ đề bạn tải lên nên có thể không chính xác.';

  @override
  String get transcriptionSignInRequiredTitle =>
      'Đăng nhập để dùng phiên âm AI';

  @override
  String get transcriptionSignInRequiredMessage =>
      'Phiên âm AI dùng dịch vụ chuyển giọng nói thành văn bản trên đám mây. Hãy đăng nhập để phiên âm audio bằng AI.';

  @override
  String get senseGroupNotAvailable =>
      'Audio này chưa hỗ trợ phát theo cụm nghĩa';

  @override
  String get wordTimestampsNotFound =>
      'Không tìm thấy mốc thời gian theo từ. Vui lòng khởi động lại ứng dụng để thử lại.';

  @override
  String get recycleBinTitle => 'Thùng rác';

  @override
  String get reviewStatisticsTitle => 'Thống kê ôn tập';

  @override
  String get reviewStatisticsAll => 'Tất cả';

  @override
  String get reviewStatisticsSentences => 'Câu';

  @override
  String get reviewStatisticsVocabulary => 'Từ vựng';

  @override
  String get reviewStatisticsTodayOverview => 'Tổng quan hôm nay';

  @override
  String get reviewStatisticsTodayReviewed => 'Đã ôn hôm nay';

  @override
  String get reviewStatisticsTodayCompleted => 'Hoàn thành hôm nay';

  @override
  String get reviewCompletionReviewed => 'Đã ôn';

  @override
  String get reviewStatusRemaining => 'Còn lại';

  @override
  String get reviewStatisticsDuration => 'Thời gian ôn';

  @override
  String get reviewStatisticsDue => 'Sẵn sàng';

  @override
  String reviewStatisticsCurrentDue(String count) {
    return '$count mục sẵn sàng ôn';
  }

  @override
  String get reviewStatisticsCurrentDueExplanation =>
      'Đã đến hạn và có thể bắt đầu';

  @override
  String reviewStatisticsCurrentDueBreakdown(Object overdue, Object today) {
    return '$overdue quá hạn, $today đến hạn hôm nay';
  }

  @override
  String get reviewStatisticsStreak => 'Chuỗi ngày ôn tập';

  @override
  String reviewStatisticsStreakExplanation(int count) {
    return 'Đã ôn trong $count ngày liên tiếp';
  }

  @override
  String get reviewStatisticsLearningRhythm => 'Nhịp độ học';

  @override
  String get reviewStatisticsTrend => '30 ngày qua';

  @override
  String get reviewStatisticsTrendExplanation =>
      'Số mục đã lưu khác nhau hoàn thành mỗi ngày';

  @override
  String get reviewStatisticsReviewPlan => 'Kế hoạch ôn tập';

  @override
  String get reviewStatisticsUpcoming => '7 ngày tới, gồm hôm nay';

  @override
  String get reviewStatisticsUpcomingExplanation =>
      'Các mục đã lưu đến hạn mỗi ngày';

  @override
  String get reviewStatisticsTodayShort => 'Hôm nay';

  @override
  String get reviewStatisticsRecentPerformance => 'Kết quả gần đây';

  @override
  String get reviewStatisticsRatings => 'Tỷ lệ ghi nhớ 30 ngày';

  @override
  String get reviewStatisticsRetentionRate => 'Ghi nhớ';

  @override
  String get reviewStatisticsRetentionExplanation =>
      'Dựa trên lần ôn đầu tiên của mỗi mục trong 30 ngày qua.\nTỷ lệ ghi nhớ = (Nhớ + Dễ) / Tổng';

  @override
  String get reviewStatisticsEmptyRatings => 'Chưa có đánh giá';

  @override
  String get reviewStatisticsContent => 'Nội dung đã ôn';

  @override
  String get reviewStatisticsContentExplanation =>
      'Đã hoàn thành ít nhất một lần ôn';

  @override
  String get reviewStatisticsHistory => 'Lịch sử';

  @override
  String reviewStatisticsItemCount(int count) {
    return '$count mục';
  }

  @override
  String get reviewStatisticsLoadError => 'Không thể tải thống kê';

  @override
  String get recycleBinEmpty => 'Không có mục đã xóa';

  @override
  String get recycleBinClearAll => 'Xóa tất cả';

  @override
  String recycleBinClearAllConfirm(int count) {
    return 'Xóa vĩnh viễn tất cả $count mục? Không thể hoàn tác.';
  }

  @override
  String get recycleBinRestore => 'Khôi phục';

  @override
  String get recycleBinDelete => 'Xóa';

  @override
  String get recycleBinSortTimeDesc => 'Xóa gần đây';

  @override
  String get recycleBinSortTimeAsc => 'Xóa lâu nhất';

  @override
  String recycleBinItemCount(int count) {
    return '$count mục';
  }

  @override
  String get importList => 'Danh sách nhập';

  @override
  String filesSelected(int count) {
    return 'Đã chọn $count tệp';
  }

  @override
  String processingFileOf(int current, int total) {
    return 'Đang xử lý $current/$total...';
  }

  @override
  String importingFileProgress(int current, int total, String name) {
    return 'Đang nhập $current/$total: $name';
  }

  @override
  String multipleAudioAdded(int count) {
    return 'Đã thêm $count mục';
  }

  @override
  String audioImportedCount(int count) {
    return 'Đã nhập $count mục';
  }

  @override
  String audioImportedWithSubtitleCount(int count) {
    return '$count mục có phụ đề';
  }

  @override
  String duplicatesSkipped(int count) {
    return 'Đã bỏ qua $count mục trùng';
  }

  @override
  String importFailedCount(int count) {
    return '$count thất bại';
  }

  @override
  String get duplicatesSkippedDetail =>
      'Các tệp sau có nội dung giống với mục đã có trong bộ sưu tập này nên đã bị bỏ qua:';

  @override
  String duplicateExistingFileName(String name) {
    return 'Trùng tên tệp: $name';
  }

  @override
  String duplicateOfExisting(String name) {
    return 'Cùng nội dung với \"$name\"';
  }

  @override
  String get removeFile => 'Gỡ';

  @override
  String get goToSettings => 'Đến Cài đặt';

  @override
  String get dictionaryDownloading => 'Đang tải từ điển...';

  @override
  String get dictionaryDownloadFailed => 'Tải từ điển thất bại';

  @override
  String get dictionaryNotDownloaded => 'Từ điển chưa được tải';

  @override
  String dictionaryBaseFormHint(String lemma) {
    return 'Đang hiển thị kết quả cho dạng gốc “$lemma”';
  }

  @override
  String get download => 'Tải xuống';

  @override
  String get retry => 'Thử lại';

  @override
  String get guideNext => 'Tiếp';

  @override
  String get guideDone => 'Xong';

  @override
  String get guideLibraryCreateCollectionDescription =>
      'Chạm vào đây để tạo bộ sưu tập mới.';

  @override
  String get guideCollectionAudioMenuDescription =>
      'Chạm vào đây để quản lý phụ đề của audio này, bộ sưu tập chứa nó, thẻ và nhiều mục khác.';

  @override
  String get guideCollectionUploadDescription =>
      'Nhấn vào đây để tải lên âm thanh của riêng bạn.';

  @override
  String get guidePlanAddSubtitleTitle => 'Thêm phụ đề';

  @override
  String get guidePlanAddSubtitleDescription =>
      'Tạo phụ đề bằng AI chỉ với một chạm, hoặc tải lên tệp phụ đề có sẵn. Sau đó bạn có thể bắt đầu luyện tập âm thanh này ngay.';

  @override
  String get guidePlanFreePlayTitle => 'Nghe theo cách của bạn';

  @override
  String get guidePlanFreePlayDescription =>
      'Trình phát âm thanh linh hoạt, đa năng để bạn nghe theo cách và nhịp độ riêng.';

  @override
  String get guidePlanStartLearningTitle => 'Theo kế hoạch luyện tập mặc định';

  @override
  String get guidePlanStartLearningDescription =>
      'Nhấn vào đây để luyện tập từng bước theo kế hoạch mặc định. Study Loop sẽ hướng dẫn và nhắc bạn ôn tập đúng lúc.';

  @override
  String get guidePlanPauseLearningTitle => 'Tạm dừng';

  @override
  String get guidePlanPauseLearningDescription =>
      'Nếu không muốn luyện tập âm thanh này nữa, hãy nhấn vào đây để tạm dừng bất cứ lúc nào. Nhắc nhở ôn tập sẽ dừng, và bạn có thể tiếp tục chỉ với một chạm.';

  @override
  String get guideRetellSkipTitle => 'Bỏ qua phần kể lại lần này';

  @override
  String get guideRetellSkipDescription =>
      'Kể lại giúp cải thiện nói tiếng Anh nhanh chóng. Nếu bây giờ bạn muốn tập trung vào nghe, hãy nhấn vào đây để bỏ qua bước này.';

  @override
  String get learningProgressLoadFailed =>
      'Không tải được tiến độ học. Vui lòng thử lại sau.';

  @override
  String get guideStudyStatsHeaderTitle => 'Hôm nay trong nháy mắt';

  @override
  String get guideStudyStatsHeaderDescription =>
      'Thời gian nghe, thời gian luyện nói và từ vựng mới của bạn hôm nay đều được tổng hợp tại đây. Nhấn vào thẻ hoặc thanh để xem chi tiết hơn.';

  @override
  String get guideStudyStreakDescription =>
      'Nhấn vào đây để xem lịch học của bạn.';

  @override
  String get guideFavoritesSentencesListDescription =>
      'Các câu bạn đã lưu, nhóm theo nguồn.';

  @override
  String get guideFavoritesVocabularyListDescription =>
      'Các từ, cụm từ và cụm nghĩa bạn đã lưu.';

  @override
  String get guideSentenceTileBodyDescription => 'Nhấn vào câu để phát từ đây.';

  @override
  String get guideSentenceTileExplanationDescription =>
      'Nhấn vào biểu tượng giải thích bên trái để xem giải thích của câu này.';

  @override
  String get viewSentenceExplanation => 'Xem giải thích câu';

  @override
  String get guideSubtitleEditorBoundaryHandleDescription =>
      'Kéo các nút điều khiển màu đỏ hoặc xanh lá trên dạng sóng để chỉnh thời điểm bắt đầu và kết thúc của câu hiện tại.';

  @override
  String get guideSubtitleEditorSentencePlayDescription =>
      'Nhấn nút phát bên trái để phát câu này.';

  @override
  String get guideSubtitleEditorSentenceMenuDescription =>
      'Nhấn menu bên phải để gộp hoặc xóa câu này.';

  @override
  String get guideSentenceAnnotationSentenceDescription =>
      'Nhấn hoặc nhấn giữ để chọn văn bản và tra từ.';

  @override
  String get guideSentenceAnnotationSenseGroupDescription =>
      'Chia câu thành các cụm nghĩa để dễ theo dõi những câu dài, phức tạp.';

  @override
  String get guideSentenceAnnotationAnalysisDescription =>
      'Xem ngữ pháp, cụm từ chính và mẹo nghe của câu này.';

  @override
  String get resetNewUserGuide => 'Đặt lại hướng dẫn người dùng mới';

  @override
  String get resetNewUserGuideSubtitle =>
      'Xóa mọi trạng thái đã xem hướng dẫn để kiểm thử';

  @override
  String get resetNewUserGuideDone => 'Đã đặt lại hướng dẫn người dùng mới';

  @override
  String get newUserGuideToggle => 'Hướng dẫn người dùng mới';

  @override
  String get newUserGuideSubtitle =>
      'Hiện mẹo từng bước khi dùng mỗi trang lần đầu';

  @override
  String get newUserGuideResetAction => 'Đặt lại';

  @override
  String get resetOnboarding => 'Đặt lại khảo sát làm quen';

  @override
  String get resetOnboardingDone =>
      'Đã đặt lại khảo sát; hãy khởi động lại ứng dụng để làm lại';

  @override
  String get discoverCommunityCollections => 'Khám phá tài nguyên';

  @override
  String get discoverEmpty => 'Chưa có bộ sưu tập tuyển chọn';

  @override
  String get discoverLoadFailed => 'Tải thất bại, nhấn để thử lại';

  @override
  String get discoverRetry => 'Thử lại';

  @override
  String get discoverPodcastEntryTitle => 'Apple Podcasts';

  @override
  String discoverPodcastEntrySubtitle(int count) {
    return '$count podcast. Đăng ký để giữ các tập mới trong thư viện của bạn.';
  }

  @override
  String get discoverPodcastTitle => 'Podcast tuyển chọn';

  @override
  String get discoverPodcastEmpty => 'Chưa có podcast tuyển chọn';

  @override
  String get podcastSignInRequiredMessage =>
      'Đăng nhập để thêm podcast tuyển chọn vào Bộ sưu tập của tôi và tiếp tục học các tập sắp tới.';

  @override
  String get podcastPreviewSubscribeFailed =>
      'Thêm thất bại. Một số nguồn RSS hoặc Apple Podcasts có thể không truy cập được trên mạng hiện tại. Hãy thử lại sau hoặc đổi mạng.';

  @override
  String get podcastEnrollNeededTitle => 'Hãy thêm podcast trước';

  @override
  String get podcastEnrollNeededMessage =>
      'Thêm podcast này vào Bộ sưu tập của tôi, sau đó bạn có thể tải xuống và học tập này.';

  @override
  String get podcastPreviewNetworkFailed =>
      'Không lấy được nội dung podcast. Apple Podcasts hoặc một số nguồn RSS có thể không truy cập được trên mạng hiện tại. Hãy thử lại sau hoặc đổi mạng.';

  @override
  String get podcastPreviewAppleFailed =>
      'Không nhận dạng được liên kết Apple Podcast. Mạng hiện tại có thể không truy cập được dịch vụ tra cứu podcast của Apple. Hãy thử lại sau hoặc đổi mạng.';

  @override
  String get podcastPreviewParseFailed =>
      'Định dạng nguồn podcast này không được hỗ trợ nên không đọc được danh sách tập.';

  @override
  String get podcastFeedBlocked =>
      'Nguồn podcast này đang chặn truy cập tự động trên mạng hiện tại. Hãy thử lại sau hoặc đổi sang mạng khác.';

  @override
  String get podcastPreviewEmpty => 'Chưa tìm thấy tập nào.';

  @override
  String get localCollectionBadge => 'Cục bộ';

  @override
  String get communityBadge => 'Chia sẻ';

  @override
  String get communityDeprecatedBadge => 'Đã gỡ';

  @override
  String get podcastCollectionBadge => 'Podcast';

  @override
  String get addToMyCollections => 'Thêm vào Bộ sưu tập của tôi';

  @override
  String get communityCollectionSignInRequiredTitle =>
      'Đăng nhập để thêm bộ sưu tập';

  @override
  String get communityCollectionSignInRequiredMessage =>
      'Đăng nhập để thêm bộ sưu tập được chia sẻ vào Bộ sưu tập của tôi và đồng bộ các tệp mới.';

  @override
  String get goLearn => 'Bắt đầu luyện tập';

  @override
  String get communityCollectionAdded => 'Đã thêm';

  @override
  String get removeFromMyCollections => 'Xóa khỏi Bộ sưu tập của tôi';

  @override
  String get enrollNeededTitle => 'Hãy thêm bộ sưu tập trước';

  @override
  String get enrollNeededMessage =>
      'Thêm bộ sưu tập này vào Bộ sưu tập của tôi, sau đó bạn có thể bắt đầu luyện tập.';

  @override
  String get enrollSucceeded => 'Đã thêm vào Bộ sưu tập của tôi';

  @override
  String get enrollFailed => 'Thêm thất bại, vui lòng kiểm tra mạng và thử lại';

  @override
  String removeCommunityConfirmTitle(String name) {
    return 'Xóa \"$name\"?';
  }

  @override
  String get removeCommunityConfirmMessage =>
      'Tất cả tệp phương tiện, phụ đề và dữ liệu học trong bộ sưu tập này sẽ bị xóa. Không thể hoàn tác.';

  @override
  String get removeCommunityConfirmConfirm => 'Xóa';

  @override
  String get communityCollectionDeprecated =>
      'Bộ sưu tập này đã bị gỡ. Bạn vẫn có thể dùng bản cục bộ.';

  @override
  String get communityCollectionRefreshFailed =>
      'Đồng bộ thất bại. Kéo xuống để thử lại.';

  @override
  String get communityFileUnavailable =>
      'Tệp này đã bị gỡ khỏi bộ sưu tập được chia sẻ';

  @override
  String communityFilesRemoved(int count) {
    return '$count tệp đã bị gỡ khỏi các bộ sưu tập được chia sẻ';
  }

  @override
  String get downloadCancel => 'Hủy tải xuống';

  @override
  String get downloadLater => 'Để sau';

  @override
  String downloadCompleted(String name) {
    return 'Đã tải xong $name';
  }

  @override
  String downloadFailed(String name) {
    return 'Tải $name thất bại, vui lòng thử lại';
  }

  @override
  String get updateCommunitySubtitle => 'Cập nhật phụ đề';

  @override
  String get updateCommunitySubtitleConfirm => 'Cập nhật phụ đề?';

  @override
  String get updateCommunitySubtitleWarning =>
      'Cập nhật phụ đề sẽ thay thế phụ đề cục bộ và xóa mọi câu đã lưu cùng tiến độ học của phương tiện này.';

  @override
  String get communitySubtitleUpdated => 'Đã cập nhật phụ đề';

  @override
  String get communitySubtitleUpdateFailed =>
      'Cập nhật phụ đề thất bại, vui lòng thử lại';

  @override
  String downloadInProgressSnackbar(String name) {
    return 'Đang tải $name, vui lòng đợi';
  }

  @override
  String get downloadLoading => 'Đang tải';

  @override
  String get backgroundDownloadRunningTitle => 'Đang tải xuống';

  @override
  String get backgroundDownloadCompleteTitle => 'Tải xuống hoàn tất';

  @override
  String get backgroundDownloadFailedTitle => 'Tải xuống thất bại';

  @override
  String get audioListColumnName => 'Tên';

  @override
  String get audioListColumnDuration => 'Thời lượng';

  @override
  String get onboardingTitle => 'Trò chuyện nhanh';

  @override
  String get onboardingSubtitle =>
      '10 giây để điều chỉnh việc luyện tập cho bạn';

  @override
  String get onboardingBack => 'Quay lại';

  @override
  String get onboardingContinue => 'Tiếp tục';

  @override
  String get onboardingExamPrompt => 'Hiện bạn đang ôn thi gì?';

  @override
  String get onboardingExamGaokao => 'Gaokao';

  @override
  String get onboardingExamCet => 'CET-4 / CET-6';

  @override
  String get onboardingExamTem => 'TEM-4 / TEM-8';

  @override
  String get onboardingExamIelts => 'IELTS';

  @override
  String get onboardingExamToefl => 'TOEFL';

  @override
  String get onboardingExamOther => 'Khác';

  @override
  String onboardingProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get onboardingNext => 'Tiếp';

  @override
  String get onboardingDone => 'Xong';

  @override
  String get onboardingFinishedTitle => 'Đã sẵn sàng';

  @override
  String get onboardingFinishedHint =>
      'Chúng tôi sẽ điều chỉnh việc luyện tập theo mục tiêu và nhịp độ của bạn.';

  @override
  String get onboardingSummaryEyebrow => 'Bạn có biết?';

  @override
  String get onboardingSummaryHeadline =>
      'Cải thiện nghe và nói\nkhông phải là luyện với nhiều tài liệu hơn,\nmà là luyện kỹ hơn.';

  @override
  String get onboardingSummaryPoint1 =>
      'Luyện với âm thanh phù hợp trình độ của bạn';

  @override
  String get onboardingSummaryPoint2 =>
      'Hiểu những gì nghe được theo từng cụm và nắm vững từ vựng trong ngữ cảnh.';

  @override
  String get onboardingSummaryPoint3 =>
      'Hình thành cảm giác tự nhiên với tiếng Anh qua việc nghe kỹ và lặp lại nhiều.';

  @override
  String get onboardingSummaryPoint4 =>
      'Luyện nói qua việc kể lại, biến những gì nghe được thành những gì bạn nói được.';

  @override
  String get onboardingStart => 'Bắt đầu luyện tập';

  @override
  String get onboardingQ1Prompt =>
      'Mục tiêu chính của bạn khi cải thiện nghe và nói tiếng Anh là gì?';

  @override
  String get onboardingQ1OptionExam => 'Để thi cử';

  @override
  String get onboardingQ1OptionDaily => 'Giao tiếp hằng ngày';

  @override
  String get onboardingQ1OptionWork => 'Công việc';

  @override
  String get onboardingQ1OptionTravel => 'Du lịch nước ngoài';

  @override
  String get onboardingQ1OptionContent => 'Hiểu video và podcast';

  @override
  String get onboardingQ1OptionOther => 'Khác';

  @override
  String get onboardingQ2Prompt => 'Bạn dự định luyện tập bao lâu mỗi ngày?';

  @override
  String get onboardingQ2Option5 => 'Khoảng 5 phút';

  @override
  String get onboardingQ2Option10 => 'Khoảng 10 phút';

  @override
  String get onboardingQ2Option20 => 'Khoảng 20 phút';

  @override
  String get onboardingQ2Option30 => '30 phút trở lên';

  @override
  String get onboardingQ2OptionFlexible => 'Tùy ngày';

  @override
  String get onboardingQ3Prompt => 'Bạn biết đến chúng tôi qua đâu?';

  @override
  String get onboardingQ3OptionAppStore => 'App Store';

  @override
  String get onboardingQ3OptionGooglePlay => 'Google Play';

  @override
  String get onboardingQ3OptionYoutube => 'YouTube';

  @override
  String get onboardingQ3OptionReddit => 'Reddit';

  @override
  String get onboardingQ3OptionXTwitter => 'X / Twitter';

  @override
  String get onboardingQ3OptionTiktok => 'TikTok';

  @override
  String get onboardingQ3OptionInstagram => 'Instagram';

  @override
  String get onboardingQ3OptionXiaohongshu => 'Xiaohongshu';

  @override
  String get onboardingQ3OptionWechat => 'WeChat';

  @override
  String get onboardingQ3OptionDouyin => 'Douyin';

  @override
  String get onboardingQ3OptionKuaishou => 'Kuaishou';

  @override
  String get onboardingQ3OptionBilibili => 'Bilibili';

  @override
  String get onboardingQ3OptionBaiduSearch => 'Tìm kiếm Baidu';

  @override
  String get onboardingQ3OptionGoogleSearch => 'Tìm kiếm Google';

  @override
  String get onboardingQ3OptionGithub => 'GitHub';

  @override
  String get onboardingQ3OptionFriend => 'Truyền miệng';

  @override
  String get onboardingQ3OptionOther => 'Khác';

  @override
  String get onboardingPermissionsHint =>
      'Để có trải nghiệm tốt nhất, chúng tôi sẽ yêu cầu các quyền sau';

  @override
  String get onboardingPermissionsNotification => 'Thông báo';

  @override
  String get onboardingPermissionsMicrophone => 'Micro';

  @override
  String get onboardingPermissionsSpeech => 'Nhận dạng giọng nói';

  @override
  String get playbackSection => 'Phát lại';

  @override
  String get learningSection => 'Học tập';

  @override
  String get learningSettings => 'Cài đặt học tập';

  @override
  String get speakingPracticeSection => 'Luyện nói';

  @override
  String get autoSkipRetellToggle => 'Tự động bỏ qua luyện kể lại';

  @override
  String get autoSkipRetellSubtitle =>
      'Tự động bỏ qua các nhiệm vụ kể lại trong kế hoạch học';

  @override
  String get autoExpandCachedAnnotationToggle => 'Tự động mở phân tích câu';

  @override
  String get autoExpandCachedAnnotationSubtitle =>
      'Tự động hiện bản dịch, phân tích và cụm nghĩa đã lưu đệm';

  @override
  String get autoShowAiExplanationToggle => 'Tự động hiện giải thích AI';

  @override
  String get autoShowAiExplanationSubtitle =>
      'Tự động hiện phần trợ giúp AI đã chọn khi bạn vào giải thích câu';

  @override
  String get autoShowAiAnalysisToggle => 'Phân tích AI';

  @override
  String get autoShowAiTranslationToggle => 'Dịch AI';

  @override
  String get autoShowAiSenseGroupsToggle => 'Cụm nghĩa AI';

  @override
  String get autoPlayRetellRecordingToggle => 'Tự động phát bản ghi âm kể lại';

  @override
  String get autoPlayRetellRecordingSubtitle =>
      'Sau mỗi lần kể lại, tự động phát bản ghi âm của bạn để xem lại phát âm';

  @override
  String get listenAndRepeatRatingToggle =>
      'Hiện đánh giá sau mỗi lần nhắc lại';

  @override
  String get listenAndRepeatRatingSubtitle =>
      'Khi tắt, bản ghi âm vẫn được giữ nhưng bỏ qua nhận dạng và chấm điểm';

  @override
  String get retellRatingToggle => 'Hiện đánh giá sau mỗi lần kể lại';

  @override
  String get retellRatingSubtitle =>
      'Khi tắt, bạn vẫn nghe lại được bản ghi âm nhưng không hiện điểm';

  @override
  String get retellSkip => 'Bỏ qua';

  @override
  String get retellSkippedSuffix => 'Đã bỏ qua';

  @override
  String get skipSilenceTitle => 'Tự động bỏ qua khoảng lặng';

  @override
  String get skipSilenceDescription =>
      'Bỏ qua các khoảng lặng dài giữa các câu';

  @override
  String get wordHighlightTitle => 'Đánh dấu từ khi phát';

  @override
  String get wordHighlightDescription =>
      'Đánh dấu từng từ khi được đọc trong âm thanh gốc';

  @override
  String get silenceThreshold => 'Ngưỡng khoảng lặng';

  @override
  String silenceThresholdValue(int seconds) {
    return '${seconds}s';
  }

  @override
  String silenceSkipped(int seconds) {
    return 'Đã bỏ qua ${seconds}s khoảng lặng';
  }

  @override
  String get speechPermDialogTitleRequest => 'Cần cấp quyền';

  @override
  String get speechPermDialogTitleDenied => 'Quyền bị từ chối';

  @override
  String get speechPermDialogTitleRestricted => 'Thiết bị bị hạn chế';

  @override
  String get speechPermItemMic => 'Micro';

  @override
  String get speechPermItemMicDesc =>
      'Ghi âm giọng nói của bạn để đánh giá phát âm';

  @override
  String get speechPermItemSpeech => 'Nhận dạng giọng nói';

  @override
  String get speechPermItemSpeechDesc => 'Phát hiện các từ phát âm sai';

  @override
  String get speechPermStatusPending => 'Chưa cấp';

  @override
  String get speechPermStatusDenied => 'Đã từ chối';

  @override
  String get speechPermDeniedHint =>
      'Bạn đã từng từ chối quyền này. Vui lòng bật lại trong Cài đặt hệ thống.';

  @override
  String get speechPermRestrictedHint =>
      'Việc ghi âm bị hạn chế trên thiết bị này bởi kiểm soát của phụ huynh hoặc MDM.';

  @override
  String get speechPermActionGrant => 'Cấp quyền';

  @override
  String get speechPermActionOpenSettings => 'Mở Cài đặt';

  @override
  String get speechPermUnsupportedToast => 'Nền tảng này không hỗ trợ ghi âm';

  @override
  String get authSignInTitle => 'Đăng nhập vào Study Loop';

  @override
  String get authChooseMethod => 'Chọn cách bạn muốn tiếp tục.';

  @override
  String get authContinueWithEmail => 'Tiếp tục bằng mã qua email';

  @override
  String get authContinueWithApple => 'Tiếp tục với Apple';

  @override
  String get authContinueWithGoogle => 'Tiếp tục với Google';

  @override
  String get authProviderComingSoon => 'Sắp ra mắt';

  @override
  String get authGoogleUnavailable =>
      'Đăng nhập Google không khả dụng trên thiết bị này. Hãy dùng mã qua email.';

  @override
  String get authGoogleServicesOutdated =>
      'Dịch vụ Google đã cũ. Vui lòng cập nhật và thử lại.';

  @override
  String get authPasswordlessHint =>
      'Không cần mật khẩu. Chúng tôi sẽ gửi mã dùng một lần qua email cho bạn.';

  @override
  String get authEmailTitle => 'Đăng nhập bằng email';

  @override
  String get authEmailOtpTitle => 'Tiếp tục bằng email';

  @override
  String get authEmailOtpDescription =>
      'Nhập email của bạn và chúng tôi sẽ gửi mã dùng một lần.';

  @override
  String get authEmailOtpAutoCreateHint =>
      'Lần đầu sử dụng sẽ tự động tạo tài khoản cho bạn.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authOtpLabel => 'Mã 6 chữ số';

  @override
  String get authOtpRequired => 'Nhập mã 6 chữ số';

  @override
  String get authOtpInvalid => 'Nhập mã 6 chữ số hợp lệ';

  @override
  String get authOtpIncorrectOrExpired =>
      'Mã xác minh không đúng hoặc đã hết hạn.';

  @override
  String get authEnterOtpTitle => 'Nhập mã';

  @override
  String get authOtpHelpText =>
      'Hãy kiểm tra thư rác nếu bạn không thấy email.';

  @override
  String get authSendOtpButton => 'Gửi mã';

  @override
  String get authSendingOtp => 'Đang gửi mã';

  @override
  String get authVerifyOtpButton => 'Tiếp tục';

  @override
  String get authVerifyingOtp => 'Đang xác minh';

  @override
  String get authResendOtpButton => 'Gửi lại mã';

  @override
  String authResendOtpCountdown(int seconds) {
    return '${seconds}s nữa để gửi lại';
  }

  @override
  String get authOtpResent => 'Đã gửi mã mới.';

  @override
  String get authPasswordLabel => 'Mật khẩu';

  @override
  String get authConfirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get authSignInButton => 'Đăng nhập';

  @override
  String get authSigningIn => 'Đang đăng nhập';

  @override
  String get authCreateAccount => 'Tạo tài khoản';

  @override
  String get authCreateAccountTitle => 'Tạo tài khoản của bạn';

  @override
  String get authCreatingAccount => 'Đang tạo tài khoản';

  @override
  String get authAlreadyHaveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get authForgotPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String get authForgotPasswordDescription =>
      'Nhập email của bạn và chúng tôi sẽ gửi liên kết đặt lại mật khẩu.';

  @override
  String get authResetPasswordTitle => 'Đặt mật khẩu mới';

  @override
  String get authResetPasswordDescription =>
      'Nhập mật khẩu mới để hoàn tất khôi phục mật khẩu.';

  @override
  String get authNewPasswordLabel => 'Mật khẩu mới';

  @override
  String get authConfirmNewPasswordLabel => 'Xác nhận mật khẩu mới';

  @override
  String get authUpdatePasswordButton => 'Cập nhật mật khẩu';

  @override
  String get authUpdatingPassword => 'Đang cập nhật mật khẩu';

  @override
  String get authSendResetLink => 'Gửi liên kết đặt lại';

  @override
  String get authSendingResetLink => 'Đang gửi liên kết';

  @override
  String get authBackToSignIn => 'Quay lại đăng nhập';

  @override
  String get authCheckEmailTitle => 'Kiểm tra email của bạn';

  @override
  String authCheckEmailMessage(String email) {
    return 'Chúng tôi đã gửi mã 6 chữ số đến $email.';
  }

  @override
  String get authResetEmailSent =>
      'Nếu tài khoản tồn tại, liên kết đặt lại đã được gửi.';

  @override
  String get authEmailRequired => 'Nhập email của bạn';

  @override
  String get authEmailInvalid => 'Nhập email hợp lệ';

  @override
  String get authPasswordRequired => 'Nhập mật khẩu của bạn';

  @override
  String get authPasswordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get authConfirmPasswordRequired => 'Xác nhận mật khẩu của bạn';

  @override
  String get authConfirmPasswordMismatch => 'Mật khẩu không khớp';

  @override
  String get authShowPassword => 'Hiện mật khẩu';

  @override
  String get authHidePassword => 'Ẩn mật khẩu';

  @override
  String get authUnavailable => 'Xác thực chưa được cấu hình.';

  @override
  String get authUnknownError => 'Đã xảy ra lỗi. Hãy thử lại.';

  @override
  String get authAgreeRequired =>
      'Vui lòng đồng ý với điều khoản và chính sách quyền riêng tư trước.';

  @override
  String get authTermsAgreementPrefix => 'Tôi đã đọc và đồng ý với';

  @override
  String get authTermsContinuationPrefix => 'Khi tiếp tục, bạn đồng ý với';

  @override
  String get authTermsJoiner => ' và ';

  @override
  String get authTermsOfService => 'Điều khoản dịch vụ';

  @override
  String get authPrivacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get authSignedInStatus => 'Đã đăng nhập';

  @override
  String get authSignedOutStatus => 'Đã đăng xuất';

  @override
  String get authSignedInWithApple => 'Đã đăng nhập bằng Apple';

  @override
  String get authSignedInWithGoogle => 'Đã đăng nhập bằng Google';

  @override
  String get authAppleAccount => 'Tài khoản Apple';

  @override
  String get authEmailUnavailable => 'Không có email';

  @override
  String get authGoogleAccount => 'Tài khoản Google';

  @override
  String get authSignOut => 'Đăng xuất';

  @override
  String get editSubtitles => 'Sửa phụ đề';

  @override
  String get mergeWithNextSentence => 'Gộp với câu sau';

  @override
  String get deleteSentence => 'Xóa câu';

  @override
  String get sentenceDeleted => 'Đã xóa câu';

  @override
  String get playSentence => 'Phát câu';

  @override
  String get stopPlayback => 'Dừng phát';

  @override
  String get editWord => 'Sửa từ';

  @override
  String get splitSentenceHere => 'Tách câu tại đây';

  @override
  String get wordEditAction => 'Sửa';

  @override
  String get wordSplitBeforeAction => 'Tách';

  @override
  String get saveSubtitleEdits => 'Lưu thay đổi phụ đề';

  @override
  String get subtitleStructureChangedWarning =>
      'Thao tác này sẽ xóa tiến độ học và các câu đã lưu của âm thanh này.';

  @override
  String get subtitleEditsSaved => 'Đã lưu thay đổi phụ đề.';

  @override
  String get discardSubtitleEditsTitle => 'Bỏ thay đổi?';

  @override
  String get discardSubtitleEditsMessage =>
      'Các thay đổi phụ đề của bạn chưa được lưu.';

  @override
  String get discard => 'Bỏ';

  @override
  String get importAudio => 'Nhập âm thanh';

  @override
  String get importAudioFromFile => 'Nhập từ tệp';

  @override
  String get importAudioFromFileDescription =>
      'Chọn tệp media từ điện thoại hoặc ổ đám mây';

  @override
  String get importAudioFromUrl => 'Nhập từ liên kết';

  @override
  String get importAudioFromUrlDescription =>
      'Dán liên kết âm thanh trực tiếp và tải về';

  @override
  String get dialogueTtsSourceTitle => 'Hội thoại → giọng nói';

  @override
  String get dialogueTtsSourceDescription =>
      'Dán hội thoại, AI đọc thành bài nghe';

  @override
  String get dialogueTtsTitle => 'Tạo từ hội thoại';

  @override
  String get dialogueTtsNameLabel => 'Tên bài học';

  @override
  String get dialogueTtsNameHint => 'Ví dụ: Đi khám bác sĩ';

  @override
  String get dialogueTtsDialogueLabel => 'Hội thoại';

  @override
  String get dialogueTtsDialogueHint =>
      'Mark: Hi Anna, come in.\nAnna: Hi, Doctor.\n…\nMỗi dòng: Tên: câu nói';

  @override
  String get dialogueTtsPaste => 'Dán';

  @override
  String get dialogueTtsEmptyHint => 'Cần ít nhất 1 câu dạng “Tên: câu nói”.';

  @override
  String get dialogueTtsVoices => 'Giọng đọc';

  @override
  String get dialogueTtsQuality => 'Chất lượng';

  @override
  String get dialogueTtsQualityNatural => 'Tự nhiên';

  @override
  String get dialogueTtsQualityStandard => 'Tiêu chuẩn';

  @override
  String get dialogueTtsQualityHigh => 'Cao';

  @override
  String get dialogueTtsCreate => 'Tạo bài học';

  @override
  String get dialogueTtsMerging => 'Đang ghép audio và thêm phụ đề…';

  @override
  String get dialogueTtsErrorAuth =>
      'OpenAI từ chối API key. Kiểm tra lại key trong Cài đặt AI.';

  @override
  String get dialogueTtsErrorRateLimit =>
      'Hết hạn mức hoặc gọi quá nhanh. Thử lại sau.';

  @override
  String get dialogueTtsErrorNetwork => 'Mất kết nối mạng.';

  @override
  String get dialogueTtsErrorEncode => 'Ghép audio thất bại.';

  @override
  String get dialogueTtsErrorDuplicate => 'Bài học có nội dung này đã tồn tại.';

  @override
  String get dialogueTtsRetry => 'Thử lại';

  @override
  String dialogueTtsStats(int lines, int speakers, int chars) {
    return '$lines câu · $speakers người nói · $chars ký tự';
  }

  @override
  String dialogueTtsEstimate(String cost, int minutes) {
    return 'Ước tính ≈ $cost · ~$minutes phút audio · dùng OpenAI key của bạn';
  }

  @override
  String dialogueTtsProgress(int done, int total) {
    return 'Đang tạo giọng $done/$total…';
  }

  @override
  String dialogueTtsLineTooLong(int index) {
    return 'Câu $index quá dài (tối đa 4.000 ký tự).';
  }

  @override
  String dialogueTtsErrorGeneric(String message) {
    return 'Tạo bài học thất bại: $message';
  }

  @override
  String get importAudioFromCloudDrive => 'Nhập từ lưu trữ đám mây';

  @override
  String get importAudioFromBaiduNetdisk => 'Nhập từ Baidu Netdisk';

  @override
  String get cloudDriveSourceShort => 'Lưu trữ đám mây';

  @override
  String get baiduNetdisk => 'Baidu Netdisk';

  @override
  String get baiduNetdiskAllFiles => 'Tất cả tệp';

  @override
  String get baiduNetdiskWaitingAuthorization => 'Đang chờ xác thực Baidu...';

  @override
  String get baiduNetdiskLoadingFiles => 'Đang tải tệp Baidu Netdisk...';

  @override
  String get baiduNetdiskImportFailed => 'Nhập từ Baidu Netdisk thất bại.';

  @override
  String get baiduNetdiskConnectTitle => 'Kết nối Baidu Netdisk';

  @override
  String get baiduNetdiskConnectDescription =>
      'Cho phép Study Loop duyệt Baidu Netdisk của bạn và nhập các tệp media đã chọn.';

  @override
  String get baiduNetdiskConnectAction => 'Kết nối Baidu Netdisk';

  @override
  String get baiduNetdiskLogoutTooltip => 'Đăng xuất khỏi Baidu Netdisk';

  @override
  String get baiduNetdiskSelectAllAction => 'Chọn';

  @override
  String get baiduNetdiskClearSelectionAction => 'Bỏ chọn';

  @override
  String get baiduNetdiskLogoutTitle => 'Đăng xuất khỏi Baidu Netdisk?';

  @override
  String get baiduNetdiskLogoutMessage =>
      'Study Loop sẽ xóa quyền truy cập Baidu Netdisk đã lưu trên thiết bị này.';

  @override
  String get baiduNetdiskLogoutConfirm => 'Đăng xuất';

  @override
  String get baiduNetdiskAccountTooltip => 'Tài khoản Baidu Netdisk';

  @override
  String get baiduNetdiskAccountTitle => 'Tài khoản Baidu Netdisk';

  @override
  String get baiduNetdiskUsername => 'Tên người dùng Baidu';

  @override
  String get baiduNetdiskNetdiskName => 'Biệt danh Netdisk';

  @override
  String get baiduNetdiskMembership => 'Gói thành viên';

  @override
  String get baiduNetdiskUserId => 'ID người dùng';

  @override
  String get baiduNetdiskUnavailable => 'Không có';

  @override
  String get baiduNetdiskDisconnect => 'Ngắt kết nối Baidu Netdisk';

  @override
  String get baiduNetdiskNoSupportedAudio =>
      'Không tìm thấy tệp media được hỗ trợ trong thư mục này.';

  @override
  String get importAudioShort => 'Nhập';

  @override
  String get cancelImport => 'Hủy nhập';

  @override
  String get cancelingImport => 'Đang hủy nhập…';

  @override
  String importAudioSelectedCount(int count) {
    return 'Nhập $count';
  }

  @override
  String importAudioAndSubtitleCount(int audioCount, int subtitleCount) {
    String _temp0 = intl.Intl.pluralLogic(
      audioCount,
      locale: localeName,
      other: '$audioCount mục',
      one: '1 mục',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      subtitleCount,
      locale: localeName,
      other: ', $subtitleCount phụ đề',
      one: ', 1 phụ đề',
      zero: '',
    );
    return 'Nhập ($_temp0$_temp1)';
  }

  @override
  String get baiduNetdiskImporting => 'Đang nhập...';

  @override
  String baiduNetdiskImportingFile(String name) {
    return 'Đang nhập $name...';
  }

  @override
  String baiduNetdiskImportedCount(int count) {
    return 'Đã nhập $count từ Baidu Netdisk';
  }

  @override
  String baiduNetdiskSkippedSummary(int duplicates, int failures) {
    return 'Bỏ qua trùng lặp: $duplicates · Thất bại: $failures';
  }

  @override
  String get audioUrlLabel => 'Liên kết âm thanh';

  @override
  String get audioUrlHint => 'https://example.com/audio.mp3';

  @override
  String get pasteAudioLink => 'Dán liên kết';

  @override
  String get audioClipboardNoValidLink => 'Bộ nhớ tạm không có liên kết hợp lệ';

  @override
  String get downloadAndImportAudio => 'Tải và nhập';

  @override
  String get audioUrlInvalid => 'Nhập liên kết âm thanh hợp lệ';

  @override
  String get audioUrlUnsupported =>
      'Liên kết này không phải định dạng âm thanh được hỗ trợ';

  @override
  String get audioUrlNotDirectAudio =>
      'Liên kết này không phải tệp âm thanh trực tiếp';

  @override
  String get audioUrlDuplicate => 'Đã có tệp âm thanh cùng tên';

  @override
  String get audioDownloadFailed => 'Tải âm thanh thất bại';

  @override
  String get audioDownloadInProgress => 'Đang tải';

  @override
  String get audioImportComplete => 'Nhập xong';

  @override
  String get audioImportCanceled => 'Đã hủy nhập âm thanh';

  @override
  String get cancelDownload => 'Hủy tải';

  @override
  String get subscribePodcast => 'Đăng ký podcast';

  @override
  String get subscribePodcastOptionDescription =>
      'Thêm bằng Apple Podcasts hoặc RSS';

  @override
  String get podcastUrlLabel => 'URL Apple Podcasts hoặc RSS';

  @override
  String get podcastUrlHint =>
      'https://podcasts.apple.com/... hoặc https://…/feed.xml';

  @override
  String get podcastSearchHint => 'Tìm podcast hoặc dán liên kết';

  @override
  String get podcastSearchEmpty => 'Không tìm thấy podcast';

  @override
  String get podcastSearchFailed => 'Tìm kiếm thất bại, vui lòng thử lại';

  @override
  String get podcastSubscribeThisLink => 'Đăng ký liên kết này';

  @override
  String get podcastSubscribing => 'Đang lấy nguồn podcast…';

  @override
  String podcastSubscribeFailed(String error) {
    return 'Đăng ký thất bại: $error';
  }

  @override
  String podcastRefreshFailed(String error) {
    return 'Làm mới thất bại: $error';
  }

  @override
  String podcastAlreadySubscribed(String name) {
    return 'Đã đăng ký — xem Bộ sưu tập \"$name\"';
  }

  @override
  String get podcastRefreshFeed => 'Làm mới nguồn';

  @override
  String get podcastUnsubscribe => 'Hủy đăng ký';

  @override
  String podcastUnsubscribeConfirmTitle(String name) {
    return 'Hủy đăng ký $name?';
  }

  @override
  String get podcastUnsubscribeConfirmMessage =>
      'Tất cả các tập và tệp âm thanh đã tải trong bộ sưu tập này sẽ bị xóa.';

  @override
  String get podcastFeedInfo => 'Thông tin nguồn';

  @override
  String get podcastDetails => 'Chi tiết';

  @override
  String get podcastEpisodeMeta => 'Thông tin tập';

  @override
  String get podcastShowMore => 'Thêm';

  @override
  String get podcastShowLess => 'Thu gọn';

  @override
  String get podcastTitle => 'Tiêu đề';

  @override
  String get podcastAuthor => 'Tác giả';

  @override
  String get podcastDescription => 'Mô tả';

  @override
  String get podcastFeedUrl => 'URL RSS';

  @override
  String get podcastAppleLink => 'Apple Podcasts';

  @override
  String get podcastOriginalLink => 'Liên kết';

  @override
  String get podcastAudioType => 'Loại âm thanh';

  @override
  String get podcastOpenLinkFailed => 'Không thể mở liên kết';

  @override
  String podcastLastRefreshed(String time) {
    return 'Làm mới lần cuối: $time';
  }

  @override
  String get podcastEpisodeGuid => 'GUID';

  @override
  String get podcastEnclosureUrl => 'URL âm thanh';

  @override
  String get ttsSettings => 'Chuyển văn bản thành giọng nói';

  @override
  String get ttsSettingsDescription =>
      'Chọn công cụ giọng nói và giọng đọc dùng khi đọc to từ và câu ví dụ.';

  @override
  String get ttsEngine => 'Công cụ giọng nói';

  @override
  String get ttsEnginePlatform => 'Giọng nói hệ thống';

  @override
  String get ttsEnginePlatformApple => 'Apple AI';

  @override
  String get ttsEnginePlatformDescription =>
      'Có sẵn trên thiết bị. Nhanh, không cần tải, chất lượng trung bình.';

  @override
  String get ttsEngineEchoLoop => 'Study Loop AI (Nâng cao)';

  @override
  String get ttsEngineComingSoon => 'Sắp ra mắt';

  @override
  String get ttsEngineEchoLoopDescription =>
      'Chất lượng âm thanh tốt nhất. Cần tải mô hình; khuyên dùng cho thiết bị cấu hình cao.';

  @override
  String get ttsEnginePiper => 'Study Loop AI (Cân bằng)';

  @override
  String get ttsEnginePiperDescription =>
      'Âm thanh tự nhiên, mượt mà. Cần tải mô hình; khuyên dùng cho thiết bị tầm trung.';

  @override
  String get ttsModel => 'Mô hình';

  @override
  String get ttsModelHighQuality => 'Chất lượng cao';

  @override
  String get ttsModelHighQualityDescription =>
      'Âm thanh tốt nhất với tốc độ chấp nhận được. Khoảng 300 MB.';

  @override
  String get ttsModelLite => 'Nhẹ';

  @override
  String get ttsModelLiteDescription =>
      'Nhỏ gọn, tiết kiệm bộ nhớ cho máy cấu hình thấp, nhưng chậm hơn. Khoảng 100 MB.';

  @override
  String get ttsModelRecommended => 'Khuyên dùng';

  @override
  String get ttsModelNotDownloaded => 'Chưa tải';

  @override
  String get ttsModelDownloadRequiredTitle => 'Cần mô hình tổng hợp giọng nói';

  @override
  String get ttsModelDownloadIntro => 'Giọng này cần tải mô hình một lần.';

  @override
  String ttsModelDownloadEstimate(Object size) {
    return 'Dung lượng tải ước tính: ~$size';
  }

  @override
  String get ttsModelDownloadSettingsHint =>
      'Bạn cũng có thể chọn mô hình giọng nói khác trong Cài đặt.';

  @override
  String get ttsModelDownloadingTitle => 'Đang tải mô hình tổng hợp giọng nói';

  @override
  String ttsModelDownloadingMessage(Object size) {
    return 'Dung lượng tải ước tính: ~$size';
  }

  @override
  String ttsModelDownloadProgress(Object progress) {
    return 'Hoàn thành $progress';
  }

  @override
  String get ttsModelDownloadFailedTitle =>
      'Tải mô hình tổng hợp giọng nói thất bại';

  @override
  String ttsModelDownloadFailedMessage(Object size) {
    return 'Quá trình tải chưa hoàn tất. Dung lượng tải ước tính: ~$size';
  }

  @override
  String get ttsDownloadModel => 'Tải mô hình';

  @override
  String get ttsAccent => 'Giọng vùng miền';

  @override
  String get ttsAccentUs => 'Anh-Mỹ';

  @override
  String get ttsAccentUk => 'Anh-Anh';

  @override
  String get ttsAccentHint =>
      '(Một số thiết bị không phân biệt giọng Mỹ và Anh)';

  @override
  String get ttsVoice => 'Giọng đọc';

  @override
  String get ttsVoiceFemale => 'Nữ';

  @override
  String get ttsVoiceMale => 'Nam';

  @override
  String get ttsDeleteModel => 'Xóa mô hình';

  @override
  String get ttsDeleteModelConfirm =>
      'Xóa mô hình giọng nói Study Loop? Bạn có thể tải lại bất cứ lúc nào.';

  @override
  String get ttsCancelDownload => 'Hủy';

  @override
  String get ttsDownloadedModelsTitle => 'Mô hình Study Loop đã tải';

  @override
  String ttsDownloadedModelsDesc(String size) {
    return 'Không dùng · $size';
  }

  @override
  String get asrDeleteAllModelsConfirm =>
      'Xóa tất cả mô hình nhận dạng giọng nói Study Loop đã tải? Bạn có thể tải lại bất cứ lúc nào.';

  @override
  String get asrDownloadedModelsTitle => 'Mô hình nhận dạng giọng nói đã tải';

  @override
  String asrDownloadedModelsDesc(String size) {
    return 'Không dùng · $size';
  }

  @override
  String get dictionarySettings => 'Cài đặt từ điển';

  @override
  String get dictionaryDefault => 'Từ điển mặc định';

  @override
  String get dictionaryDefaultDescription =>
      'Từ điển hiển thị mặc định khi tra từ';

  @override
  String get dictionarySources => 'Nguồn từ điển';

  @override
  String get dictionarySourcesDescription =>
      'Từ điển bị tắt sẽ không xuất hiện trong bộ chuyển tra cứu';

  @override
  String get dictionaryAutoSpeakOnLookup => 'Tự phát âm';

  @override
  String get dictionaryAdFilterTitle => 'Chặn quảng cáo trong từ điển web';

  @override
  String get dictSourceLocal => 'Từ điển cục bộ';

  @override
  String get dictSourceAi => 'Từ điển AI';

  @override
  String get dictSourceCambridge => 'Cambridge';

  @override
  String get dictSourceAlwaysOn => 'Luôn bật';

  @override
  String dictSourceCannotDisable(String name) {
    return '$name là nguồn cơ bản và không thể tắt';
  }

  @override
  String get dictDefaultBadge => 'Mặc định';

  @override
  String dictSwitcherSemantics(String name) {
    return 'Chuyển từ điển, hiện là $name';
  }

  @override
  String get cambridgeNotFound => 'Không tìm thấy trong Cambridge';

  @override
  String get dictTryOtherSource => 'Thử từ điển khác';

  @override
  String get dictCambridgeOpenInBrowser => 'Mở trong trình duyệt';

  @override
  String get aiNoAnalysis => 'Chưa có phân tích AI';

  @override
  String get aiSignInRequired => 'Đăng nhập để dùng từ điển AI';

  @override
  String get dictPhraseTooLong => 'Cụm từ quá dài. Chọn tối đa 8 từ.';

  @override
  String get ttsPlayUk => 'Phát âm giọng Anh';

  @override
  String get ttsPlayUs => 'Phát âm giọng Mỹ';

  @override
  String get dictAiSynonyms => 'Từ đồng nghĩa';

  @override
  String get dictAiAntonyms => 'Từ trái nghĩa';

  @override
  String get dictAiExpressions => 'Cụm kết hợp';

  @override
  String get dictAiWordFamily => 'Họ từ';

  @override
  String get dictAiForms => 'Dạng từ';

  @override
  String get dictAiEtymology => 'Nguồn gốc từ';

  @override
  String get dictAiTips => 'Mẹo học';

  @override
  String get dictAiMultiKeyPoints => 'Ghi chú học tập';

  @override
  String get dictAiMultiMeanings => 'Nghĩa & ví dụ';

  @override
  String get dictAiMultiNaturalness => 'Chỉnh sửa';

  @override
  String get dictAiMultiPronunciationTips => 'Phát âm';

  @override
  String get dictAiMultiSimilarExpressions => 'Cách diễn đạt tương tự';

  @override
  String get dictAiMultiBackground => 'Kiến thức nền';

  @override
  String get chatOpenTooltip => 'Hỏi AI';

  @override
  String get chatSentenceTitle => 'Gia sư AI';

  @override
  String get chatInputPlaceholder => 'Hỏi bất cứ điều gì…';

  @override
  String get chatSend => 'Gửi';

  @override
  String get chatStop => 'Dừng';

  @override
  String get chatClear => 'Xóa cuộc trò chuyện';

  @override
  String get chatNewChat => 'Cuộc trò chuyện mới';

  @override
  String get chatRegenerate => 'Tạo lại';

  @override
  String get chatEdit => 'Sửa';

  @override
  String get chatEditTitle => 'Sửa tin nhắn';

  @override
  String get chatCopy => 'Sao chép';

  @override
  String get chatCopied => 'Đã sao chép';

  @override
  String chatContextLabel(String summary) {
    return 'Đang thảo luận: $summary';
  }

  @override
  String get chatEmptyGreeting => 'Hỏi mình bất cứ điều gì về câu này.';

  @override
  String get chatErrorNetwork => 'Không có mạng. Chạm để thử lại.';

  @override
  String get chatErrorGenerate => 'Tạo thất bại. Chạm để thử lại.';

  @override
  String get chatUpgrade => 'Nâng cấp';

  @override
  String get chatSignInTitle => 'Cần đăng nhập';

  @override
  String get chatSignInMessage => 'Đăng nhập để dùng Trợ lý AI.';

  @override
  String get chatScrollToBottom => 'Cuộn xuống cuối';

  @override
  String get chatThinking => 'Đang suy nghĩ…';

  @override
  String get chatFollowUp => 'Hỏi AI';

  @override
  String get chatFollowUpExplain => 'Giải thích';

  @override
  String get chatFollowUpTranslate => 'Dịch';

  @override
  String get chatFollowUpExample => 'Ví dụ';

  @override
  String get chatFollowUpInstruction =>
      'Chỉ trả lời câu hỏi dựa trên đoạn văn được trích dẫn bên dưới.';

  @override
  String get chatQuoteRemove => 'Xóa trích dẫn';

  @override
  String get retellAiReviewTooltip => 'Đánh giá AI';

  @override
  String get retellAiReviewTitle => 'Đánh giá Kể lại bằng AI';

  @override
  String get retellAiReviewKeyPoints => 'Mức độ bao quát ý chính';

  @override
  String get retellAiReviewLabelOriginal => 'Bản gốc';

  @override
  String get retellAiReviewLabelYouSaid => 'Bạn đã nói';

  @override
  String get retellAiReviewLabelTip => 'Mẹo';

  @override
  String get retellAiReviewSuggestion => 'Gợi ý';

  @override
  String get retellAiReviewStatusCovered => 'Đủ ý';

  @override
  String get retellAiReviewStatusPartial => 'Một phần';

  @override
  String get retellAiReviewStatusMissed => 'Bỏ sót';

  @override
  String get retellAiReviewStatusDistorted => 'Sai lệch';

  @override
  String get retellAiReviewStatusAdded => 'Thêm vào';

  @override
  String get retellAiReviewCorrections => 'Chỉnh sửa cách diễn đạt';

  @override
  String get retellAiReviewCorrectionTypeGrammar => 'Ngữ pháp';

  @override
  String get retellAiReviewCorrectionTypeWordChoice => 'Chọn từ';

  @override
  String get retellAiReviewCorrectionTypeRedundancy => 'Dài dòng';

  @override
  String get retellAiReviewCorrectionTypePhrasing => 'Cách diễn đạt';

  @override
  String get retellAiReviewCorrectionTypeCohesion => 'Liên kết ý';

  @override
  String get retellAiReviewEvaluating => 'Đang đánh giá…';

  @override
  String get retellAiReviewGenerating => 'Đang tạo…';

  @override
  String get retellAiReviewRetry => 'Thử lại';

  @override
  String get retellAiReviewError =>
      'Không thể hoàn tất đánh giá AI. Vui lòng thử lại.';

  @override
  String get retellAiReviewAudioPreparationError =>
      'Không thể chuẩn bị bản ghi âm cho đánh giá AI.';

  @override
  String get retellAiReviewAudioTooLarge =>
      'Bản ghi âm đã chuẩn bị vượt quá giới hạn 2 MB.';

  @override
  String get retellAiReviewSignInRequiredTitle =>
      'Đăng nhập để dùng đánh giá Kể lại bằng AI';

  @override
  String get retellAiReviewSignInRequiredMessage =>
      'Đánh giá Kể lại bằng AI dùng dịch vụ AI đám mây. Đăng nhập để nhận nhận xét về phần kể lại của bạn.';

  @override
  String get retellAiReviewPlayRecording => 'Phát bản ghi âm';

  @override
  String get retellAiReviewStopRecording => 'Dừng bản ghi âm';

  @override
  String get videoHideTrack => 'Ẩn video';

  @override
  String get mediaShowVisualTrack => 'Hiện video';

  @override
  String get mediaEnterFullscreen => 'Toàn màn hình';

  @override
  String get mediaExitFullscreen => 'Thoát toàn màn hình';

  @override
  String get mediaHideVideoSubtitles => 'Ẩn phụ đề video';

  @override
  String get mediaShowVideoSubtitles => 'Hiện phụ đề video';

  @override
  String get videoLoopWhole => 'Lặp lại tất cả';

  @override
  String get videoLoopSentence => 'Lặp lại câu';

  @override
  String get videoLoading => 'Đang tải video…';

  @override
  String get videoLoadFailed => 'Tải video thất bại';

  @override
  String get videoNoTranscript => 'Không có bản ghi';

  @override
  String get videoRetry => 'Thử lại';

  @override
  String get pronunciationPlay => 'Phát âm';

  @override
  String get pronunciationStandard => 'Phát âm';

  @override
  String get pronunciationAdjective => 'Tính từ';

  @override
  String get pronunciationNoun => 'Danh từ';

  @override
  String get pronunciationNounAdjective => 'Danh từ / tính từ';

  @override
  String get pronunciationVerb => 'Động từ';

  @override
  String get pronunciationPastTense => 'Quá khứ';

  @override
  String get pronunciationPresentTense => 'Hiện tại';

  @override
  String get pronunciationInterjection => 'Thán từ';

  @override
  String get pronunciationLibrary => 'Phát âm từ ngoại tuyến';

  @override
  String get pronunciationLibraryDescription =>
      'Âm thanh từ đã ghi sẵn cho tra cứu từ điển';

  @override
  String get redownload => 'Tải lại';

  @override
  String get collapseSidebar => 'Thu gọn thanh bên';

  @override
  String get expandSidebar => 'Mở rộng thanh bên';

  @override
  String get aiSettingsTitle => 'Cài đặt AI';

  @override
  String get aiSettingsNotConfigured => 'Chưa cấu hình';

  @override
  String get aiSettingsIntro =>
      'Study Loop gọi trực tiếp nhà cung cấp AI của bạn bằng API key riêng. Khóa chỉ được lưu trên thiết bị này, trong bộ nhớ bảo mật của hệ thống, và không bao giờ được gửi đi nơi khác.';

  @override
  String get aiSettingsApiKeyLabel => 'API Key';

  @override
  String aiSettingsApiKeySavedHint(String masked) {
    return 'Đã lưu: $masked — nhập để thay thế';
  }

  @override
  String get aiSettingsShowKey => 'Hiện khóa';

  @override
  String get aiSettingsHideKey => 'Ẩn khóa';

  @override
  String get aiSettingsBaseUrlLabel => 'Base URL';

  @override
  String get aiSettingsBaseUrlHelper =>
      'Endpoint tương thích OpenAI (OpenAI, OpenRouter, máy chủ cục bộ…)';

  @override
  String get aiSettingsBaseUrlInvalid =>
      'Nhập URL hợp lệ, ví dụ https://api.openai.com/v1';

  @override
  String get aiSettingsBaseUrlInsecure =>
      'Dùng https (http chỉ được phép với localhost / mạng LAN)';

  @override
  String get aiSettingsModelLabel => 'Mô hình';

  @override
  String get aiSettingsTestConnection => 'Kiểm tra kết nối';

  @override
  String get aiSettingsSave => 'Lưu';

  @override
  String get aiSettingsSaved => 'Đã lưu cài đặt AI';

  @override
  String get aiSettingsSaveFailed => 'Không thể lưu cài đặt AI';

  @override
  String get aiSettingsLoadFailed =>
      'Không thể đọc cài đặt AI đã lưu. Bạn có thể nhập lại.';

  @override
  String get aiSettingsKeyRequired => 'Hãy nhập API key trước';

  @override
  String aiSettingsTestOk(int count) {
    return 'Đã kết nối — có $count mô hình';
  }

  @override
  String get aiSettingsTestOkUnknown => 'Đã kết nối';

  @override
  String aiSettingsTestUnauthorized(int status) {
    return 'API key không hợp lệ ($status)';
  }

  @override
  String aiSettingsTestHttpError(int status) {
    return 'Lỗi máy chủ ($status)';
  }

  @override
  String aiSettingsTestNetworkError(String message) {
    return 'Không thể kết nối máy chủ: $message';
  }

  @override
  String get aiSettingsRemoveKey => 'Xóa API key';

  @override
  String get aiSettingsRemoveKeyConfirm =>
      'Xóa API key đã lưu khỏi thiết bị này? Các tính năng AI sẽ ngừng hoạt động cho đến khi bạn thêm khóa lại.';

  @override
  String get aiSettingsRemoveKeyDone => 'Đã xóa API key';

  @override
  String get dictionaryOfflineUnavailable =>
      'Chưa có từ điển offline cho ngôn ngữ mẹ đẻ của bạn. Hãy dùng từ điển AI hoặc từ điển web.';

  @override
  String get aiKeyRequiredTitle => 'Chưa cấu hình AI';

  @override
  String get aiKeyRequiredMessage =>
      'Thêm API key OpenAI (hoặc dịch vụ tương thích) của bạn trong Cài đặt AI để dùng các tính năng AI.';

  @override
  String get aiOpenSettings => 'Mở Cài đặt AI';

  @override
  String get podcastSearchToStart =>
      'Tìm theo tên podcast, hoặc dán link podcast / RSS để đăng ký.';

  @override
  String get reviewReminderSavedBody1 => 'Đến giờ ôn lại câu và từ đã lưu rồi';

  @override
  String get reviewReminderSavedBody2 =>
      'Nghe lại các câu đã lưu một lượt để nhớ lâu hơn';

  @override
  String get reviewReminderSavedBody3 =>
      'Tranh thủ nghe vài câu lúc rảnh, tích tiểu thành đại';

  @override
  String get reviewReminderSavedBody4 =>
      'Các câu đã lưu đang chờ bạn — vào ôn nhé';

  @override
  String get reviewReminderSavedBody5 =>
      'Nghe đi nghe lại mới nhớ được — cùng ôn nào';

  @override
  String reviewReminderPerAudioBody(String audioName, int round) {
    return '$audioName · Đến giờ ôn tập vòng $round';
  }

  @override
  String get recordingSettings => 'Ghi âm';

  @override
  String get recordingSettingsTitle => 'Cài đặt ghi âm';

  @override
  String get recordingVolume => 'Âm lượng ghi âm';

  @override
  String get recordingGainLow => 'Nhỏ';

  @override
  String get recordingGainLowDesc => '×1.5 · nói gần mic hoặc nơi ồn';

  @override
  String get recordingGainStandard => 'Chuẩn';

  @override
  String get recordingGainStandardDesc => '×2.2 · mặc định';

  @override
  String get recordingGainLoud => 'To';

  @override
  String get recordingGainLoudDesc => '×3.5';

  @override
  String get recordingGainExtraLoud => 'Rất to';

  @override
  String get recordingGainExtraLoudDesc => '×5';

  @override
  String get recordingVolumeHint =>
      'Mức to được giới hạn mềm để tiếng không bị rè.';

  @override
  String get recordingQuality => 'Chất lượng ghi âm';

  @override
  String get recordingQualityStandard => 'Tiêu chuẩn';

  @override
  String get recordingQualityStandardDesc => '16 kHz · file nhỏ nhất';

  @override
  String get recordingQualityGood => 'Tốt';

  @override
  String get recordingQualityGoodDesc =>
      '24 kHz · âm gió rõ hơn, file khoảng 1.5 lần';

  @override
  String get recordingQualityHigh => 'Cao';

  @override
  String get recordingQualityHighDesc => '44.1 kHz · file khoảng 2.8 lần';

  @override
  String get recordingTrialButton => 'Ghi thử 5 giây';

  @override
  String recordingTrialRecording(int seconds) {
    return 'Đang ghi… ${seconds}s';
  }

  @override
  String get recordingTrialPlaying => 'Đang phát lại…';

  @override
  String get recordingTrialNoPermission =>
      'Chưa cấp quyền micro. Hãy bật trong cài đặt hệ thống.';

  @override
  String get recordingTrialFailed => 'Không ghi âm được. Hãy thử lại.';

  @override
  String get recordingSettingsFootnote =>
      'Áp dụng cho lần ghi âm tiếp theo. Bản ghi cũ không thay đổi.';

  @override
  String get devVersionOverride => 'Ghi đè phiên bản';

  @override
  String get devVersionOverrideSubtitle =>
      'Giả lập phiên bản cũ để thử hộp thoại cập nhật, tự đặt lại khi khởi động lại';

  @override
  String get devRealVersion => 'Phiên bản thật';

  @override
  String devRealVersionLabel(String version) {
    return 'Phiên bản thật: $version';
  }

  @override
  String get devSimulatedVersion => 'Phiên bản giả lập';

  @override
  String get devVersionHint => 'vd 1.0.0';

  @override
  String get devVersionOverrideHelp =>
      'Thấp hơn minimumVersion trên server sẽ bắt buộc cập nhật; thấp hơn latestVersion sẽ gợi ý cập nhật.';

  @override
  String get devClearOverride => 'Xoá ghi đè';

  @override
  String devVersionOverrideCleared(String version) {
    return 'Đã xoá ghi đè, trở về phiên bản thật $version';
  }

  @override
  String devVersionOverrideSet(String version) {
    return 'Đã ghi đè phiên bản thành $version, bấm \"Kiểm tra cập nhật\" để thử';
  }

  @override
  String get devAsrTest => 'Thử engine ASR';

  @override
  String get devLogs => 'Nhật ký';

  @override
  String get devSubscriptionDebug => 'Gỡ lỗi gói đăng ký';

  @override
  String get devSubscriptionDebugSubtitle =>
      'Chẩn đoán quyền lợi, xoá cache & làm mới, ghi đè Pro/Free';

  @override
  String devAnalyticsChannel(String channel) {
    return 'Kênh hiện tại: $channel';
  }

  @override
  String get devSubtitleAutoAlign => 'Tự căn chỉnh phụ đề';

  @override
  String get devSubtitleAutoAlignSubtitle =>
      'Sau khi AI chép lời, tinh chỉnh ranh giới câu theo khoảng lặng của audio';

  @override
  String get devDictionaryLookup => 'Tra từ điển';

  @override
  String get devEnterWord => 'Nhập từ...';

  @override
  String get devNotFound => 'Không có trong từ điển';

  @override
  String get devCollins => 'Collins';

  @override
  String get devPreferences => 'Tuỳ chọn (SharedPreferences)';

  @override
  String get devInternalStorage => 'Bộ nhớ trong';

  @override
  String get devClose => 'Đóng';

  @override
  String get devMicPermissionRequired => 'Cần quyền ghi âm';

  @override
  String get devEngineConfig => 'Cấu hình engine';

  @override
  String get devAsrMode => 'Chế độ ASR';

  @override
  String get devOffline => 'Offline trên máy';

  @override
  String get devModel => 'Model';

  @override
  String get devModelStatus => 'Trạng thái model';

  @override
  String get devNotDownloaded => 'Chưa tải';

  @override
  String get devDownloaded => 'Đã tải';

  @override
  String devDownloadFailed(String error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get devTranscribing => 'Đang chép lời...';

  @override
  String devRecording(String duration) {
    return 'Đang ghi âm... $duration';
  }

  @override
  String get devTapToRecord => 'Bấm để bắt đầu ghi âm';

  @override
  String get devDownloadModelFirst => 'Hãy tải model trước';

  @override
  String get devTranscriptionResult => 'Kết quả chép lời';

  @override
  String get devMetrics => 'Chỉ số hiệu năng';

  @override
  String get devRecordingDuration => 'Thời lượng ghi âm';

  @override
  String get devInferenceTime => 'Thời gian suy luận';

  @override
  String get devEngine => 'Engine';

  @override
  String get devEventLog => 'Nhật ký sự kiện';

  @override
  String devActionDone(String label) {
    return '$label xong';
  }

  @override
  String devActionFailed(String label, String error) {
    return '$label thất bại: $error';
  }

  @override
  String get devCurrentEntitlement =>
      'Quyền lợi hiện tại (nguồn chuẩn của app)';

  @override
  String get devIsStale => 'isStale (từ cache cũ)';

  @override
  String get devAnonymous => 'Ẩn danh';

  @override
  String get devNoExpiry => 'Vĩnh viễn / không có';

  @override
  String get devRcCustomerInfo => 'CustomerInfo gốc của RevenueCat';

  @override
  String devReadFailed(String error) {
    return 'Đọc thất bại: $error';
  }

  @override
  String get devNoRcData =>
      'Không có dữ liệu (chưa cấu hình RevenueCat hoặc đang dùng bản stub).';

  @override
  String get devRcHint =>
      'activeEntitlements rỗng nhưng có gói → sản phẩm chưa gắn vào entitlement;\nkey khác lookForEntitlementId → định danh entitlement không khớp;\nactiveSubscriptions vẫn có giá trị → có thể là giao dịch StoreKit Configuration cục bộ,\nxoá trong Xcode \"Debug ▸ StoreKit ▸ Manage Transactions\".';

  @override
  String get devActions => 'Thao tác';

  @override
  String get devClearCacheRefreshTitle =>
      'Xoá cache cục bộ + huỷ cache RC + làm mới';

  @override
  String get devClearCacheRefreshSubtitle =>
      'Sửa lỗi \"đã xoá trên dashboard nhưng vẫn hiện đã đăng ký\"';

  @override
  String get devClearCacheRefresh => 'Xoá cache & làm mới';

  @override
  String get devRestorePurchases => 'Khôi phục giao dịch';

  @override
  String get devSignOutTitle => 'Đăng xuất (xoá quyền lợi)';

  @override
  String get devSignedIn => 'Đang đăng nhập';

  @override
  String get devNotSignedIn => 'Chưa đăng nhập, không dùng được';

  @override
  String get devSignOut => 'Đăng xuất';

  @override
  String get devOverrideEntitlement => 'Ghi đè quyền lợi thủ công (chỉ Debug)';

  @override
  String get devOverrideEntitlementHelp =>
      'Thử UI hội viên / paywall mà không mua thật. Chọn \"Thật\" để bỏ ghi đè.';

  @override
  String get devReal => 'Thật';

  @override
  String get devForcePremium => 'Ép hội viên';

  @override
  String get devForceFree => 'Ép Free';

  @override
  String get devPrefsCopiedAll => 'Đã sao chép toàn bộ tuỳ chọn vào clipboard';

  @override
  String get devDeletePrefTitle => 'Xoá tuỳ chọn?';

  @override
  String devDeletePrefContent(String key) {
    return 'key: $key\nKhông thể hoàn tác, chỉ dùng để thử.';
  }

  @override
  String devDeleted(String key) {
    return 'Đã xoá $key';
  }

  @override
  String get devRefresh => 'Làm mới';

  @override
  String get devCopyAll => 'Sao chép tất cả';

  @override
  String get devSearchKeyValue => 'Tìm key hoặc value';

  @override
  String devPrefsCount(int count) {
    return '$count mục';
  }

  @override
  String devPrefsMatched(int count) {
    return ' · khớp $count';
  }

  @override
  String get devNoPrefs => 'Không có tuỳ chọn';

  @override
  String get devNoMatches => 'Không có kết quả khớp';

  @override
  String devCopied(String key) {
    return 'Đã sao chép $key';
  }

  @override
  String devShareLogFailed(String error) {
    return 'Chia sẻ nhật ký thất bại: $error';
  }

  @override
  String devLogsTitle(int count) {
    return 'Nhật ký ($count mục gần nhất)';
  }

  @override
  String get devShareLogs => 'Chia sẻ nhật ký';

  @override
  String get devNoLogs => 'Chưa có nhật ký';

  @override
  String get devLogsLimitHint =>
      'Chỉ hiện 500 mục gần nhất; chia sẻ nhật ký để xuất toàn bộ';

  @override
  String get devEmptyDir => '(thư mục trống)';

  @override
  String get audioTrimEntryTitle => 'Cắt đoạn audio';

  @override
  String audioTrimEntrySubtitle(String duration) {
    return 'Bỏ quảng cáo đầu/cuối trước khi tạo phụ đề · $duration';
  }

  @override
  String get audioTrimTitle => 'Cắt audio';

  @override
  String get audioTrimStart => 'Điểm đầu';

  @override
  String get audioTrimEnd => 'Điểm cuối';

  @override
  String get audioTrimSetHere => 'Đặt tại đây';

  @override
  String get audioTrimPlayFromStart => 'Nghe từ đây';

  @override
  String get audioTrimPlayToEnd => 'Nghe đến đây';

  @override
  String get audioTrimPlayResult => 'Nghe bản đã cắt';

  @override
  String audioTrimNewLength(String length) {
    return 'Độ dài mới: $length';
  }

  @override
  String audioTrimRemoved(String removed) {
    return '(bỏ $removed)';
  }

  @override
  String get audioTrimWaveformFailed => 'Không hiển thị được dạng sóng';

  @override
  String get audioTrimSaving => 'Đang cắt audio…';

  @override
  String get audioTrimFailed => 'Cắt audio thất bại, file gốc vẫn giữ nguyên';

  @override
  String audioTrimDone(String length) {
    return 'Đã cắt audio · độ dài mới $length';
  }

  @override
  String get audioTrimDeleteSubtitleTitle => 'Cắt audio sẽ xóa phụ đề';

  @override
  String get audioTrimDeleteSubtitleBody =>
      'Thời gian trong phụ đề sẽ bị lệch sau khi cắt. Phụ đề, câu yêu thích và tiến độ học của bài này sẽ bị xóa khi bấm Lưu. Bạn có thể tạo lại phụ đề sau khi cắt.';

  @override
  String get audioTrimContinue => 'Tiếp tục';

  @override
  String get audioTrimDiscardTitle => 'Bỏ thay đổi?';

  @override
  String get driveSync => 'Đồng bộ Google Drive';

  @override
  String get driveSyncNotSignedIn => 'Chưa đăng nhập';

  @override
  String get driveSyncIntro =>
      'Sao lưu cài đặt, tiến độ học, podcast, phụ đề và audio vào thư mục riêng của ứng dụng trên Google Drive của bạn.';

  @override
  String get driveSyncKeyNotice =>
      '🔒 OpenAI API key không bao giờ được sao lưu.';

  @override
  String get driveSyncSignIn => 'Đăng nhập bằng Google';

  @override
  String get driveSyncSignOut => 'Đăng xuất';

  @override
  String get driveSyncLastBackup => 'Lần sao lưu gần nhất';

  @override
  String get driveSyncNoBackup => 'Chưa có bản sao lưu trên Drive';

  @override
  String get driveSyncBackupNow => 'Sao lưu ngay';

  @override
  String get driveSyncRestore => 'Khôi phục từ Drive';

  @override
  String get driveSyncBackingUp => 'Đang sao lưu…';

  @override
  String get driveSyncRestoring => 'Đang khôi phục…';

  @override
  String get driveSyncStepPreparing => 'Đang chuẩn bị dữ liệu…';

  @override
  String get driveSyncStepHashing => 'Đang kiểm tra file audio…';

  @override
  String get driveSyncStepUploadingBackup => 'Đang tải bản sao lưu lên…';

  @override
  String get driveSyncStepDownloadingBackup => 'Đang tải bản sao lưu về…';

  @override
  String get driveSyncStepApplying => 'Đang áp dụng dữ liệu…';

  @override
  String get driveSyncRestoreTitle => 'Khôi phục dữ liệu?';

  @override
  String get driveSyncRestoreAction => 'Khôi phục';

  @override
  String get driveSyncBackupDone => 'Đã sao lưu lên Google Drive';

  @override
  String get driveSyncRestoreDone => 'Đã khôi phục từ Google Drive';

  @override
  String get driveSyncCancelConfirm => 'Huỷ thao tác đang chạy?';

  @override
  String get driveSyncDataUnchanged => 'Dữ liệu trên máy không bị thay đổi.';

  @override
  String get driveSyncSignInAgain => 'Đăng nhập lại';

  @override
  String get driveSyncErrorAuth => 'Phiên Google đã hết hạn';

  @override
  String get driveSyncErrorNetwork => 'Không có kết nối mạng';

  @override
  String get driveSyncErrorQuota => 'Google Drive đã hết dung lượng';

  @override
  String get driveSyncErrorVersion =>
      'Bản sao lưu được tạo từ phiên bản app mới hơn. Hãy cập nhật app trước.';

  @override
  String get driveSyncErrorMismatch =>
      'Bản sao lưu trên Drive chưa hoàn chỉnh. Hãy sao lưu lại.';

  @override
  String get driveSyncErrorNotConfigured =>
      'Bản build này chưa cấu hình đăng nhập Google (GOOGLE_WEB_CLIENT_ID).';

  @override
  String driveSyncBackupSummary(int count, String size) {
    return '$count file · $size audio';
  }

  @override
  String driveSyncStepUploadingMedia(String progress) {
    return 'Đang tải audio lên $progress…';
  }

  @override
  String driveSyncStepDownloadingMedia(String progress) {
    return 'Đang tải audio về $progress…';
  }

  @override
  String driveSyncRestoreConfirm(String date, int count) {
    return 'Dữ liệu học tập và cài đặt hiện tại sẽ được thay bằng bản sao lưu ngày $date ($count file). OpenAI key hiện tại được giữ nguyên.';
  }

  @override
  String driveSyncErrorGeneric(String error) {
    return 'Đồng bộ thất bại: $error';
  }
}
