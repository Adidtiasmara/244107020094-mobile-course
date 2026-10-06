# week3_todo

Project Flutter untuk **Praktikum 2 & 3 - State Management dengan Riverpod**
dan **AI Challenge** (Minggu 3).

## Tujuan

Menerapkan state management Riverpod (`Notifier`, `ConsumerWidget`) pada
aplikasi ToDo, menangani state asinkron dengan `AsyncValue`, lalu
mengintegrasikannya dengan navigasi GoRouter.

## Fitur

- Daftar tugas: tambah, tandai selesai, hapus (`Notifier`).
- Filter tugas: Semua, Aktif, Selesai (provider turunan).
- Halaman Produk: simulasi `AsyncValue` (loading, error + retry, success).
- Halaman Statistik (AI Challenge): cincin persentase selesai + tiga baris
  angka (Total, Selesai, Belum selesai), dengan loading, error + retry, dan
  empty state. Data dihitung dari daftar tugas sungguhan.
- Navigasi `NavigationBar` lewat GoRouter (`/`, `/produk`, `/stats`).

## Struktur

```text
lib/
├── main.dart                     # ProviderScope + GoRouter + NavigationBar
├── pages/
│   ├── todo_page.dart            # Daftar tugas + filter + dialog tambah
│   ├── product_page.dart         # AsyncValue produk
│   └── stats_page.dart           # AI Challenge: cincin progres + 3 state
├── providers/
│   ├── todo_provider.dart        # Todo, Notifier, filter, provider turunan
│   ├── products_provider.dart    # AsyncNotifier produk
│   └── stats_provider.dart       # AsyncNotifier Stats (delay 2s, gagal 30%)
└── widgets/
    └── todo_tile.dart            # Baris tugas
```

## Menjalankan

```bash
flutter pub get
flutter run -d chrome    # atau -d linux / emulator
```

Aplikasi membuka halaman **Tugas** lebih dulu. Tab **Tugas**, **Produk**, dan
**Statistik** tersedia di `NavigationBar` bawah. Tambah tugas di tab Tugas,
lalu buka tab Statistik agar angkanya terisi.

## Testing

```bash
dart analyze   # No issues found!
flutter test   # 6 test lulus
```

Prompt, output awal AI, perbaikan, dan keputusan teknis ada di
`../docs/ai-challenge.md`.
