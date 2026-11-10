import 'api_exception.dart';

/// Envelope phản hồi chung (A4): `{success, data, error}`.
class ApiEnvelope {
  const ApiEnvelope({required this.success, this.data, this.error});

  final bool success;
  final Object? data;
  final ApiEnvelopeError? error;

  /// Trả `null` nếu [json] không đúng định dạng envelope.
  static ApiEnvelope? tryParse(Object? json) {
    if (json is! Map || json['success'] is! bool) return null;
    final rawError = json['error'];
    return ApiEnvelope(
      success: json['success'] as bool,
      data: json['data'],
      error: rawError is Map
          ? ApiEnvelopeError(
              code: ApiErrorCode.fromCode(rawError['code']?.toString()),
              message: rawError['message']?.toString(),
              details: rawError['details'] is Map
                  ? Map<String, dynamic>.from(rawError['details'] as Map)
                  : const {},
            )
          : null,
    );
  }
}

class ApiEnvelopeError {
  const ApiEnvelopeError({
    required this.code,
    this.message,
    this.details = const {},
  });

  final ApiErrorCode code;
  final String? message;
  final Map<String, dynamic> details;
}
