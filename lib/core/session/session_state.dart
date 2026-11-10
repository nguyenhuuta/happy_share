import 'package:equatable/equatable.dart';

import '../../features/auth/data/model/me_data.dart';
import '../../features/family/data/model/family_with_member.dart';
import '../network/api_exception.dart';

/// Vị trí của người dùng trong luồng vào app (B5). Router điều hướng theo giá trị này.
enum SessionStatus {
  /// Đang đọc token / gọi `GET /me` lần đầu.
  initializing,

  /// Chưa đăng nhập hoặc phiên hết hiệu lực.
  unauthenticated,

  /// Chưa bật "Ghi lại hành trình của tôi" (hoặc đã tắt) → màn giới thiệu (có thể bỏ qua).
  /// Nhóm là tùy chọn (D15): có hay không có nhóm đều vào được app.
  consentIntro,

  /// Vào shell 5 tab.
  ready,

  /// Không tải được `/me` lần đầu (mạng/5xx) → màn chờ có nút thử lại.
  failure,
}

class SessionState extends Equatable {
  const SessionState({
    this.status = SessionStatus.initializing,
    this.me,
    this.error,
    this.consentIntroSkipped = false,
    this.activeFamilyId,
  });

  final SessionStatus status;

  /// Dữ liệu `/me` gần nhất. Giữ lại khi một lần làm mới thất bại vì mạng.
  final MeData? me;

  /// Lỗi của lần gọi `/me` gần nhất (nếu có) — UI hiện banner, không đá người dùng ra ngoài.
  final ApiErrorCode? error;

  /// Người dùng chọn "Để sau" ở màn giới thiệu (chỉ trong phiên chạy hiện tại).
  final bool consentIntroSkipped;

  /// Nhóm đang xem ở các tab (người dùng có thể ở nhiều nhóm, D03). null → nhóm đầu tiên.
  final String? activeFamilyId;

  /// Các nhóm đang tham gia (rỗng khi chưa có nhóm nào).
  List<FamilyWithMember> get families => me?.families ?? const [];

  /// Nhóm đang xem: nhóm được chọn nếu còn hiệu lực, không thì nhóm đầu tiên; null nếu chưa có nhóm.
  FamilyWithMember? get activeFamily {
    final list = families;
    if (list.isEmpty) return null;
    for (final f in list) {
      if (f.family.id == activeFamilyId) return f;
    }
    return list.first;
  }

  SessionState copyWith({
    SessionStatus? status,
    MeData? me,
    bool clearMe = false,
    ApiErrorCode? error,
    bool clearError = false,
    bool? consentIntroSkipped,
    String? activeFamilyId,
  }) => SessionState(
    status: status ?? this.status,
    me: clearMe ? null : (me ?? this.me),
    error: clearError ? null : (error ?? this.error),
    consentIntroSkipped: consentIntroSkipped ?? this.consentIntroSkipped,
    activeFamilyId: activeFamilyId ?? this.activeFamilyId,
  );

  @override
  List<Object?> get props => [
    status,
    me,
    error,
    consentIntroSkipped,
    activeFamilyId,
  ];
}
