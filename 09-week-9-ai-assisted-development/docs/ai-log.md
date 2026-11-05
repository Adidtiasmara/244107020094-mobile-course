# AI Log — Minggu 9 (fitur pencarian judul catatan)

Fitur: **pencarian judul catatan + empty state** di aplikasi `07-week-7-clean-architecture`.
Dikerjakan dengan siklus: prompt → generate → **verify** → test → refactor → explain.
Assistant yang dipakai: GLM via ZCode CLI (peran setara Copilot/Cursor).

## 1. Prompt yang dikirim (format 5 slot)

```text
Peran: senior Flutter developer.

Konteks: aplikasi catatan offline-first, feature-first Clean Architecture
(presentation -> domain <- data), Riverpod (AsyncNotifier), GoRouter, SQLite.
Struktur fitur notes:
  lib/features/notes/
  ├── domain/{entities/note.dart, repositories/, usecases/}
  ├── data/{models/, repositories/}
  └── presentation/{providers/notes_providers.dart, pages/notes_page.dart, widgets/}
Entity Note: { int? id, String title, String body, DateTime updatedAt, bool dirty }
Halaman daftar: notes_page.dart (ConsumerStatefulWidget), state list di notesProvider.

Tugas: tambahkan pencarian judul catatan di halaman daftar + empty state saat
tidak ada hasil.

Batas: jangan rusak arsitektur, maksimal 80 baris, jangan tambah package baru,
tidak ada secret di dalam prompt (dipakai placeholder, tidak ada token/kredensial).

Output: kode + 3 test case + cara menguji manual.
```

Konteks di atas dipotret dari struktur repo; tidak ada file penuh atau token yang
ditempel ke AI.

## 2. Output mentah AI (apa adanya, sebelum diedit — commit `1436242`)

```dart
/// Filter catatan berdasarkan kata kunci pada judul.
List<Note> filterNotes(List<Note> notes, String query) {
  if (query.isEmpty) return notes;
  return notes.where((note) => note.title.contains(query)).toList();
}
```

Ditambah pada `notes_page.dart`: state lokal `String _query = ''`, `TextField`
dengan `onChanged: (value) => setState(() => _query = value)`, cabang data memanggil
`filterNotes(items, _query)`, dan empty state:

```dart
final results = filterNotes(items, _query);
if (results.isEmpty) {
  return Center(
    child: Text('Catatan dengan judul "$_query" tidak ditemukan.'),
  );
}
```

Tiga test yang dijanjikan output (`test/search_filter_test.dart`): menyaring kata
kunci persis, query kosong → semua, tanpa hasil → kosong. Ketiganya hijau, tetapi
tidak ada test kasus huruf besar/kecil (lihat temuan di bawah).

## 3. Verifikasi (6 langkah codelab)

| Langkah | Hasil |
|---|---|
| Baca setiap baris | `filterNotes` paham; TextField tanpa controller (belum bisa dibersihkan programatik); logika filter hidup di `presentation` — mencurigakan |
| Cek import lintas layer | Grep sterilitas #1 & #2 tetap nol (filter tidak menyentuh Dio/SQLite), tapi logika bisnis di presentation = pelanggaran arah, di-refactor di langkah berikut |
| Kecocokan API | Semua API dipakai ada (`String.contains`, `where`, `toList`) — tidak ada method fiktif |
| `flutter analyze` | 0 issue |
| Test tambahan | 1 test lolos (query kosong) + 1 test **GAGAL**: "filterNotes mengabaikan huruf besar/kecil" |
| Uji manual | Query "BELAJAR" di emulator tidak menemukan judul "Belajar Flutter" (bukti: `screenshots/`, langkah manual di README) |

## 4. Bug/halusinasi yang ditemukan + pola red test

**Temuan:** filter **case-sensitive**. Query `belajar` (huruf kecil) mengembalikan
0 hasil padahal ada judul `Belajar Flutter` dan `Belajar Riverpod`.

**Red test** (`test/search_filter_test.dart`):

```dart
test('filterNotes mengabaikan huruf besar/kecil', () {
  final results = filterNotes(sample(), 'belajar');
  expect(results, hasLength(2));
});
```

Bukti gagal (output asli, tersimpan di `screenshots/terminal-red-test.txt`):

```
00:00 +3 -1: filterNotes mengabaikan huruf besar/kecil [E]
  Expected: an object with length of <2>
    Actual: []
     Which: has length of <0>
```

**Akar masalah:** output AI memakai `title.contains(query)` tanpa normalisasi —
AI mengasumsikan input pengguna sudah sesuai kapitalisasi judul. **Perbaikan kecil**
(commit `5310c73`): `query.toLowerCase()` + `title.toLowerCase()` sebelum
`contains`. Test kembali hijau (19/19).

## 5. Refactor ke layer yang benar (commit `c53ea06`)

Logika pencarian dipindah dari presentation ke use case murni:

- `lib/features/notes/domain/usecases/search_notes.dart` — `SearchNotes.call({notes, query})`,
  murni Dart, tanpa import Flutter → bisa diuji tanpa UI (grep sterilitas domain tetap nol).
- `notes_providers.dart` — `NoteQueryNotifier` (query sebagai state Riverpod) +
  `searchNotesProvider`; halaman hanya meng-watch dan menampilkan.
- Halaman kehilangan state `_query`; `TextField` kini pakai controller yang
  di-dispose di `State.dispose()` (pelajaran dari bug dialog Minggu 8).
- Tambahan widget test: empty state pencarian + tombol "Hapus pencarian" (20/20).

## 6. AI Prompt Challenge (review kode search)

Prompt baku modul dijalankan pada kode final; 3 temuan + keputusan tercatat di
[`docs/ai-review-vs-keputusan.md`](ai-review-vs-keputusan.md). Satu temuan
(query spasi saja diperlakukan sebagai pencarian) **terbukti benar** via red test
kedua dan diperbaiki (commit `8e84e14`, 21/21 hijau); dua temuan lain ditolak
dengan alasan teknis.

## 7. Rangkuman keputusan per file

| File | Keputusan |
|---|---|
| `domain/usecases/search_notes.dart` | diterima + refactor: versi domain murni, trim + lowercase |
| `presentation/providers/notes_providers.dart` | diterima: query jadi provider, wiring use case di sini |
| `presentation/pages/notes_page.dart` | diterima + refactor: buang filter lokal, pakai use case; controller dikelola benar |
| `test/search_filter_test.dart` | diterima: 5 test (4 unit + 1 widget), termasuk 2 yang awalnya merah |
