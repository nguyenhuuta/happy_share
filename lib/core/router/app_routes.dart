/// Đường dẫn của app. Năm tab khớp CLAUDE.md A1; các đường dẫn còn lại là luồng trước-shell.
abstract final class AppRoutes {
  // 5 tab
  static const family = '/family';
  static const journey = '/journey';
  static const places = '/places';
  static const members = '/members';
  static const settings = '/settings';

  // Trước khi vào shell
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const familySetup = '/family-setup';
  static const familyCreate = '/family-setup/create';
  static const familyJoin = '/family-setup/join';
  static const consentIntro = '/consent-intro';
}
