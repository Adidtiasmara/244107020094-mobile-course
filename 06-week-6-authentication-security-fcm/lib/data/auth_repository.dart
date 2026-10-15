/// Sesi hasil login: pasangan access token dan refresh token.
class AuthSession {
  const AuthSession({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

/// Auth provider tiruan yang siap diganti Firebase Auth.
///
/// Alur token identik dengan penyedia sungguhan, sehingga migrasi ke
/// `FirebaseAuth.instance.signInWithEmailAndPassword` atau Google Sign-In hanya
/// mengganti isi dua method di kelas ini tanpa mengubah UI maupun interceptor.
class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@')) {
      throw Exception('Email tidak valid');
    }
    if (password.length < 6) {
      throw Exception('Kata sandi minimal 6 karakter');
    }
    // Kredensial demo: hanya kata sandi ini yang diterima mock provider.
    if (password != 'rahasia123') {
      throw Exception('Email atau kata sandi salah');
    }
    // Simulasi JWT. Di produksi token diterbitkan server, jangan dirakit manual.
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
