import '../constants/domain_constants.dart';

/// Chuẩn hóa mã mời người dùng nhập/dán: chữ hoa, bỏ khoảng trắng và dấu `-`
/// (giống cách server chuẩn hóa nên mã dán dạng `k7m2-q9xa` vẫn hợp lệ).
///
/// Trả `null` nếu sai độ dài hoặc có ký tự ngoài bảng chữ (A3.3). Chỉ để báo lỗi
/// sớm ở UI; quyết định mã đúng/đã dùng/hết hạn luôn là của server.
String? normalizeInviteCode(String raw) {
  final code = raw.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  return kInviteCodePattern.hasMatch(code) ? code : null;
}
