import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/di/injection.dart';
import 'package:happy_share/core/network/api_client.dart';
import 'package:happy_share/core/session/app_session_cubit.dart';
import 'package:happy_share/core/storage/local_data_cleaner.dart';
import 'package:happy_share/core/storage/secure_token_store.dart';
import 'package:happy_share/features/auth/data/repository/auth_repository.dart';
import 'package:happy_share/features/auth/data/repository/me_repository.dart';
import 'package:happy_share/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:happy_share/features/family/data/repository/family_repository.dart';
import 'package:happy_share/features/family/presentation/cubit/family_setup_cubit.dart';
import 'package:happy_share/features/family/presentation/cubit/members_cubit.dart';

/// Bắt lỗi thiếu đăng ký DI (injection.config.dart sinh tự động) ngay ở test thay vì sập lúc mở app.
void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });
  tearDown(() => getIt.reset());

  test('resolve được toàn bộ đồ thị phụ thuộc của M1', () {
    expect(getIt<ApiClient>(), isNotNull);
    expect(getIt<TokenStore>(), isA<SecureTokenStore>());
    expect(getIt<LocalDataCleaner>(), isA<DefaultLocalDataCleaner>());
    expect(getIt<AuthRepository>(), isNotNull);
    expect(getIt<MeRepository>(), isNotNull);
    expect(getIt<FamilyRepository>(), isNotNull);
    expect(getIt<AppSessionCubit>(), isNotNull);
    expect(getIt<AuthCubit>(), isNotNull);
    expect(getIt<FamilySetupCubit>(), isNotNull);
    expect(getIt<MembersCubit>(), isNotNull);
  });

  test(
    'AppSessionCubit là singleton của app; cubit form/thành viên là factory (mỗi màn một bản)',
    () {
      expect(
        identical(getIt<AppSessionCubit>(), getIt<AppSessionCubit>()),
        isTrue,
      );
      expect(identical(getIt<AuthCubit>(), getIt<AuthCubit>()), isFalse);
      expect(identical(getIt<MembersCubit>(), getIt<MembersCubit>()), isFalse);
      expect(identical(getIt<ApiClient>(), getIt<ApiClient>()), isTrue);
    },
  );
}
