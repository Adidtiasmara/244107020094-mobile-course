# AI Challenge: Refactor ke Clean Architecture

Dokumen ini mencatat prompt yang dipakai, ringkasan output awal AI, tabel
usulan-vs-keputusan-final, dan alasan teknis tiap keputusan. Sesuai kebijakan AI
Minggu 7: AI boleh mengusulkan reorganisasi, tetapi keputusan akhir dan
justifikasinya milik mahasiswa.

## Prompt

```text
Project Flutter saya: week5_offline_notes (CRUD catatan SQLite + cache-first
posts + preferensi SharedPreferences, state dengan Riverpod).
Kondisi kini: folder lib/{data, pages, widgets}, repository tercampur dengan
implementasi, widget memanggil Dio/sqflite langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur notes + posts + settings.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

## Ringkasan Output Awal AI

AI mengusulkan struktur feature-first dengan tiga fitur (`notes`, `posts`,
`settings`), memindahkan `data/api_client.dart` dan `data/local/db.dart` menjadi
infrastruktur bersama, memecah repository menjadi interface (`domain`) +
implementasi (`data`), menambahkan `NoteModel`/`PostModel` untuk mapping, serta
membuat use case untuk setiap operasi. AI juga mengusulkan `Failure` untuk
semua repository, termasuk `SettingsRepository`.

## Tabel Usulan vs Keputusan Final

| # | Usulan AI | Keputusan Final | Alasan teknis |
| :---: | :--- | :--- | :--- |
| 1 | Feature-first `features/{notes,posts,settings}/{domain,data,presentation}` | **Diadopsi** | Satu fitur dapat dipahami/dihapus tanpa menyentuh fitur lain |
| 2 | `lib/core/failures.dart` untuk `Failure` | **Diadopsi** | Exception mentah dipetakan jadi pesan ramah sebelum UI |
| 3 | `lib/infra/` untuk Dio + SQLite | **Diadopsi, diubah nama** | `core` harus bebas framework (grep sterilitas #2), jadi pembungkus framework ditaruh di `infra/` |
| 4 | Use case untuk **setiap** operasi, termasuk preferensi | **Disederhanakan** | Use case per get/set preferensi = over-engineering; `SettingsRepository` dipakai langsung ke notifier |
| 5 | `Failure` untuk `SettingsRepository` | **Ditolak** | Nilai primitif tanpa aturan bisnis; membungkus tiap get/set dengan record sukses/gagal menambah noise tanpa manfaat |
| 6 | Use case `GetNotes`/`AddNote`/`DeleteNote`/`GetNote` tipis | **Diadopsi** | Presentasi bergantung pada operasi bisnis, bukan repository; memudahkan penambahan aturan nanti |
| 7 | Use case `SyncNotes` | **Diadopsi** | Punya logika nyata (hitung dirty → upload → tandai bersih), bukan sekadar meneruskan |
| 8 | `NoteModel`/`PostModel` extends entity + `toEntity()` | **Diadopsi** | Mapping hanya di `data`; domain tetap murni |
| 9 | Ekstrak `formatDateTime`/`parseNoteId` ke `core/format.dart` | **Diadopsi** | Fungsi murni, bisa diuji tanpa widget |
| 10 | `mapDioError` untuk memetakan `DioException` | **Diadopsi** | UI hanya menerima `message` yang ramah |

## Kapan Use Case Dibutuhkan (Keputusan Sendiri)

- **Butuh use case**: operasi menggabungkan >1 repository atau punya aturan
  bisnis. Contoh: `SyncNotes` (hitung dirty, simulasi upload, tandai bersih).
- **Repository langsung ke notifier cukup**: CRUD satu-baris tanpa aturan
  tambahan. Contoh: seluruh operasi `SettingsRepository` (get/set tema,
  markOpenedNow, getLastOpened).
- **Kompromi**: CRUD `notes` tetap dibungkus use case tipis agar presentation
  bergantung pada operasi bisnis, tetapi tidak ditambahi `Failure` buatan.

## Wiring DI (Riverpod, tanpa package tambahan)

```dart
// Data layer: implementasi konkret dirakit di sini.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// Domain layer: use case menerima abstraksi.
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

// Presentation layer: state untuk UI.
final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);
```

Widget tidak pernah memanggil `NoteRepositoryImpl(...)`; semua lewat provider.

## Hasil Verifikasi

Hasil tiga grep sterilitas dan `flutter analyze`/`flutter test` ada di
[`verifikasi-grep.md`](verifikasi-grep.md).
