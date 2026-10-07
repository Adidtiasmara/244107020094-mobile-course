import 'package:dio/dio.dart';

/// Base URL dapat ditimpa saat build/run, misalnya untuk menguji error:
/// `flutter run --dart-define=API_BASE_URL=https://localhost:9/`
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://jsonplaceholder.typicode.com',
);

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: false),
  );
  return dio;
}
