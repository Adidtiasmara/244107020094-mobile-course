# Minggu 9 — AI-Assisted Development / Vibe Coding

## Fitur yang dibuat dengan AI

**Pencarian judul catatan + empty state** di proyek `07-week-7-clean-architecture/`:

- Kotak cari di halaman daftar; hasil terfilter langsung saat mengetik.
- Tidak peka huruf besar/kecil (`belajar` menemukan `Belajar Flutter`).
- Query kosong/spasi = tanpa kata kunci (semua catatan tampil).
- Empty state: "Tidak ada catatan dengan judul `<query>`." + tombol **Hapus pencarian**.
- Aturan pencarian hidup di use case `SearchNotes` (domain, murni Dart), bukan di widget.

## Siklus yang dijalankan

prompt → generate → **verify** → test → refactor → explain (ringkasan):

1. **Prompt 5 slot** (Peran, Konteks, Tugas, Batas, Output) — teks lengkap di
   [`docs/ai-log.md`](docs/ai-log.md).
2. **Generate** — output mentah AI disimpan apa adanya (`docs/ai-log.md` §2,
   commit `1436242`): `filterNotes` di presentation, case-sensitive.
3. **Verify** — 6 langkah codelab; ketemu **bug case-sensitive**, dibuktikan
   dengan red test (`screenshots/terminal-red-test.txt`), diperbaiki (`5310c73`).
4. **Test** — 4 unit test `SearchNotes` + 1 widget test empty state.
5. **Refactor** — logika pindah ke `domain/usecases/search_notes.dart`,
   query jadi provider Riverpod (`c53ea06`).
6. **Explain** — semua keputusan tercatat dan bisa dijelaskan tanpa membuka AI
   (`docs/ai-log.md` §7 + [`docs/ai-review-vs-keputusan.md`](docs/ai-review-vs-keputusan.md)).

**AI Prompt Challenge:** 3 temuan dari prompt baku modul → 1 terima (query spasi,
bukti red test kedua, fix `8e84e14`), 2 tolak dengan alasan (debounce =
over-engineering; pencarian body = scope creep).

## Teknologi

Flutter, Dart, flutter_riverpod (Notifier + provider turunan), flutter_test,
Clean Architecture feature-first (tetapan dari Minggu 7). Tanpa package baru.

## Cara menjalankan

```bash
git clone https://github.com/Adidtiasmara/244107020094-mobile-course.git
cd 244107020094-mobile-course/07-week-7-clean-architecture
flutter pub get
flutter create . --platforms=android,windows   # sekali saja
flutter run
```

Uji manual tiga query (langkah + screenshot yang diambil): lihat
[`screenshots/daftar-screenshot-manual.md`](screenshots/daftar-screenshot-manual.md).

## Hasil

```
$ flutter analyze
No issues found!

$ dart format --output=none --set-exit-if-changed .
All 22 files already formatted.

$ flutter test
00:03 +21: All tests passed!
```

Grep sterilitas domain tetap nol hasil. Output lengkap:
[`screenshots/terminal-analyze-format-test.txt`](screenshots/terminal-analyze-format-test.txt).

## Peta commit

| Commit | Isi |
|---|---|
| `1436242` | draf output AI apa adanya (filter di presentation, case-sensitive) |
| `5310c73` | fix bug case-sensitive (red → green) |
| `c53ea06` | refactor: `SearchNotes` di domain + query provider + widget test |
| `8e84e14` | fix query spasi (temuan prompt challenge yang diterima) |

## Daftar isi folder

- `docs/ai-log.md` — prompt, output mentah, verifikasi 6 langkah, bug + red test, refactor.
- `docs/ai-review-vs-keputusan.md` — tabel 3 temuan AI vs keputusan + bukti.
- `docs/panduan-pr.md` — draft PR Minggu 9 dan urutan merge.
- `screenshots/` — bukti gate mesin + panduan screenshot manual.
