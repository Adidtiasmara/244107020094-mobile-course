# Minggu 8 — Mid Project Review & Code Review

## Status tengah semester

Minggu 1–7 selesai (lihat tabel progres di README utama). Fondasi yang dibawa ke paruh
kedua: proyek `07-week-7-clean-architecture/` (refactor `week5_offline_notes` menjadi
feature-first clean architecture) kini bisa di-build dari clone baru, lewat alur
issue → branch → PR → review untuk pertama kalinya, dan punya CI.

Minggu 8 **tidak membuat aplikasi baru** — isinya mereview dan merapikan proyek tersebut.

## Peta issue dan PR

| # | Judul | Branch | Commit utama | Status |
|---|-------|--------|--------------|--------|
| Issue 1 | Menekan Simpan dengan judul kosong tidak memberi umpan balik | — | — | ditutup oleh PR-2 |
| PR-1 | `chore: tambah pubspec dan analysis_options project minggu 7` | `feature/build-scaffold` | 83c5bc7 | menunggu review |
| PR-2 | `feat(notes): validasi judul kosong + test` | `feature/notes-title-validation` | 89b92e6, 9acc5d8, d2b64b2 | menunggu review |
| PR-3 | `chore: rapikan format dan tambah CI untuk analyze, format, dan test` | `feature/ci-github-actions` | 39cbde2 | menunggu review |

Semua PR memakai template (Masalah / Solusi / Cara uji / Screenshot), target merge ke
`develop`, dan masing-masing kecil (< 300 baris perubahan berarti).

Isi draft issue & PR bisa dilihat di `docs/panduan-push-github.md`.

## Temuan review utama

Ringkasan hasil review (AI + verifikasi mandiri), detail lengkap di
[`docs/ai-review-vs-keputusan.md`](docs/ai-review-vs-keputusan.md):

1. **Blocker** — hasil `AddNote` dibuang begitu saja; kegagalan simpan tidak pernah
   terlihat user → diperbaiki (SnackBar gagal simpan).
2. **Blocker** — controller dialog dipakai setelah di-dispose saat animasi tutup →
   diperbaiki (dialog jadi `_AddNoteDialog` StatefulWidget), ketahuan dari widget test.
3. Assertion test menguji hardcode fake → diperbaiki.
4–5. Dua saran lain **ditolak dengan alasan teknis** (validasi domain bukan duplikasi UI;
   ekstraksi konstanta = abstraksi prematur).

## Fitur yang disentuh minggu ini

- Validasi judul kosong pada use case `AddNote` (domain) + umpan balik error di dialog.
- Notifikasi gagal simpan (SnackBar) di halaman catatan.
- Widget test dialog tambah catatan (error state + happy path).
- `pubspec.yaml`, `analysis_options.yaml`, PR template, dan GitHub Actions CI
  (analyze + format + test per pull request).

## Teknologi

Flutter, Dart, flutter_riverpod, go_router, sqflite, dio, shared_preferences,
flutter_test, GitHub Actions.

## Cara menjalankan

```bash
git clone https://github.com/Adidtiasmara/244107020094-mobile-course.git
cd 244107020094-mobile-course/07-week-7-clean-architecture
flutter pub get
flutter create . --platforms=android,windows   # sekali saja, folder platform tidak di-commit
flutter run
```

## Hasil

```
$ flutter analyze
No issues found!

$ dart format --output=none --set-exit-if-changed .
All 36 files already formatted.

$ flutter test
00:04 +15: All tests passed!
```

Grep sterilitas Minggu 7 tetap nol hasil (cek ulang di
[`docs/review-checklist.md`](docs/review-checklist.md)). Output lengkap:
[`screenshots/terminal-analyze-format-test.txt`](screenshots/terminal-analyze-format-test.txt).

## Daftar isi folder

- `docs/review-checklist.md` — audit riwayat commit, asesmen kesiapan tengah semester, checklist peer review.
- `docs/ai-review-vs-keputusan.md` — prompt, tabel temuan AI vs keputusan + bukti.
- `docs/panduan-push-github.md` — langkah push, buka issue/PR, dan merge.
- `screenshots/` — bukti gate mesin + daftar screenshot tambahan.
