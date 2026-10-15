import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/debug_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapPush();
  runApp(const ProviderScope(child: CampusNotifyApp()));
}

/// Router dengan guard: pengguna yang belum login selalu diarahkan ke `/login`,
/// dan pengguna yang sudah login tidak bisa kembali ke `/login`.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      final goingToLogin = state.matchedLocation == AppRoutes.login;

      if (!loggedIn && !goingToLogin) return AppRoutes.login;
      if (loggedIn && goingToLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(path: AppRoutes.debug, builder: (_, _) => const DebugPage()),
      GoRoute(
        path: AppRoutes.announcementPattern,
        builder: (_, state) =>
            AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );

  ref.listen(authStateProvider, (_, _) => router.refresh());
  return router;
});

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _pushStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final router = ref.read(routerProvider);

      listenForeground((route) {
        _messengerKey.currentState
          ?..hideCurrentMaterialBanner()
          ..showMaterialBanner(
            MaterialBanner(
              content: const Text(
                'Jadwal kuliah berubah: Kelas Mobile pindah ke Ruang A2 '
                'jam 13.00',
              ),
              leading: const Icon(Icons.notifications_active),
              actions: [
                TextButton(
                  onPressed: () {
                    _messengerKey.currentState?.hideCurrentMaterialBanner();
                    router.go(route);
                  },
                  child: const Text('Buka'),
                ),
              ],
            ),
          );
      });

      listenOpenedApp((route) {
        _messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Dibuka dari notifikasi: $route'),
            duration: const Duration(seconds: 4),
          ),
        );
        router.go(route);
      });

      await handleTerminated((route) => router.go(route));
    });
  }

  /// Menjalankan siklus hidup FCM setelah pengguna berhasil login, mengikuti
  /// alur wajib codelab: minta izin, ambil token dan kirim ke backend, pantau
  /// `onTokenRefresh`, lalu berlangganan topik broadcast.
  Future<void> _startPush() async {
    final granted = await requestNotificationPermission();
    if (mounted) {
      ref.read(notificationPermissionProvider.notifier).set(granted);
    }

    await initFcmToken(
      onToken: (token) async {
        // Titik integrasi backend: POST /devices { fcm_token, platform }.
        // Token hanya dikirim lewat HTTPS body dan ditulis terpotong di log.
        debugPrint(
          'POST /devices fcm_token=${maskToken(token)} '
          'platform=${defaultTargetPlatform.name}',
        );
        if (mounted) ref.read(fcmTokenProvider.notifier).set(token);
      },
    );

    if (mounted) ref.read(subscribedTopicProvider.notifier).set(true);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final loggedIn = ref.watch(authStateProvider).value ?? false;
    if (loggedIn && !_pushStarted) {
      _pushStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startPush());
    }

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: router,
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF16425B),
      brightness: brightness,
    ),
    brightness: brightness,
    useMaterial3: true,
  );
}
