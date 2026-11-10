// Mirror các hằng số của CLAUDE.md phần A3.3 / A4 mà mobile cần.
// Hằng số chỉ server dùng (token TTL, ngưỡng visit…) KHÔNG đưa vào đây.

const String kDefaultTimezone = 'Asia/Ho_Chi_Minh';

/// Phiên bản nội dung "Ghi lại hành trình của tôi" (ghi nhận cá nhân, D15) — gửi kèm `POST /locations/consent`.
const String kCurrentConsentVersion = '2026-11-v2';

/// Phiên bản nội dung đồng ý chia sẻ khi tạo/tham gia nhóm (D16) — gửi kèm `POST /families` và `/families/join`.
const String kCurrentSharingConsentVersion = '2026-11-g1';

/// Mỗi người ở tối đa chừng này nhóm đang hoạt động (D03); server trả `GROUP_LIMIT` khi vượt.
const int kMaxGroupsPerUser = 5;

/// Lịch sử xem được của chính mình tối thiểu (ngày); gói nhóm rộng hơn thì dài hơn (A3.3).
const int kPersonalHistoryDays = 30;

/// Mã mời: 8 ký tự Crockford Base32, không có 0/O/1/I/L/U (A3.3, đã chuẩn hóa chữ hoa).
const int kInviteCodeLength = 8;
final RegExp kInviteCodePattern = RegExp(r'^[2-9A-HJKMNP-TV-Z]{8}$');

const int kBatchMaxEvents = 500;
const int kEventMaxAgeDays = 7;

// Giới hạn dữ liệu đầu vào (A4 — "Giới hạn dữ liệu đầu vào"). Validate trước khi gửi.
const int kIdentifierMaxLength = 254;
const int kPasswordMinLength = 8;
const int kPasswordMaxLength = 72;
const int kNameMaxLength =
    100; // display_name, nickname, tên nhóm, tên địa điểm
const int kPlaceRadiusMinM = 50;
const int kPlaceRadiusMaxM = 500;
const int kPlaceRadiusDefaultM = 150;

// Native (truyền xuống qua TrackingConfig ở M2).
const int kMoveStartDistanceM = 200;
const int kMovingSampleIntervalS = 60;
const int kDesiredAccuracyM = 100;

// Queue & sync.
const int kQueueMaxRows = 20000;
const int kSyncMaxAttempts = 20;
const Duration kSyncBackoffBase = Duration(seconds: 30);
const Duration kSyncBackoffMax = Duration(hours: 1);
