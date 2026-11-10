import '../../../core/constants/domain_constants.dart';

/// Kiểm tra đầu vào trước khi gọi API (A4 "Giới hạn dữ liệu đầu vào"), để người dùng thấy lỗi
/// ngay. Kết quả có cùng dạng với `ApiException.fieldErrors`: `{trường: [quy tắc]}` — quy tắc là
/// khóa ổn định (`required`, `minLength`, `maxLength`), UI map sang chuỗi l10n.
///
/// KHÔNG kiểm tra định dạng identifier (email/SĐT/tên tài khoản): server nhận dạng và chuẩn hóa
/// (D13); sai định dạng sẽ trả `VALIDATION_ERROR` kèm `fields.identifier`.
Map<String, List<String>> validateLogin({
  required String identifier,
  required String password,
}) {
  final errors = <String, List<String>>{};
  _identifier(identifier, errors);
  if (password.isEmpty) errors['password'] = ['required'];
  return errors;
}

Map<String, List<String>> validateRegister({
  required String identifier,
  required String password,
  required String displayName,
}) {
  final errors = <String, List<String>>{};
  final name = displayName.trim();
  if (name.isEmpty) {
    errors['display_name'] = ['required'];
  } else if (name.length > kNameMaxLength) {
    errors['display_name'] = ['maxLength'];
  }
  _identifier(identifier, errors);
  if (password.length < kPasswordMinLength) {
    errors['password'] = ['minLength'];
  } else if (password.length > kPasswordMaxLength) {
    errors['password'] = ['maxLength'];
  }
  return errors;
}

/// Tạo gia đình: tên không rỗng, ≤ 100; múi giờ do UI chọn từ danh sách nên chỉ cần không rỗng.
Map<String, List<String>> validateCreateFamily({
  required String name,
  required String timezone,
}) {
  final errors = <String, List<String>>{};
  final n = name.trim();
  if (n.isEmpty) {
    errors['name'] = ['required'];
  } else if (n.length > kNameMaxLength) {
    errors['name'] = ['maxLength'];
  }
  if (timezone.trim().isEmpty) errors['timezone'] = ['required'];
  return errors;
}

void _identifier(String raw, Map<String, List<String>> errors) {
  final v = raw.trim();
  if (v.isEmpty) {
    errors['identifier'] = ['required'];
  } else if (v.length > kIdentifierMaxLength) {
    errors['identifier'] = ['maxLength'];
  }
}
