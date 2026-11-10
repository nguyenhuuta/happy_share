import 'package:equatable/equatable.dart';

import '../network/api_exception.dart';

enum SubmitStatus { idle, submitting, success, failure }

/// Trạng thái chung của một form gửi lên server (đăng nhập, đăng ký, tạo/tham gia gia đình…).
///
/// - [fieldErrors]: `{trường: [quy tắc]}` — từ kiểm tra cục bộ hoặc `VALIDATION_ERROR` của server.
///   UI hiển thị lỗi theo quy tắc (l10n), không hiển thị `message` thô của server.
/// - [error]: mã lỗi tổng quát khi không gắn được vào một trường (`INVALID_CREDENTIALS`, mạng…).
class SubmitState<T> extends Equatable {
  const SubmitState({
    this.status = SubmitStatus.idle,
    this.fieldErrors = const {},
    this.error,
    this.result,
  });

  final SubmitStatus status;
  final Map<String, List<String>> fieldErrors;
  final ApiErrorCode? error;
  final T? result;

  bool get isSubmitting => status == SubmitStatus.submitting;

  const SubmitState.submitting() : this(status: SubmitStatus.submitting);

  const SubmitState.success([T? result])
    : this(status: SubmitStatus.success, result: result);

  const SubmitState.failure({
    Map<String, List<String>> fieldErrors = const {},
    ApiErrorCode? error,
  }) : this(
         status: SubmitStatus.failure,
         fieldErrors: fieldErrors,
         error: error,
       );

  /// Lỗi từ server → trạng thái thất bại giữ nguyên `fieldErrors` của `VALIDATION_ERROR`.
  factory SubmitState.fromException(ApiException e) => SubmitState.failure(
    fieldErrors: e.code == ApiErrorCode.validationError
        ? e.fieldErrors
        : const {},
    error: e.code,
  );

  @override
  List<Object?> get props => [status, fieldErrors, error, result];
}
