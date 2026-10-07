# Pemrograman Mobile — JTI Polinema

Dokumentasi praktikum mingguan mata kuliah Pemrograman Mobile, Jurusan Teknologi
Informasi, Politeknik Negeri Malang. Semua proyek dikerjakan dengan Flutter SDK
dan bahasa Dart.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Progress](https://img.shields.io/badge/progres-minggu%201--4%20dari%2016-informational)]()

## Identitas

| | |
|---|---|
| Nama | Muhammad Firman Aditiasmara |
| Program Studi | D4 Teknik Informatika |
| Jurusan | Teknologi Informasi |
| Institusi | Politeknik Negeri Malang |

## Progres Modul

| Minggu | Topik | Status | Direktori |
| :---: | :--- | :---: | :--- |
| 01 | Mobile Development Ecosystem & Flutter Refresh | Selesai | [`01-...`](./01-week-1-mobile-development-ecosystem-flutter-refresh/) |
| 02 | Declarative UI & Responsive Design | Selesai | [`02-...`](./02-week-2-declarative-ui-responsive-design/) |
| 03 | Navigation & State Management (Riverpod) | Selesai | [`03-...`](./03-week-3-navigation-state-management/) |
| 04 | Networking & REST API | Selesai | [`04-...`](./04-week-4-networking-rest-api/) |
| 05 | Local Storage & Offline-First | Belum mulai | [`05-...`](./05-week-5-local-storage-offline-first/) |
| 06 | Authentication, Security & FCM | Belum mulai | [`06-...`](./06-week-6-authentication-security-fcm/) |
| 07 | Clean Architecture | Belum mulai | [`07-...`](./07-week-7-clean-architecture/) |
| 08 | Mid Project Review & Code Review | Belum mulai | [`08-...`](./08-week-8-mid-project-review/) |
| 09 | AI-assisted Development / Vibe Coding | Belum mulai | [`09-...`](./09-week-9-ai-assisted-development/) |
| 10 | AI Feature Integration | Belum mulai | [`10-...`](./10-week-10-ai-feature-integration/) |
| 11 | Performance Optimization | Belum mulai | [`11-...`](./11-week-11-performance-optimization/) |
| 12 | Testing & Quality Assurance | Belum mulai | [`12-...`](./12-week-12-testing-quality-assurance/) |
| 13 | CI/CD & Automation | Belum mulai | [`13-...`](./13-week-13-ci-cd-automation/) |
| 14 | Deployment & Monitoring | Belum mulai | [`14-...`](./14-week-14-deployment-monitoring/) |
| 15 | Secure Mobile Development | Belum mulai | [`15-...`](./15-week-15-secure-mobile-development/) |
| 16 | Final Project Expo | Belum mulai | [`16-...`](./16-week-16-final-project-expo/) |

## Minggu yang Sudah Selesai

### Minggu 1 — Ekosistem Mobile & Flutter Refresh
- `flutter doctor` bersih untuk target Android dan `flutter devices` mendeteksi
  emulator/perangkat.
- Latihan mandiri: fungsi `hitungLuasPersegiPanjang`, kelas `Profil` dengan
  penanganan email kosong.
- Mini assignment: aplikasi profil mahasiswa dengan NIM dan satu informasi
  tambahan memakai widget dasar.
- Catatan: perbedaan hot reload dan hot restart.

Detail: [`01-.../README.md`](./01-week-1-mobile-development-ecosystem-flutter-refresh/README.md)

### Minggu 2 — Declarative UI & Responsive Design
- Halaman Academic Overview: header profil dan empat kartu informasi
  (Assignments, Attendance, GPA, Current Week).
- Layout responsif dengan `LayoutBuilder`: satu kolom di layar sempit, dua kolom
  di layar lebar.
- Light/dark theme lewat `CupertinoSwitch`, dilengkapi label `Semantics`.
- Widget test untuk tampilan responsif.

Detail: [`02-.../README.md`](./02-week-2-declarative-ui-responsive-design/README.md)

### Minggu 3 — Navigation & State Management
- Navigasi multi-halaman dengan GoRouter: `/`, `/produk`, `/stats`, dan rute
  detail dengan path parameter.
- State management Riverpod: `Notifier` untuk daftar tugas, provider turunan
  untuk filter (Semua, Aktif, Selesai).
- Penanganan `AsyncValue` untuk kondisi loading, error (tombol Coba lagi),
  success, dan empty.
- Enam test lulus dan `dart analyze` bersih.

Detail: [`03-.../README.md`](./03-week-3-navigation-state-management/README.md)

### Minggu 4 — Networking & REST API
- Klien HTTP terpusat `dio` (base URL, timeout 10 detik, interceptor) dan model
  `Post`/`Comment` dengan `fromJson` aman null.
- Repository pattern: UI hanya membaca provider, tidak pernah memanggil Dio
  langsung.
- Empat state UI: loading, error (+ tombol Coba lagi), empty, dan success.
- Pagination infinite scroll 10 item per halaman dengan guard request ganda.
- Halaman detail `/post/:id` dengan GoRouter dan daftar komentar.
- `dart analyze` bersih dan 10 test lulus (unit, provider palsu, widget).

Detail: [`04-.../README.md`](./04-week-4-networking-rest-api/README.md)

## Cara Menjalankan

1. Cek kesiapan environment:
   ```bash
   flutter doctor
2. Masuk ke direktori proyek minggu yang dituju (contoh minggu 3):
cd 03-week-3-navigation-state-management/week3_todo
3. Pasang dependensi lalu jalankan:
flutter pub get
flutter run
Referensi
- Modul Praktikum: Codelabs Pemrograman Mobile JTI Polinema (https://jti-polinema.github.io/flutter-codelab/)
- Dokumentasi Flutter (https://docs.flutter.dev/) · Panduan Dart (https://dart.dev/guides) · Riverpod (https://riverpod.dev/docs)

---
