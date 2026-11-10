// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Happy Share';

  @override
  String get tabFamily => 'Nhóm';

  @override
  String get tabJourney => 'Hành trình';

  @override
  String get tabPlaces => 'Địa điểm';

  @override
  String get tabMembers => 'Thành viên';

  @override
  String get tabSettings => 'Cài đặt';

  @override
  String get emptyComingSoon => 'Sắp có';

  @override
  String get errorNetwork => 'Không có kết nối mạng. Vui lòng thử lại.';

  @override
  String get errorUnknown => 'Đã có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get errorUnauthenticated =>
      'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';

  @override
  String get errorSessionExpired =>
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get errorInvalidCredentials => 'Tài khoản hoặc mật khẩu không đúng.';

  @override
  String get errorForbidden => 'Bạn không có quyền thực hiện thao tác này.';

  @override
  String get errorNotFamilyMember => 'Bạn không thuộc nhóm này.';

  @override
  String get errorConsentRequired => 'Bạn cần bật ghi lại hành trình trước.';

  @override
  String get errorConsentRevoked => 'Bạn đã tắt ghi lại hành trình.';

  @override
  String get errorNotFound => 'Không tìm thấy dữ liệu.';

  @override
  String get errorIdentifierTaken => 'Tài khoản này đã được sử dụng.';

  @override
  String get errorAlreadyInFamily => 'Bạn đã ở trong nhóm này.';

  @override
  String get errorInviteInvalid => 'Mã mời không đúng hoặc đã được dùng.';

  @override
  String get errorInviteExpired => 'Mã mời đã hết hạn.';

  @override
  String get errorOwnerCannotLeave =>
      'Chủ nhóm không thể rời khi còn thành viên khác.';

  @override
  String get errorGroupLimit =>
      'Bạn đã ở đủ số nhóm tối đa. Hãy rời một nhóm trước khi tham gia nhóm khác.';

  @override
  String get errorPlanLimitMembers =>
      'Nhóm đã đạt số thành viên tối đa của gói.';

  @override
  String get errorPlanLimitPlaces => 'Nhóm đã đạt số địa điểm tối đa của gói.';

  @override
  String get errorHistoryOutOfPlan =>
      'Ngày này nằm ngoài lịch sử của gói hiện tại.';

  @override
  String get errorRateLimited =>
      'Bạn thao tác quá nhanh. Vui lòng thử lại sau.';

  @override
  String get errorValidation => 'Dữ liệu chưa hợp lệ. Vui lòng kiểm tra lại.';

  @override
  String get pageLogin => 'Đăng nhập';

  @override
  String get pageRegister => 'Tạo tài khoản';

  @override
  String get pageFamilySetup => 'Bắt đầu cùng nhóm';

  @override
  String get pageCreateFamily => 'Tạo nhóm';

  @override
  String get pageJoinFamily => 'Tham gia nhóm';

  @override
  String get pageConsentIntro => 'Ghi lại hành trình';

  @override
  String get sharingStateSharing => 'Đang chia sẻ';

  @override
  String get sharingStateLimited => 'Chia sẻ hạn chế';

  @override
  String get sharingStatePaused => 'Đã tạm dừng';

  @override
  String get sharingStateNotShared => 'Chưa chia sẻ';

  @override
  String get freshnessStale => 'Dữ liệu cũ';

  @override
  String get freshnessNone => 'Chưa có dữ liệu';
}
