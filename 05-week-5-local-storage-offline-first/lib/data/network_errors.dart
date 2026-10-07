import 'package:dio/dio.dart';

/// Mengubah exception teknis menjadi pesan yang ramah pengguna.
String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Data tidak ditemukan (404).';
        if (code == 401 || code == 403) {
          return 'Akses ditolak ($code). Periksa kredensial Anda.';
        }
        return 'Server bermasalah ($code). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  if (error is OfflineException) return error.message;
  return 'Terjadi kesalahan tak terduga: $error';
}

/// Dilempar ketika `forceOffline` aktif, sehingga demo offline deterministik
/// tanpa bergantung pada kondisi Wi-Fi.
class OfflineException implements Exception {
  const OfflineException([this.message = 'Mode offline aktif.']);

  final String message;

  @override
  String toString() => message;
}
