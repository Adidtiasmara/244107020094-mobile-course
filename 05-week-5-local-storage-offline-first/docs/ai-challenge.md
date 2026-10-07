# AI Challenge - Week 5

Dokumen ini mencatat prompt, output awal AI, verifikasi terhadap checklist modul,
perbaikan yang dilakukan, keputusan final, dan hasil testing untuk bagian
**AI Prompt Challenge** pada praktikum Local Storage & Offline First.

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

AI assistant yang dipakai: opencode (model `inferhub/cb/deepseek-v4.1-flash`).

## 2. Output awal AI

### 2.1 Tabel perbandingan storage (versi awal AI)

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| Kompleksitas query | Tidak ada (key-value) | Rendah (box key-value) | Sedang (SQL manual) | Rendah (API type-safe) |
| Kebutuhan relasi | Tidak cocok | Terbatas | Kuat (JOIN, FK) | Kuat (FK + stream) |
| Reaktivitas (stream) | Tidak ada | `watch()` per box | Tidak ada (manual) | Ya, stream per query |
| Type-safety | Rendah | Sedang (adapter) | Rendah (String/Map) | Tinggi (generated) |
| Ukuran boilerplate | Sangat kecil | Kecil | Sedang | Besar (codegen) |
| Kemudahan testing | Mudah (mock store) | Sedang | Sedang (in-memory) | Mudah (in-memory) |
| **Rekomendasi AI** | Preferensi | Alternatif | **Catatan** | Alternatif besar |

Rekomendasi awal AI: **SharedPreferences untuk preferensi, sqflite untuk catatan.**

### 2.2 Skema tabel catatan 1000+ (versi awal AI)

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL
);
```

### 2.3 Kode CRUD awal AI (dipotong)

```dart
Future<List<Note>> fetchNotes() async {
  final db = await openNotesDb();
  final rows = await db.query('notes', orderBy: 'updated_at DESC');
  return rows.map(Note.fromMap).toList();
}
```

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada output awal | Tindakan |
| :--- | :--- | :--- |
| Apakah AI menempatkan daftar catatan di SharedPreferences? | Tidak. AI menaruh catatan di sqflite dan menolak SharedPreferences untuk koleksi | Aman, dipertahankan |
| Apakah skema mendukung antrean sync (dirty flag / updated_at)? | **Tidak.** Skema awal hanya punya `updated_at`, tanpa `dirty` | Ditambah kolom `dirty INTEGER NOT NULL DEFAULT 0` |
| Apakah klaim "real-time" didukung stream? | AI tidak mengklaim real-time untuk sqflite; reaktivitas diserahkan ke Riverpod | Aman. Reaktivitas ditangani `AsyncNotifierProvider` |
| Apakah estimasi boilerplate masuk akal? | Ya. `flutter pub add sqflite path` ringan; Drift butuh `build_runner` + codegen | Dipertahankan |
| Test menguji field hilang / repository palsu? | AI belum membuat test | Ditambah `test/note_test.dart` + `FakeNoteRepository` |

## 4. Perbaikan yang dilakukan

### 4.1 Dirty flag untuk antrean sinkronisasi

Skema awal AI tidak mendukung sync offline. Ditambahkan kolom `dirty` pada
tabel `notes` dan method `countDirty()` serta `markAllSynced()` pada
`NoteRepository`, lalu `syncNotes()` di `lib/data/sync.dart`.

### 4.2 Tabel cache untuk cache-first read

Modul meminta cache-first read untuk data API. AI belum menyiapkan tabel cache,
sehingga ditambahkan tabel `cached_posts(id, payload, cached_at)` dan helper
`readCachedPosts`/`writeCachedPosts`/`cachedPostsAt`.

### 4.3 Aturan konflik eksplisit

Modul mewajibkan aturan konflik. Dipilih **last-write-wins berdasarkan
`updated_at`**: catatan lokal selalu diurutkan `updated_at DESC`, dan saat sync
catatan yang lebih baru menang. Aturan ini didokumentasikan di README.

### 4.4 `openDb` disuntikkan untuk testing

Constructor `NoteRepository({Future<Database> Function()? openDb})` memungkinkan
test menyuntikkan `FakeNoteRepository` tanpa menyentuh SQLite sungguhan
(mengikuti contoh modul).

### 4.5 Dukungan web + sqflite FFI

Agar screenshot dapat diambil di browser (layout mobile), ditambahkan
conditional import `notes_database_factory_io.dart` / `_web.dart` dan
`sqflite_common_ffi_web`. Pada Android tetap memakai `sqflite` asli.

## 5. Keputusan final

| Kebutuhan | Pilihan | Alasan |
| :--- | :--- | :--- |
| Preferensi (tema, terakhir dibuka) | **SharedPreferences** | Nilai primitif kecil, tanpa query, API paling sederhana |
| Daftar catatan (1000+) | **sqflite (SQLite)** | Query terurut, update parsial, kolom `dirty` untuk antrean sync |
| Cache posts API | **sqflite** | Menyimpan payload JSON terindeks `id`, mudah di-invalidate |

Keputusan ini **sama** dengan rekomendasi awal AI (SharedPreferences +
sqflite), tetapi skema dan lapisan sync diperbaiki agar benar-benar
offline-first.

## 6. Hasil testing

Perintah dan hasil (dijalankan di dalam `week5_offline_notes/`):

```text
$ dart analyze
Analyzing week5_offline_notes...
No issues found!

$ flutter test
00:00 +0: test/note_test.dart: fromMap aman terhadap field yang hilang
00:00 +1: test/note_test.dart: flag dirty bertahan pada serialisasi
00:00 +2: test/widget_test.dart: NoteTile menampilkan badge belum tersinkron
00:00 +3: test/note_test.dart: provider sukses dengan repository palsu
00:00 +4: test/note_test.dart: provider error dengan repository palsu
00:00 +5: test/note_test.dart: countDirty menghitung catatan belum tersinkron
00:00 +6: test/widget_test.dart: NoteTile tidak menampilkan badge saat sinkron
00:00 +7: All tests passed!
```

Catatan: `flutter analyze` tidak dapat dijalankan di environment ini karena
cache Flutter SDK lokal kehilangan folder `dev/`. Sebagai gantinya dipakai
`dart analyze` pada package yang sama, yang menganalisis `lib/` dan `test/`
dengan rules `flutter_lints` yang sama.

## 7. Keputusan teknis

- UI tidak pernah memanggil SQLite/SharedPreferences langsung; semua lewat
  repository + provider.
- Daftar catatan tidak disimpan di SharedPreferences karena koleksi butuh query,
  update parsial, dan sinkronisasi yang tidak praktis pada key-value.
- `dirty` disimpan sebagai integer 0/1 agar cocok dengan tipe SQLite.
- `updated_at` disimpan sebagai ISO-8601 agar urutannya leksikografis sama
  dengan urutan waktu (aman untuk `ORDER BY`).
- Cache-first: UI menampilkan cache seketika, refresh jaringan berjalan di
  background dan tetap menampilkan cache bila refresh gagal.
