/// Satu sumber kebenaran untuk seluruh path rute aplikasi.
///
/// Dipakai bersama oleh GoRouter dan deep link dari notifikasi FCM agar
/// keduanya tidak pernah memakai string yang berbeda.
class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String home = '/';
  static const String debug = '/debug';
  static const String announcementPattern = '/pengumuman/:id';

  static String announcement(String id) => '/pengumuman/$id';
}
