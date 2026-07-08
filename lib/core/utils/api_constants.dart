class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://envy-enhance-fixed5.vercel.app',
  );

  static const String apiPath = '/api';
  static String get apiUrl => '$baseUrl$apiPath';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Pagination
  static const int defaultPageSize = 12;
  static const int maxPageSize = 50;

  // Product image base URL
  static String productImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$baseUrl/$path';
  }
}
