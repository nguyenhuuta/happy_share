import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/features/auth/domain/auth_validators.dart';

void main() {
  group('validateLogin', () {
    test('hợp lệ', () {
      expect(validateLogin(identifier: 'mai.tran', password: 'x'), isEmpty);
    });
    test('thiếu identifier / mật khẩu', () {
      expect(validateLogin(identifier: '   ', password: ''), {
        'identifier': ['required'],
        'password': ['required'],
      });
    });
    test(
      'mật khẩu KHÔNG kiểm tra độ dài khi đăng nhập (mật khẩu cũ vẫn thử được)',
      () {
        expect(validateLogin(identifier: 'a', password: 'ngan'), isEmpty);
      },
    );
    test('identifier quá 254 ký tự', () {
      expect(
        validateLogin(identifier: 'a' * 255, password: 'x')['identifier'],
        ['maxLength'],
      );
      expect(validateLogin(identifier: 'a' * 254, password: 'x'), isEmpty);
    });
    test(
      'không kiểm tra định dạng — server nhận dạng email/SĐT/tên tài khoản',
      () {
        for (final id in [
          'mai@email.com',
          '0912345678',
          '+84 912 345 678',
          'mai.tran',
          '1ab',
        ]) {
          expect(
            validateLogin(identifier: id, password: 'x'),
            isEmpty,
            reason: id,
          );
        }
      },
    );
  });

  group('validateRegister', () {
    Map<String, List<String>> v({
      String id = 'mai.tran',
      String pw = 'matkhau123',
      String name = 'Mẹ',
    }) => validateRegister(identifier: id, password: pw, displayName: name);

    test('hợp lệ', () => expect(v(), isEmpty));
    test('mật khẩu 8–72 ký tự', () {
      expect(v(pw: '1234567')['password'], ['minLength']);
      expect(v(pw: '12345678'), isEmpty);
      expect(v(pw: 'a' * 72), isEmpty);
      expect(v(pw: 'a' * 73)['password'], ['maxLength']);
    });
    test('tên hiển thị không rỗng, ≤ 100', () {
      expect(v(name: '  ')['display_name'], ['required']);
      expect(v(name: 'a' * 100), isEmpty);
      expect(v(name: 'a' * 101)['display_name'], ['maxLength']);
    });
    test('gom nhiều lỗi cùng lúc', () {
      expect(v(id: '', pw: 'x', name: ''), {
        'display_name': ['required'],
        'identifier': ['required'],
        'password': ['minLength'],
      });
    });
    test(
      'mật khẩu toàn khoảng trắng đủ dài vẫn hợp lệ về độ dài (server là nơi quyết định)',
      () {
        expect(v(pw: ' ' * 8), isEmpty);
      },
    );
  });

  group('validateCreateFamily', () {
    test('hợp lệ', () {
      expect(
        validateCreateFamily(name: 'Nhà Nguyễn', timezone: 'Asia/Ho_Chi_Minh'),
        isEmpty,
      );
    });
    test('tên rỗng / quá dài, thiếu múi giờ', () {
      expect(validateCreateFamily(name: ' ', timezone: '')['name'], [
        'required',
      ]);
      expect(validateCreateFamily(name: ' ', timezone: '')['timezone'], [
        'required',
      ]);
      expect(validateCreateFamily(name: 'a' * 101, timezone: 'UTC')['name'], [
        'maxLength',
      ]);
    });
  });
}
