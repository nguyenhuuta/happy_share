import '../session/session_state.dart';
import 'app_routes.dart';

/// Quy tắc điều hướng theo [SessionStatus] — hàm thuần để test được. Trả về đường dẫn cần
/// chuyển tới, hoặc `null` nếu giữ nguyên [location].
String? sessionRedirect(SessionStatus status, String location) {
  bool under(String base) => location == base || location.startsWith('$base/');

  switch (status) {
    case SessionStatus.initializing:
    case SessionStatus.failure:
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    case SessionStatus.unauthenticated:
      return under(AppRoutes.login) || under(AppRoutes.register)
          ? null
          : AppRoutes.login;
    case SessionStatus.consentIntro:
      return under(AppRoutes.consentIntro) ? null : AppRoutes.consentIntro;
    case SessionStatus.ready:
      // Đã vào được app: các màn trước-shell hết ý nghĩa, kể cả `/consent-intro`. Riêng luồng
      // tạo/tham gia nhóm (`/family-setup/*`) là tính năng dùng được bất cứ lúc nào (D03: có thể ở
      // nhiều nhóm) nên KHÔNG bị coi là lỗi thời. Nhờ vậy bấm
      // "Để sau" hoặc đồng ý xong (consent chuyển sang granted) là router tự đưa vào shell, màn
      // hình không cần tự điều hướng. Khi người dùng muốn bật chia sẻ từ Cài đặt (M3) thì dùng một
      // route riêng nằm trong shell (tái dùng cùng widget), không dùng `/consent-intro`.
      final stale =
          under(AppRoutes.splash) ||
          under(AppRoutes.login) ||
          under(AppRoutes.register) ||
          under(AppRoutes.consentIntro);
      return stale ? AppRoutes.family : null;
  }
}
