/// API configuration - Base URL for Laravel backend
///
/// **Localhost URLs by platform:**
/// - Android Emulator: http://10.0.2.2:8000
/// - iOS Simulator: http://localhost:8000
/// - Physical device: http://YOUR_PC_IP:8000 (e.g. http://192.168.1.5:8000)
///
/// **Enable API mode:** flutter run --dart-define=USE_API=true
class ApiConfig {
  ApiConfig._();

  /// Use real API instead of mock data
  static const bool useApi = bool.fromEnvironment(
    'USE_API',
    defaultValue: true,
  );

  /// Base URL for API - change based on your setup
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.8.224:8003/api',
  );

  /// Full URL for an endpoint
  static String url(String path) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }

  /// Timeout for API requests (seconds)
  static const int timeoutSeconds = 30;
}
