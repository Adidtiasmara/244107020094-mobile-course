# Verifikasi Dependency Rule (Grep Sterilitas)

Tanggal: 15 Oktober 2026. Dijalankan di dalam folder `07-week-7-clean-architecture/`.

Tujuan: membuktikan bahwa dependensi hanya mengarah ke dalam
(`presentation → domain ← data`) dan lapisan dalam bebas dari framework.

## 1. Presentation steril dari data mentah (harus NOL hasil)

```bash
rg "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation
```

Hasil: **nol hasil**. Tidak ada widget/provider yang menyentuh jaringan, database,
atau secure storage secara langsung.

## 2. Domain & core steril dari framework (harus NOL hasil)

```bash
rg "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase" lib/features/*/domain lib/core
```

Hasil: **nol hasil**. Entity, kontrak repository, use case, dan `Failure` murni
Dart sehingga dapat diuji tanpa framework.

## 3. Instansiasi manual / DI bocor (harus NOL hasil)

```bash
rg "Repository\(|Dio\(BaseOptions" lib/features/*/presentation
```

Hasil: **nol hasil**. Widget tidak pernah membuat repository sendiri; semua
wiring ada di provider (`notes_providers.dart`, `posts_providers.dart`,
`settings_providers.dart`).

## 4. Static analysis + test

```bash
flutter analyze
flutter test
```

Hasil:

```text
Analyzing 07-week-7-clean-architecture...
No issues found! (ran in 3.1s)

00:01 +10: All tests passed!
```

## Kesimpulan

| Pemeriksaan | Hasil |
| :--- | :---: |
| Presentation steril dari data mentah | NOL hasil |
| Domain & core steril dari framework | NOL hasil |
| Instansiasi manual di presentation | NOL hasil |
| `flutter analyze` | Bersih |
| `flutter test` | 10 lulus |
