/// Cặp token trả từ `/auth/*` (A4). Thời điểm hết hạn là UTC.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    accessExpiresAt: DateTime.parse(json['access_expires_at'] as String),
    refreshExpiresAt: DateTime.parse(json['refresh_expires_at'] as String),
  );

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'access_expires_at': accessExpiresAt.toUtc().toIso8601String(),
    'refresh_expires_at': refreshExpiresAt.toUtc().toIso8601String(),
  };
}
