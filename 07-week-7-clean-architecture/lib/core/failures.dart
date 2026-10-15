/// Kegagalan tingkat domain.
///
/// Murni Dart: tidak boleh mengimpor Flutter, Dio, SQLite, atau Firebase agar
/// logika bisnis dapat diuji tanpa framework. `presentation` hanya menerima
/// `message`, bukan exception mentah.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// Kegagalan yang berasal dari penyimpanan lokal (SQLite/preferences).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Kegagalan yang berasal dari jaringan (Dio/timeout/offline).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Kegagalan tak terduga yang belum dipetakan ke jenis lain.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
