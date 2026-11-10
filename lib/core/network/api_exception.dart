/// Mã lỗi API — khớp CLAUDE.md phần A4, cộng 2 mã cục bộ (không đến từ server).
enum ApiErrorCode {
  validationError('VALIDATION_ERROR'),
  batchTooLarge('BATCH_TOO_LARGE'),
  unauthenticated('UNAUTHENTICATED'),
  tokenExpired('TOKEN_EXPIRED'),
  refreshTokenInvalid('REFRESH_TOKEN_INVALID'),
  invalidCredentials('INVALID_CREDENTIALS'),
  forbidden('FORBIDDEN'),
  notFamilyMember('NOT_FAMILY_MEMBER'),
  consentRequired('CONSENT_REQUIRED'),
  consentRevoked('CONSENT_REVOKED'),
  deviceNotRegistered('DEVICE_NOT_REGISTERED'),
  notFound('NOT_FOUND'),
  identifierTaken('IDENTIFIER_TAKEN'),
  alreadyInFamily('ALREADY_IN_FAMILY'),
  inviteInvalid('INVITE_INVALID'),
  inviteExpired('INVITE_EXPIRED'),
  ownerCannotLeave('OWNER_CANNOT_LEAVE'),
  groupLimit('GROUP_LIMIT'),
  planLimitMembers('PLAN_LIMIT_MEMBERS'),
  planLimitPlaces('PLAN_LIMIT_PLACES'),
  historyOutOfPlan('HISTORY_OUT_OF_PLAN'),
  rateLimited('RATE_LIMITED'),
  internalError('INTERNAL_ERROR'),

  /// Cục bộ: không có mạng / timeout / lỗi kết nối.
  networkError('NETWORK_ERROR'),

  /// Cục bộ: mã lạ hoặc phản hồi sai định dạng.
  unknown('UNKNOWN');

  const ApiErrorCode(this.code);

  final String code;

  static ApiErrorCode fromCode(String? code) {
    for (final value in ApiErrorCode.values) {
      if (value.code == code) return value;
    }
    return ApiErrorCode.unknown;
  }
}

/// Lỗi ném ra từ lớp data. UI phân nhánh theo [code], KHÔNG hiển thị [message].
class ApiException implements Exception {
  const ApiException(
    this.code, {
    this.message,
    this.httpStatus,
    this.details = const {},
  });

  final ApiErrorCode code;

  /// Chỉ để debug/log. Không hiển thị cho người dùng.
  final String? message;
  final int? httpStatus;
  final Map<String, dynamic> details;

  /// Với `VALIDATION_ERROR`: `{field: [rule, ...]}`.
  Map<String, List<String>> get fieldErrors {
    final fields = details['fields'];
    if (fields is! Map) return const {};
    return {
      for (final entry in fields.entries)
        entry.key.toString(): [
          if (entry.value is List)
            for (final rule in entry.value as List) rule.toString(),
        ],
    };
  }

  @override
  String toString() => 'ApiException(${code.code}, http=$httpStatus)';
}
