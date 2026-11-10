import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../config/env.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Gọi một lần trong `main()` (và trong entry point của workmanager ở M3).
@InjectableInit(initializerName: 'init', asExtension: true)
Future<void> configureDependencies() async => getIt.init();

/// Các đối tượng bên thứ ba / không có constructor đánh dấu được.
@module
abstract class RegisterModule {
  @lazySingleton
  Env get env => const Env.fromDefines();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  /// Logger KHÔNG được ghi tọa độ — chỉ số lượng, id, mã lỗi.
  @lazySingleton
  Logger get logger => Logger(printer: SimplePrinter());
}
