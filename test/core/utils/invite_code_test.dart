import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/utils/invite_code.dart';

void main() {
  group('normalizeInviteCode', () {
    test('chữ thường, khoảng trắng, dấu gạch được chuẩn hóa như server', () {
      expect(normalizeInviteCode('k7m2q9xa'), 'K7M2Q9XA');
      expect(normalizeInviteCode(' k7m2-q9xa '), 'K7M2Q9XA');
      expect(normalizeInviteCode('K7M2 Q9XA'), 'K7M2Q9XA');
    });

    test('sai độ dài hoặc ký tự ngoài bảng chữ → null', () {
      expect(normalizeInviteCode(''), isNull);
      expect(normalizeInviteCode('K7M2Q9X'), isNull);
      expect(normalizeInviteCode('K7M2Q9XAA'), isNull);
      expect(normalizeInviteCode('K7M2Q9X0'), isNull); // 0
      expect(normalizeInviteCode('K7M2Q9XO'), isNull); // O
      expect(normalizeInviteCode('K7M2Q9XU'), isNull); // U
      expect(normalizeInviteCode('K7M2Q9X!'), isNull);
    });
  });
}
