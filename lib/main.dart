import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/session/app_session_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  final session = getIt<AppSessionCubit>();
  runApp(HappyShareApp(session: session));
  // Không chặn khung hình đầu: router hiện màn chờ trong lúc đọc token / gọi GET /me.
  unawaited(session.start());
}
