# AI Challenge - Week 3

Dokumen ini mencatat prompt, output awal AI, verifikasi, perbaikan, dan hasil
testing untuk bagian **AI Challenge** pada praktikum Navigation & State
Management.

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

AI assistant yang dipakai: opencode (model `inferhub/cb/deepseek-v4.1-flash`).

## 2. Output awal AI

`lib/providers/stats_provider.dart` (versi awal):

```dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    await Future.delayed(const Duration(seconds: 2));
    if (Random().nextDouble() < 0.3) {
      throw Exception('Gagal terhubung ke server');
    }
    return ['Total tugas: 0', 'Selesai: 0', 'Belum selesai: 0'];
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);
```

`lib/pages/stats_page.dart` (versi awal):

```dart
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    return Scaffold(
      body: statsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, s) => Text('Error: $e'),
        data: (stats) => ListView(
          children: [for (final s in stats) Text(s)],
        ),
      ),
    );
  }
}
```

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada output awal | Tindakan |
| :--- | :--- | :--- |
| State diubah immutable (tidak ada `state.add`/mutasi list) | Belum ada mutasi, tetapi belum ada method untuk mengubah state | Aman, ditambah `refresh()` yang selalu mengganti state baru |
| `ref.watch` hanya di `build`, `ref.read` di callback | Sudah benar | Dipertahankan |
| Ketiga state AsyncValue ditangani | Loading dan error ada, tetapi error hanya teks tanpa tombol retry | Ditambah pesan + tombol **Coba lagi** |
| Provider bertipe eksplisit, tidak duplikat | Sudah eksplisit | Dipertahankan |
| Tidak memakai API Riverpod lama (`StateProvider`, `StateNotifierProvider`, `Consumer` bertingkat) | AI sempat mengusulkan `StateProvider` untuk filter todo | Diganti `NotifierProvider` |
| `flutter analyze` dan `flutter test` lolos | Ada `prefer_initializing_formals`, dan unit test error menggantung | Diperbaiki (lihat bagian 4) |

## 4. Perbaikan yang dilakukan

### 4.1 Random tidak bisa di-inject (unit test tidak deterministik)

Output awal memanggil `Random()` langsung di dalam `build()`, sehingga unit
test tidak bisa memaksa sukses atau gagal. Perbaikan: `Random`, `delay`, dan
`failureRate` dijadikan parameter konstruktor, lalu di-override di test:

```dart
statsProvider.overrideWith(
  () => StatsNotifier(random: Random(0), delay: Duration.zero, failureRate: 0),
);
```

### 4.2 Error state menggantung karena Riverpod 3 auto-retry

Riverpod 3 otomatis mengulang provider yang gagal (exponential backoff).
Akibatnya unit test yang mengharapkan `AsyncError` menunggu 30 detik lalu
timeout, dan di aplikasi halaman error tidak bertahan. Perbaikan: retry
dinonaktifkan agar retry tetap manual lewat tombol:

```dart
ProviderScope(
  retry: (retryCount, error) => null,
  child: const MyApp(),
)
```

### 4.3 State loading/error/success lebih lengkap

- `refresh()` memakai `AsyncValue.guard` supaya exception otomatis menjadi
  `AsyncError`, bukan `try/catch` manual.
- Error state diberi tombol **Coba lagi** yang memanggil `ref.invalidate`.
- Data statistik dihitung dari `todoListProvider`, bukan angka `0` hardcoded,
  supaya tidak menampilkan data palsu.

### 4.4 Model `Stats` dan UI statistik

Output awal mengembalikan `List<String>` berisi teks siap tampil, sehingga
angka dan label tercampur di provider. Perbaikan: provider mengembalikan model
`Stats` (`total`, `done`, `remaining`, `completion`, `percent`) dan UI yang
memformat tampilannya. Unit test jadi bisa memeriksa angka, bukan string.

UI dirombak agar terasa sengaja dirancang, bukan template:

