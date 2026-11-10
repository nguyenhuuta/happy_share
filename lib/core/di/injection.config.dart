// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:happy_share/core/config/env.dart' as _i17;
import 'package:happy_share/core/di/injection.dart' as _i327;
import 'package:happy_share/core/network/api_client.dart' as _i740;
import 'package:happy_share/core/session/app_session_cubit.dart' as _i822;
import 'package:happy_share/core/storage/local_data_cleaner.dart' as _i386;
import 'package:happy_share/core/storage/secure_token_store.dart' as _i22;
import 'package:happy_share/features/auth/data/repository/auth_repository.dart'
    as _i873;
import 'package:happy_share/features/auth/data/repository/me_repository.dart'
    as _i1039;
import 'package:happy_share/features/auth/presentation/cubit/auth_cubit.dart'
    as _i434;
import 'package:happy_share/features/family/data/repository/family_repository.dart'
    as _i743;
import 'package:happy_share/features/family/presentation/cubit/family_setup_cubit.dart'
    as _i660;
import 'package:happy_share/features/family/presentation/cubit/members_cubit.dart'
    as _i672;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i17.Env>(() => registerModule.env);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i974.Logger>(() => registerModule.logger);
    gh.lazySingleton<_i22.TokenStore>(
      () => _i22.SecureTokenStore(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i386.LocalDataCleaner>(
      () => _i386.DefaultLocalDataCleaner(gh<_i22.TokenStore>()),
    );
    gh.lazySingleton<_i740.ApiClient>(
      () => _i740.ApiClient(gh<_i17.Env>(), gh<_i22.TokenStore>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i873.AuthRepository>(
      () => _i873.AuthRepository(
        gh<_i740.ApiClient>(),
        gh<_i22.TokenStore>(),
        gh<_i386.LocalDataCleaner>(),
      ),
    );
    gh.lazySingleton<_i1039.MeRepository>(
      () => _i1039.MeRepository(gh<_i740.ApiClient>()),
    );
    gh.lazySingleton<_i743.FamilyRepository>(
      () => _i743.FamilyRepository(gh<_i740.ApiClient>()),
    );
    gh.lazySingleton<_i822.AppSessionCubit>(
      () => _i822.AppSessionCubit(
        gh<_i1039.MeRepository>(),
        gh<_i873.AuthRepository>(),
        gh<_i22.TokenStore>(),
        gh<_i386.LocalDataCleaner>(),
        gh<_i740.ApiClient>(),
      ),
    );
    gh.factory<_i660.FamilySetupCubit>(
      () => _i660.FamilySetupCubit(
        gh<_i743.FamilyRepository>(),
        gh<_i822.AppSessionCubit>(),
      ),
    );
    gh.factory<_i672.MembersCubit>(
      () => _i672.MembersCubit(
        gh<_i743.FamilyRepository>(),
        gh<_i822.AppSessionCubit>(),
      ),
    );
    gh.factory<_i434.AuthCubit>(
      () => _i434.AuthCubit(
        gh<_i873.AuthRepository>(),
        gh<_i822.AppSessionCubit>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i327.RegisterModule {}
