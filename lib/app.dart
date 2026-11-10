import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/gen/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/session/app_session_cubit.dart';
import 'core/theme/app_theme.dart';

class HappyShareApp extends StatefulWidget {
  /// [session] điều khiển điều hướng đăng nhập/gia đình/consent. `null` → chỉ hiện shell 5 tab (test).
  const HappyShareApp({super.key, this.session});

  final AppSessionCubit? session;

  @override
  State<HappyShareApp> createState() => _HappyShareAppState();
}

class _HappyShareAppState extends State<HappyShareApp> {
  late final GoRouter _router = createAppRouter(session: widget.session);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Mặc định tiếng Việt; chỉ dùng en khi máy đặt en.
      localeResolutionCallback: (locale, supported) =>
          locale?.languageCode == 'en'
          ? const Locale('en')
          : const Locale('vi'),
    );
    final session = widget.session;
    return session == null
        ? app
        : BlocProvider.value(value: session, child: app);
  }
}
