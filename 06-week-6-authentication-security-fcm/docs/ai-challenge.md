# AI Challenge - Week 6

Dokumen ini mencatat prompt, output awal AI, verifikasi terhadap AI Verification
Checklist modul, perbaikan manual, keputusan final, dan hasil testing untuk
bagian **AI Prompt Challenge** pada praktikum Authentication, Security & FCM.

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

AI assistant yang dipakai: opencode (model `inferhub/cb/deepseek-v4.1-flash`).

## 2. Output awal AI

### 2.1 PushService versi awal AI (dipotong)

```dart
class PushService {
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> init(WidgetRef ref) async {
    await Firebase.initializeApp();
    final settings = await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM token: $token');
    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      print('token refresh: $t');
    });

    FirebaseMessaging.onMessage.listen((message) async {
      await _local.show(0, message.notification?.title, message.notification?.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // navigasi
    });
  }

  Future<void> onBackground(RemoteMessage message) async {
    print('bg: ${message.data}');
  }
}
```

### 2.2 Klaim AI tentang perbedaan platform

AI menandai Android 13+ wajib `requestPermission`, iOS cukup lewat
`DarwinInitializationSettings`, dan menyatakan handler background tidak boleh
menyentuh `BuildContext`. Ketiga klaim ini benar dan dipertahankan.

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada output awal | Tindakan |
| :--- | :--- | :--- |
| Background handler top-level + `@pragma('vm:entry-point')`? | **Tidak.** AI memakai method kelas `onBackground` tanpa pragma | Diekstrak ke fungsi top-level `firebaseMessagingBackgroundHandler` + pragma |
| `onTokenRefresh` benar-benar kirim token baru ke backend? | **Tidak.** Hanya `print` | Ditambah callback `onToken` yang memanggil `POST /devices` |
| Foreground memakai local notification manual? | Sebagian. `show` dipanggil dengan posisi argumen lama | Diperbaiki ke named argument `id/title/body/notificationDetails/payload` |
| Klik dari ketiga state masuk rute yang benar? | Belum ada `getInitialMessage` dan deep link | Ditambah `handleTerminated` + `routeFromMessage` + GoRouter |
| Token/secret tidak di-hardcode dan tidak di-log penuh? | **Melanggar.** `print('FCM token: $token')` menulis token penuh | Diganti `maskToken` (12 karakter + `...`) dan log terpotong |
| `flutter analyze` dan `flutter test` lolos | Belum ada test | Ditambah 17 test |

## 4. Perbaikan manual yang dilakukan

### 4.1 Handler background top-level dengan pragma

Handler dipindah keluar kelas, diberi `@pragma('vm:entry-point')`, dan hanya
melakukan pekerjaan ringan (log rute). Navigasi dilakukan lewat
`onMessageOpenedApp`/`getInitialMessage` saat pengguna mengetuk notifikasi.

### 4.2 `onTokenRefresh` yang nyata mengirim ke backend

`initFcmToken` menerima callback `onToken`, memanggilnya untuk token awal dan
setiap rotasi, lalu memasukkannya ke `POST /devices` beserta platform. Untuk
membuktikan jalur ini, halaman Debug menyediakan tombol **Simulasikan rotasi
token** yang memicu `deleteToken`/`getToken` sehingga listener benar-benar
dijalankan.

### 4.3 Deep link lewat fungsi murni

`routeFromMessage` dan `announcementIdFromMessage` di
`lib/messaging/route_parser.dart` memisahkan parsing `RemoteMessage -> route`
dari Firebase. Ketiga handler memakai fungsi yang sama sehingga tidak ada rute
yang berbeda antar state.

### 4.4 Masking token

`maskToken` hanya menampilkan 12 karakter pertama. Token penuh tidak pernah
muncul di UI, log, maupun screenshot laporan.

### 4.5 Satu implementasi PushService

`lib/messaging/push_service.dart` memuat seluruh siklus FCM (izin, token,
`onTokenRefresh`, tiga handler, topik) untuk Android/iOS. `maskToken` ikut di
sini agar hanya ada satu berkas messaging, sesuai struktur modul. Dukungan web
(`push_service_stub.dart` + conditional import) dihapus karena codelab menargetkan
perangkat Android/iOS dan notifikasi paling andal diuji di perangkat fisik.

## 5. Keputusan final

| Aspek | Keputusan | Alasan |
| :--- | :--- | :--- |
| Penyimpanan token | `flutter_secure_storage` | Keystore/Keychain terenkripsi; SharedPreferences tidak |
| Auth | Mock provider + JWT simulasi | Codelab berjalan tanpa backend; titik ganti Firebase Auth ditandai |
| Refresh 401 | Sekali, lalu retry | Menghindari loop; bila refresh gagal, `clear()` dan login ulang |
| Deep link | `routeFromMessage` murni | Bisa diunit-test tanpa Firebase |
| Handler background | Top-level + pragma | Berjalan di isolate terpisah |
| Topik | Broadcast saja | Pesan personal harus lewat token perangkat |

