import 'package:injectable/injectable.dart';

import 'secure_token_store.dart';

/// Dọn dữ liệu cục bộ. Các milestone sau mở rộng bản cài đặt này
/// (M2/M3: hàng đợi SQLite, `device_id`, trạng thái consent cho native; M4: cache).
abstract class LocalDataCleaner {
  /// Đăng xuất / xóa tài khoản / hết phiên: xóa TẤT CẢ dữ liệu cục bộ của phiên (gồm token).
  Future<void> clearAll();

  /// Rời gia đình, bị xóa khỏi gia đình hoặc thu hồi chia sẻ: server đã `revoked` consent nên
  /// phải dừng thu thập và xóa hàng đợi vị trí chưa gửi (A3.2, B10). KHÔNG đụng tới token.
  Future<void> clearLocationData();
}

@LazySingleton(as: LocalDataCleaner)
class DefaultLocalDataCleaner implements LocalDataCleaner {
  DefaultLocalDataCleaner(this._tokens);

  final TokenStore _tokens;

  @override
  Future<void> clearAll() async {
    await clearLocationData();
    await _tokens.clear();
  }

  @override
  Future<void> clearLocationData() async {
    // M1: chưa có hàng đợi vị trí / native tracking. M2–M3 bổ sung tại đây.
  }
}
