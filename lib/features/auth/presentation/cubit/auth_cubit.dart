import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/session/app_session_cubit.dart';
import '../../../../core/utils/submit_state.dart';
import '../../data/repository/auth_repository.dart';
import '../../domain/auth_validators.dart';

/// Form đăng nhập / đăng ký. Thành công → làm mới phiên (`GET /me`); router tự chuyển màn.
@injectable
class AuthCubit extends Cubit<SubmitState<void>> {
  AuthCubit(this._auth, this._session) : super(const SubmitState());

  final AuthRepository _auth;
  final AppSessionCubit _session;

  Future<void> login({required String identifier, required String password}) {
    final errors = validateLogin(identifier: identifier, password: password);
    return _submit(
      errors,
      () => _auth.login(identifier: identifier, password: password),
    );
  }

  Future<void> register({
    required String identifier,
    required String password,
    required String displayName,
  }) {
    final errors = validateRegister(
      identifier: identifier,
      password: password,
      displayName: displayName,
    );
    return _submit(
      errors,
      () => _auth.register(
        identifier: identifier,
        password: password,
        displayName: displayName,
      ),
    );
  }

  /// Xóa lỗi khi người dùng bắt đầu sửa lại form.
  void clearErrors() {
    if (state.status == SubmitStatus.failure) emit(const SubmitState());
  }

  Future<void> _submit(
    Map<String, List<String>> localErrors,
    Future<void> Function() action,
  ) async {
    if (state.isSubmitting) return; // chống bấm đúp
    if (localErrors.isNotEmpty) {
      emit(
        SubmitState.failure(
          fieldErrors: localErrors,
          error: ApiErrorCode.validationError,
        ),
      );
      return;
    }
    emit(const SubmitState.submitting());
    try {
      await action();
    } on ApiException catch (e) {
      emit(SubmitState.fromException(e));
      return;
    }
    // Đã đăng nhập. Làm mới `/me` có thể lỗi mạng: khi đó phiên sang `failure` (màn chờ + thử lại),
    // vẫn không coi là đăng nhập thất bại vì token đã được lưu.
    emit(const SubmitState.success());
    await _session.refreshMe();
  }
}
