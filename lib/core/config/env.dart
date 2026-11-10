/// Cấu hình môi trường đọc từ `--dart-define-from-file=env/dev.json`.
class Env {
  const Env({
    required this.name,
    required this.apiBaseUrl,
    required this.googleMapsApiKey,
  });

  const Env.fromDefines()
    : name = const String.fromEnvironment('ENV', defaultValue: 'dev'),
      apiBaseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000/api/v1',
      ),
      googleMapsApiKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  final String name;
  final String apiBaseUrl;
  final String googleMapsApiKey;

  bool get isProd => name == 'prod';
}
