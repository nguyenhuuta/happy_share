import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/constants/domain_constants.dart';
import 'package:happy_share/core/constants/domain_enums.dart';
import 'package:happy_share/core/network/api_exception.dart';

void main() {
  test('ApiErrorCode.fromCode map đúng mã A4 và mã lạ → unknown', () {
    expect(
      ApiErrorCode.fromCode('CONSENT_REVOKED'),
      ApiErrorCode.consentRevoked,
    );
    expect(
      ApiErrorCode.fromCode('PLAN_LIMIT_PLACES'),
      ApiErrorCode.planLimitPlaces,
    );
    expect(ApiErrorCode.fromCode('NOPE'), ApiErrorCode.unknown);
    expect(ApiErrorCode.fromCode(null), ApiErrorCode.unknown);
  });

  test('mã lỗi server (A4) đều có trong enum, không trùng giá trị', () {
    const a4 = [
      'VALIDATION_ERROR',
      'BATCH_TOO_LARGE',
      'UNAUTHENTICATED',
      'TOKEN_EXPIRED',
      'REFRESH_TOKEN_INVALID',
      'INVALID_CREDENTIALS',
      'FORBIDDEN',
      'NOT_FAMILY_MEMBER',
      'CONSENT_REQUIRED',
      'CONSENT_REVOKED',
      'DEVICE_NOT_REGISTERED',
      'NOT_FOUND',
      'IDENTIFIER_TAKEN',
      'ALREADY_IN_FAMILY',
      'INVITE_INVALID',
      'INVITE_EXPIRED',
      'OWNER_CANNOT_LEAVE',
      'PLAN_LIMIT_MEMBERS',
      'PLAN_LIMIT_PLACES',
      'HISTORY_OUT_OF_PLAN',
      'RATE_LIMITED',
      'INTERNAL_ERROR',
    ];
    for (final code in a4) {
      expect(ApiErrorCode.fromCode(code).code, code);
    }
    final codes = ApiErrorCode.values.map((e) => e.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('EMAIL_TAKEN (cũ) không còn là mã hợp lệ → unknown', () {
    expect(ApiErrorCode.fromCode('EMAIL_TAKEN'), ApiErrorCode.unknown);
    expect(
      ApiErrorCode.fromCode('IDENTIFIER_TAKEN'),
      ApiErrorCode.identifierTaken,
    );
  });

  test('mã mời hợp lệ theo A3.3 (bảng chữ không có 0/O/1/I/L/U)', () {
    expect(kInviteCodePattern.hasMatch('K7M2Q9XA'), isTrue);
    expect(kInviteCodePattern.hasMatch('K7M2Q9X0'), isFalse); // có 0
    expect(kInviteCodePattern.hasMatch('K7M2Q9XL'), isFalse); // có L
    expect(
      kInviteCodePattern.hasMatch('K7M2Q9XU'),
      isFalse,
    ); // có U (server không bao giờ sinh)
    expect(kInviteCodePattern.hasMatch('K7M2Q9X'), isFalse); // thiếu ký tự
    // Mọi ký tự trong bảng chữ của server đều được chấp nhận, mọi ký tự bị loại đều bị từ chối.
    for (final ch in '23456789ABCDEFGHJKMNPQRSTVWXYZ'.split('')) {
      expect(kInviteCodePattern.hasMatch(ch * 8), isTrue, reason: ch);
    }
    for (final ch in '01OILU'.split('')) {
      expect(kInviteCodePattern.hasMatch(ch * 8), isFalse, reason: ch);
    }
  });

  test('giới hạn đầu vào khớp A4', () {
    expect(kPasswordMinLength, 8);
    expect(kPasswordMaxLength, 72);
    expect(kIdentifierMaxLength, 254);
    expect(kNameMaxLength, 100);
    expect(
      [kPlaceRadiusMinM, kPlaceRadiusDefaultM, kPlaceRadiusMaxM],
      [50, 150, 500],
    );
  });

  test('mọi enum domain có giá trị unknown', () {
    expect(IdentifierType.values, contains(IdentifierType.unknown));
    expect(MemberRole.values, contains(MemberRole.unknown));
    expect(SharingState.values, contains(SharingState.unknown));
    expect(ConsentStatus.values, contains(ConsentStatus.unknown));
    expect(Freshness.values, contains(Freshness.unknown));
    expect(GapReason.values, contains(GapReason.unknown));
  });
}
