import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/model/me_data.dart';
import '../constants/domain_enums.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/data/repository/me_repository.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../storage/local_data_cleaner.dart';
import '../storage/secure_token_store.dart';
import 'session_state.dart';

/// Nguồn sự thật về "đang ở bước nào của luồng vào app" (B5). Router đọc [SessionState.status].
///
/// Quy tắc xử lý lỗi `GET /me`:
/// - `UNAUTHENTICATED` (sau khi `AuthInterceptor` đã thử refresh): phiên hỏng → đăng xuất cục bộ.
/// - Hết phiên do refresh bị từ chối (`REFRESH_TOKEN_INVALID`) đến qua [ApiClient.sessionExpired].
/// - Lỗi mạng / 5xx / `TOKEN_EXPIRED` còn sót lại là TẠM THỜI: không đăng xuất. Đã có dữ liệu thì
///   giữ nguyên màn hình (chỉ gắn `error`); chưa có thì sang `failure` để người dùng thử lại.
@lazySingleton
class AppSessionCubit extends Cubit<SessionState> {
  AppSessionCubit(
    this._me,
    this._auth,
    this._tokens,
    this._cleaner,
    ApiClient api,
  ) : super(const SessionState()) {
    _expiredSub = api.sessionExpired.listen((_) => _handleSessionExpired());
  }

  final MeRepository _me;
  final AuthRepository _auth;
  final TokenStore _tokens;
  final LocalDataCleaner _cleaner;
  late final StreamSubscription<void> _expiredSub;

  /// Gọi một lần lúc mở app (không chặn UI: router hiện splash trong lúc chờ).
  Future<void> start() async {
    if (await _tokens.read() == null) {
      emit(const SessionState(status: SessionStatus.unauthenticated));
      return;
    }
    await refreshMe();
  }

  /// Tải lại `GET /me` rồi cập nhật trạng thái. Gọi sau đăng nhập/đăng ký, tạo/tham gia/rời nhóm,
  /// bật ghi nhận hành trình, hoặc khi bất kỳ API trả `NOT_FAMILY_MEMBER`.
  Future<void> refreshMe() async {
    try {
      final me = await _me.getMe();
      // Ghi nhận bị tắt từ nơi khác (máy khác): server từ chối dữ liệu mới → dọn hàng đợi cục bộ.
      // Mất/rời một nhóm KHÔNG đụng tới ghi nhận cá nhân (D15) nên không dọn gì.
      final was = state.me?.consent.status;
      if ((was == ConsentStatus.granted || was == ConsentStatus.paused) &&
          me.consent.status == ConsentStatus.revoked) {
        await _cleaner.clearLocationData();
      }
      emit(
        SessionState(
          status: _statusFor(me, state.consentIntroSkipped),
          me: me,
          consentIntroSkipped: state.consentIntroSkipped,
          activeFamilyId: state.activeFamilyId,
        ),
      );
    } on ApiException catch (e) {
      // Token đã bị xóa (refresh bị từ chối → `sessionExpired`) nghĩa là hết phiên, dù lỗi nhìn thấy
      // ở đây là `TOKEN_EXPIRED`. Không kiểm tra thì hai sự kiện chạy đua và có thể kẹt ở `failure`.
      if (e.code == ApiErrorCode.unauthenticated ||
          await _tokens.read() == null) {
        await _endSession();
      } else if (state.me == null) {
        emit(SessionState(status: SessionStatus.failure, error: e.code));
      } else {
        emit(state.copyWith(error: e.code));
      }
    }
  }

  /// Chọn nhóm đang xem. Bỏ qua nếu người dùng không thuộc nhóm đó.
  void selectFamily(String familyId) {
    if (state.families.any((f) => f.family.id == familyId) &&
        state.activeFamily?.family.id != familyId) {
      emit(state.copyWith(activeFamilyId: familyId));
    }
  }

  /// Người dùng bấm "Để sau" ở màn giới thiệu ghi nhận hành trình.
  void skipConsentIntro() {
    emit(
      state.copyWith(
        consentIntroSkipped: true,
        status: state.status == SessionStatus.consentIntro
            ? SessionStatus.ready
            : null,
      ),
    );
  }

  /// Đăng xuất chủ động: gọi API (best effort) rồi dọn dữ liệu cục bộ.
  Future<void> signOut() async {
    await _auth.logout();
    emit(const SessionState(status: SessionStatus.unauthenticated));
  }

  Future<void> _handleSessionExpired() async {
    if (state.status == SessionStatus.unauthenticated) return;
    await _endSession();
  }

  Future<void> _endSession() async {
    await _auth.clearLocalSession();
    emit(const SessionState(status: SessionStatus.unauthenticated));
  }

  static SessionStatus _statusFor(MeData me, bool introSkipped) {
    // Nhóm là tùy chọn (D15): chỉ ghi nhận hành trình quyết định có cần màn giới thiệu hay không.
    if (me.consent.hasAgreed) return SessionStatus.ready;
    // Chưa bật (status null) hoặc đã tắt → giới thiệu, trừ khi đã chọn "Để sau".
    return introSkipped ? SessionStatus.ready : SessionStatus.consentIntro;
  }

  @override
  Future<void> close() async {
    await _expiredSub.cancel();
    return super.close();
  }
}