- Satu titik fokus: cincin progres persentase selesai (`CustomPainter`) yang
  beranimasi sekali saat data siap, lalu tiga baris angka pendukung.
- Warna tetap dari tema teal aplikasi (tidak ada identitas baru), aksen teal
  hanya di cincin dan ikon.
- Tanpa gradient, glow, glassmorphism, atau badge dekoratif. Satu elevasi
  (shadow) hanya pada panel ringkasan.
- Setiap keadaan punya pesan dan aksi: loading berlabel, error + retry,
  empty + tombol menuju daftar tugas.
- Kontras palet diverifikasi: `onSurfaceVariant` 9.09:1, `primary` 6.35:1,
  `onSurface` 16.76:1, ikon di chip 7.21:1.

### 4.5 Lint `prefer_initializing_formals`

Field privat tidak bisa dipakai sebagai named initializing formal, jadi field
`delay` dan `failureRate` dibuat publik dan diisi lewat `this.delay` /
`this.failureRate`.

### 4.6 Bug index pada daftar terfilter (bukan dari AI, ditemukan saat integrasi)

Notifier todo dari modul memakai `toggle(index)` / `remove(index)`. Setelah
daftar difilter, index pada daftar tampil berbeda dari index pada state asli,
sehingga item yang salah bisa terhapus. Perbaikan: method menerima objek
`Todo` dan mencocokkan dengan `identical`, bukan index.

## 5. Hasil testing

Perintah dan hasil (dijalankan di dalam `week3_todo/`):

```text
$ dart analyze
No issues found!

$ flutter test
00:00 +0: add, toggle, dan remove menghasilkan state baru
00:00 +1: filteredTodosProvider mengikuti filter
00:00 +2: statistik sukses menghitung total, selesai, dan sisa
00:00 +3: statistik gagal memunculkan AsyncError
00:00 +4: menambah tugas baru
00:01 +5: berpindah ke halaman statistik lewat GoRouter
00:02 +6: All tests passed!
```

Unit test `stats_provider_test.dart` menguji `StatsNotifier` secara langsung,
sehingga halaman statistik (AI Challenge) terverifikasi tanpa membangun UI.
Widget test di `widget_test.dart` ikut membangun halaman lewat GoRouter dan
memastikan baris "Total tugas" dan "Belum selesai" tampil.

Tampilan halaman juga dirender sebagai golden image saat pengerjaan untuk
memeriksa hasil visual (font dan ikon asli di-load), lalu file preview
sementara dihapus setelah diperiksa.

Catatan: `flutter analyze` tidak bisa dijalankan di environment ini karena
cache Flutter SDK lokal kehilangan folder `dev/`
(`PathNotFoundException: .../.cache/flutter_sdk/dev/`). Sebagai gantinya
dipakai `dart analyze` pada package yang sama, yang menganalisis `lib/` dan
`test/` dengan rules `flutter_lints` yang sama dan menghasilkan
`No issues found!`.

## 6. Keputusan teknis

- Memakai `AsyncNotifier` + `AsyncValue` (bukan tiga boolean) supaya loading,
  error, dan data tidak bisa berada di kondisi saling bertentangan.
- Menonaktifkan auto-retry agar perilaku UI dapat diprediksi dan sesuai
  instruksi modul (retry manual).
- Statistik dihitung dari state todo yang sebenarnya, sehingga halaman tidak
  menampilkan angka fiktif.
- Provider mengembalikan model `Stats`, bukan `List<String>`, agar angka dan
  presentasi terpisah dan dapat diuji.
- Operasi todo berbasis objek (bukan index) agar tetap benar saat filter aktif.
- Keputusan visual mengikuti filter anti-AI-slop: warna dari identitas teal
  aplikasi, satu aksen, satu elevasi, ikon relevan, tanpa emoji/gradient/glow,
  dan kontras yang sudah dihitung.
