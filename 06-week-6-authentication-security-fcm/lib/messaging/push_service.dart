import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'route_parser.dart';

final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

/// Deep link yang tertunda dari klik notifikasi saat aplikasi terminated.
String? pendingDeepLink;

String? _currentToken;
String? get currentToken => _currentToken;

void Function(String route)? _foregroundGo;
void Function(String route)? _openedApp;
void Function(String route)? _terminatedGo;
Future<void> Function(String token)? _onToken;

const String _topicPengumuman = 'pengumuman-kampus';
const String _channelId = 'pengumuman';
const String _channelName = 'Pengumuman Kampus';

/// Menyamarkan token agar aman ditampilkan di layar.
///
/// Hanya `visible` karakter pertama yang ditampilkan. Token penuh tidak pernah
/// ditampilkan di UI, ditulis ke log, atau disertakan di screenshot laporan.
String maskToken(String token, {int visible = 12}) {
  if (token.length <= visible) return token;
  return '${token.substring(0, visible)}...';
}

/// Handler background wajib fungsi top-level dan berjalan di isolate terpisah.
///
/// Karena isolate berbeda, handler ini tidak boleh menyentuh `BuildContext`,
/// Riverpod, atau state UI. Tugasnya hanya mencatat ringan; navigasi dilakukan
/// saat pengguna mengetuk notifikasi.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    'FCM background: id=${message.messageId} route=${routeFromMessage(message.data)}',
  );
}

Future<void> bootstrapPush() async {
  try {
    await Firebase.initializeApp();
  } catch (error) {
    debugPrint('Firebase belum dikonfigurasi: $error');
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await initLocalNotifications();
}

Future<bool> requestNotificationPermission() async {
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  } catch (error) {
    debugPrint('Gagal meminta izin notifikasi: $error');
    return false;
  }
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      final route = response.payload;
      if (route != null && route.isNotEmpty) {
        _foregroundGo?.call(route);
      }
    },
  );

  // Buat kanal lebih awal supaya notifikasi FCM saat background/terminated
  // (yang ditampilkan sistem, bukan kode ini) tidak jatuh ke kanal default.
  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Notifikasi pengumuman resmi kampus',
          importance: Importance.high,
        ),
      );
}

/// Mengambil token saat ini, memantau rotasinya, lalu berlangganan topik.
///
/// Listener `onTokenRefresh` wajib ada. Tanpa itu backend menyimpan token basi
/// setelah reinstall, clear data, atau rotasi keamanan.
Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  _onToken = onToken;
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _currentToken = token;
      await onToken(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      _currentToken = token;
      await onToken(token);
    });

    await subscribeToTopic(_topicPengumuman);
  } catch (error) {
    debugPrint('FCM tidak tersedia di perangkat ini: $error');
  }
}

Future<void> subscribeToTopic(String topic) async {
  await FirebaseMessaging.instance.subscribeToTopic(topic);
}

Future<void> unsubscribeFromTopic(String topic) async {
  await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
}

/// Foreground: sistem tidak menampilkan banner otomatis, jadi banner lokal
/// ditampilkan manual. Ketukan pada banner diteruskan ke router.
void listenForeground(void Function(String route) go) {
  _foregroundGo = go;

  FirebaseMessaging.onMessage.listen((message) async {
    final route = routeFromMessage(message.data);
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Notifikasi pengumuman resmi kampus',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: route,
    );
  });
}

/// Background: banner sistem muncul otomatis, dan saat diklik pesan diteruskan
/// ke handler ini untuk navigasi.
void listenOpenedApp(void Function(String route) open) {
  _openedApp = open;

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    open(routeFromMessage(message.data));
  });
}

/// Terminated: aplikasi dibuka dari notifikasi, ambil pesan awal lalu navigasi.
Future<void> handleTerminated(void Function(String route) go) async {
  _terminatedGo = go;
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    go(routeFromMessage(initial.data));
  }
  if (pendingDeepLink != null) {
    go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}

/// Memaksa rotasi token untuk menguji jalur `onTokenRefresh`.
///
/// Menghapus token lama lalu meminta token baru; listener yang sudah terpasang
/// akan menerima token pengganti dan mengirimkannya ke backend.
Future<String?> simulateTokenRefresh() async {
  try {
    await FirebaseMessaging.instance.deleteToken();
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _currentToken = token;
      await _onToken?.call(token);
    }
    return _currentToken;
  } catch (error) {
    debugPrint('Gagal merotasi token: $error');
    return _currentToken;
  }
}

/// Menampilkan notifikasi lokal untuk menguji banner foreground.
Future<void> simulateIncoming({
  required String route,
  String title = 'Jadwal kuliah berubah',
  String body = 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
}) async {
  await _local.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Notifikasi pengumuman resmi kampus',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    payload: route,
  );
}

/// Mensimulasikan klik notifikasi pada state background atau terminated.
///
/// `background` meniru `onMessageOpenedApp`, `terminated` meniru
/// `getInitialMessage` saat aplikasi dibuka dari notifikasi.
Future<void> simulateOpened({
  required String state,
  required String route,
}) async {
  final parsed = routeFromMessage({'route': route});
  if (state == 'terminated') {
    pendingDeepLink = parsed;
    _terminatedGo?.call(parsed);
  } else {
    _openedApp?.call(parsed);
  }
}
