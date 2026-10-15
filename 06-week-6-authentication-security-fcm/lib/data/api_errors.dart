import 'package:dio/dio.dart';

/// Menerjemahkan `DioException` menjadi pesan yang layak ditampilkan ke UI.
///
/// UI hanya menerima teks, bukan exception mentah, sehingga tidak pernah
/// membocorkan detail internal (URL, stack trace) ke layar pengguna.
String friendlyErrorMessage(Object error) {
  if (error is! DioException) {
    return 'Terjadi kesalahan tak terduga. Coba lagi.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi lambat. Periksa jaringan lalu coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet.';
    case DioExceptionType.badCertificate:
      return 'Sertifikat server tidak tepercaya.';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code == 401) return 'Sesi berakhir. Silakan masuk ulang.';
      if (code == 403) return 'Anda tidak punya akses ke data ini.';
      if (code == 404) return 'Data tidak ditemukan.';
      return 'Server menolak permintaan (kode $code).';
    case DioExceptionType.unknown:
      return 'Gagal menghubungi server. Coba lagi.';
  }
}
