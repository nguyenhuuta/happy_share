// Enum dùng chung với server — giá trị chuỗi phải khớp CLAUDE.md phần A3.2.
// Thêm/đổi giá trị = sửa phần chung ở CẢ 2 CLAUDE.md + tăng SHARED_VERSION.
// Mọi enum có `unknown` làm giá trị dự phòng khi server gửi giá trị lạ.
import 'package:json_annotation/json_annotation.dart';

enum MemberRole {
  @JsonValue('owner')
  owner,
  @JsonValue('member')
  member,
  unknown,
}

enum MemberStatus {
  @JsonValue('active')
  active,
  @JsonValue('left')
  left,
  @JsonValue('removed')
  removed,
  unknown,
}

enum ConsentStatus {
  @JsonValue('granted')
  granted,
  @JsonValue('paused')
  paused,
  @JsonValue('revoked')
  revoked,
  unknown,
}

enum SharingState {
  @JsonValue('sharing')
  sharing,
  @JsonValue('limited')
  limited,
  @JsonValue('paused')
  paused,
  @JsonValue('not_shared')
  notShared,
  unknown,
}

/// Loại định danh đăng nhập — server tự nhận dạng (D13); mobile chỉ hiển thị.
enum IdentifierType {
  @JsonValue('email')
  email,
  @JsonValue('phone')
  phone,
  @JsonValue('username')
  username,
  unknown,
}

enum DevicePlatform {
  @JsonValue('ios')
  ios,
  @JsonValue('android')
  android,
  unknown,
}

enum OsPermission {
  @JsonValue('always')
  always,
  @JsonValue('while_in_use')
  whileInUse,
  @JsonValue('denied')
  denied,
  @JsonValue('restricted')
  restricted,
  @JsonValue('not_determined')
  notDetermined,
  unknown,
}

enum LocationSource {
  @JsonValue('gps')
  gps,
  @JsonValue('fused')
  fused,
  @JsonValue('network')
  network,
  @JsonValue('significant_change')
  significantChange,
  @JsonValue('visit_arrival')
  visitArrival,
  @JsonValue('visit_departure')
  visitDeparture,
  @JsonValue('geofence_enter')
  geofenceEnter,
  @JsonValue('geofence_exit')
  geofenceExit,
  unknown,
}

enum ActivityType {
  @JsonValue('still')
  still,
  @JsonValue('walking')
  walking,
  @JsonValue('running')
  running,
  @JsonValue('cycling')
  cycling,
  @JsonValue('in_vehicle')
  inVehicle,
  @JsonValue('unknown')
  unknown,
}

enum VisitStatus {
  @JsonValue('open')
  open,
  @JsonValue('closed')
  closed,
  unknown,
}

enum PlaceCategory {
  @JsonValue('home')
  home,
  @JsonValue('school')
  school,
  @JsonValue('work')
  work,
  @JsonValue('other')
  other,
  unknown,
}

enum Freshness {
  @JsonValue('fresh')
  fresh,
  @JsonValue('recent')
  recent,
  @JsonValue('stale')
  stale,
  @JsonValue('none')
  none,
  unknown,
}

enum TimelineItemType {
  @JsonValue('visit')
  visit,
  @JsonValue('travel')
  travel,
  @JsonValue('gap')
  gap,
  unknown,
}

enum GapReason {
  @JsonValue('no_data')
  noData,
  @JsonValue('sharing_paused')
  sharingPaused,
  unknown,
}

enum SubscriptionPlan {
  @JsonValue('free')
  free,
  @JsonValue('basic')
  basic,
  @JsonValue('premium')
  premium,
  @JsonValue('beta')
  beta,
  unknown,
}

enum SubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('expired')
  expired,
  @JsonValue('canceled')
  canceled,
  unknown,
}
