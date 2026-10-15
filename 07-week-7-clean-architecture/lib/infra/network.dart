import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/failures.dart';

/// Base URL dapat ditimpa saat build/run, misalnya untuk menguji offline:
/// `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8085`
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

final dioProvider = Provider<Dio>((ref) => createDio());

/// Toggle offline deterministik agar demo/testing tidak bergantung pada Wi-Fi.
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

/// Memetakan exception jaringan teknis menjadi `NetworkFailure` yang ramah
/// pengguna (Refactoring Challenge #3). Dipakai lapisan `data` sebelum
/// menyerahkan hasil ke domain, sehingga UI hanya menerima `message`.
NetworkFailure mapDioError(Object error) {
  if (error is! DioException) {
    return NetworkFailure('Terjadi kesalahan jaringan. Coba lagi.');
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure(
        'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.',
      );
    case DioExceptionType.connectionError:
      return const NetworkFailure(
        'Tidak dapat terhubung ke server. Periksa internet Anda.',
      );
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 404) return const NetworkFailure('Data tidak ditemukan (404).');
      if (code == 401 || code == 403) {
        return NetworkFailure('Akses ditolak ($code). Periksa kredensial Anda.');
      }
      return NetworkFailure('Server bermasalah ($code). Coba lagi nanti.');
    default:
      return const NetworkFailure('Terjadi kesalahan jaringan. Coba lagi.');
  }
}
