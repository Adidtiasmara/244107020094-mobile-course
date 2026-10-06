# week3_navigation

Project Flutter untuk **Praktikum 1 - Navigasi dengan GoRouter** (Minggu 3).

## Tujuan

Menunjukkan navigasi multi-halaman dengan `go_router`: path parameter `:id`,
`context.go` untuk berpindah, serta detail yang bisa dibuka langsung lewat URL.

## Fitur

- Halaman Home berisi 10 item.
- Menekan item membuka `/detail/:id` dengan path parameter.
- Path detail dapat diakses langsung tanpa melewati Home.

## Struktur

```text
lib/
├── main.dart              # GoRouter: route "/" dan "detail/:id"
└── pages/
    ├── home_page.dart     # Daftar 10 item
    └── detail_page.dart   # Detail berdasarkan id
```

## Menjalankan

```bash
flutter pub get
flutter run -d chrome    # atau -d linux / emulator
```

## Verifikasi

```bash
dart analyze   # No issues found!
flutter test   # 1 test lulus
```