Keputusan ini berbeda dari draf awal AI pada empat titik (handler background,
`onTokenRefresh` ke backend, deep link terminated, dan masking token). Alasan
teknisnya tercatat pada bagian 3 dan 4.

## 6. Hasil testing

### 6.1 Unit/widget test

Perintah dan hasil (dijalankan di dalam `campus_notify/`):

```text
$ flutter analyze
Analyzing campus_notify...
No issues found! (ran in 7.2s)

$ flutter test --concurrency=1
+ : test/auth_push_test.dart: routeFromMessage menangani route kosong dan tanpa garis miring
+ : test/auth_push_test.dart: routeFromMessage mengabaikan spasi di sekitar route
+ : test/auth_push_test.dart: announcementIdFromMessage mengambil id dari field id
+ : test/auth_push_test.dart: announcementIdFromMessage jatuh ke segmen terakhir rute bila id tidak ada
+ : test/auth_push_test.dart: announcementIdFromMessage mengembalikan null untuk payload beranda
+ : test/auth_push_test.dart: maskToken menyisakan 12 karakter pertama lalu elipsis
+ : test/auth_push_test.dart: maskToken tidak memotong token yang lebih pendek dari batas
+ : test/auth_push_test.dart: AuthRepository login menolak email tanpa @
+ : test/auth_push_test.dart: AuthRepository login menolak kata sandi pendek
+ : test/auth_push_test.dart: AuthRepository login menolak kata sandi yang salah
+ : test/auth_push_test.dart: AuthRepository login sukses mengembalikan pasangan access dan refresh
+ : test/auth_push_test.dart: AuthRepository refresh gagal bila refresh token kosong
+ : test/auth_push_test.dart: AuthRepository refresh sukses mengembalikan access token baru
+ : test/auth_push_test.dart: AuthNotifier status login dibaca dari keberadaan access token
+ : test/auth_push_test.dart: AuthNotifier login menyimpan token dan menandai status login
+ : test/auth_push_test.dart: AuthNotifier login gagal tidak menyimpan token
+ : test/auth_push_test.dart: AuthNotifier logout membersihkan token dan memaksa login ulang
+ : All tests passed!
```

Catatan: sebelumnya `flutter analyze` tidak dapat dijalankan karena cache
Flutter SDK lokal kehilangan folder `dev/`, sehingga dipakai `dart analyze`.
Pada environment terbaru `flutter analyze` sudah berjalan normal dan dipakai
kembali sebagai perintah verifikasi utama (hasil di atas).

### 6.2 Uji perilaku FCM di perangkat fisik

Dijalankan di Infinix X6833B (Android 14) dengan pesan dikirim dari Firebase
Console → Messaging ke FCM registration token perangkat. Payload memakai
gabungan `notification + data {route, id}`.

| State | Handler | Hasil observasi | Bukti |
| :--- | :--- | :--- | :--- |
| Foreground | `onMessage` | Banner lokal manual muncul di dalam aplikasi | `screenshots/08-foreground.png` |
| Background | `onMessageOpenedApp` | Banner sistem di tray; ketukan meneruskan rute | `screenshots/09-background.png` |
| Terminated | `getInitialMessage` | Banner sistem; aplikasi dibuka dari nol | `screenshots/10-terminated.png` |

Temuan saat pengujian:

- **Kesalahan umum yang terbukti di lapangan:** `adb shell am force-stop`
  menandai aplikasi `stopped` sehingga Android memblokir FCM
  (`GCM: result=CANCELLED`). Uji terminated harus lewat recent-apps/`am kill`.
- **Custom data rawan salah ketik:** key `route ` (dengan spasi) membuat
  `routeFromMessage` gagal menemukan `data['route']` sehingga deep link jatuh ke
  beranda. Key harus persis `route`.
- `onTokenRefresh` terbukti benar-benar mengirim ulang token ke `POST /devices`
  saat tombol *Simulasikan rotasi token* ditekan (log aplikasi menampilkan
  `POST /devices fcm_token=<masked>`).

## 7. Keputusan teknis tambahan

- UI tidak pernah memanggil Firebase atau secure storage langsung; semua lewat
  provider dan `CampusNotifyApp` (main.dart).
- Token dikirim ke backend hanya lewat body HTTPS, tidak pernah di query URL.
- `pendingDeepLink` dipakai untuk menahan rute dari klik notifikasi yang tiba
  sebelum router siap.
- Sesi login ditentukan oleh keberadaan access token, bukan flag memori, agar
  bertahan setelah aplikasi ditutup.
