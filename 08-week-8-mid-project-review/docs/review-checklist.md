# Review Checklist — Minggu 8

## 1. Audit riwayat Git

Hasil `git log --oneline`, `git branch -a`, `git status` (sebelum Minggu 8):

- 33 commit, **semua langsung ke `main`**, tidak pernah ada branch lain.
- Ada merge commit `Merge branch 'main' of github.com:...` dua kali — tanda lupa
  `git pull` sebelum push (bukan hasil PR).
- Sebagian besar pesan commit belum memakai format conventional.

### Tabel perbaikan pesan commit (before → after)

| Before | After (usulan) | Alasan |
|--------|----------------|--------|
| `upd: week 3,5,6 update readme dan stuktur repository` | `docs: perbarui README dan struktur repo minggu 3, 5, 6` | `upd` bukan tipe konvensional, ada typo `stuktur`, dan satu commit mencampur README + struktur. |
| `screenshot update and modified week 5` | `docs(week5): perbarui screenshot` | Tanpa tipe, deskripsi kabur ("update and modified"), tidak bisa di-revert per logika. |
| `ignore update` | `chore: perbarui .gitignore folder minggu 3` | Tidak menjelaskan apa yang di-ignore/diubah; reviewer harus buka diff untuk tahu isinya. |

Pesan yang sudah benar sejak awal (dipertahankan sebagai contoh):
`feat: create week 1 Flutter profile app`, `feat(week5): CRUD, preferensi, dan offline-first`.

## 2. Kesiapan tengah semester

Struktur proyek yang direview: `07-week-7-clean-architecture/` (refactor
`week5_offline_notes` dari Minggu 7).

| Aspek | Status | Bukti |
|-------|--------|-------|
| Struktur feature-first (domain/data/presentation) | ✅ | `lib/features/{notes,posts,settings}`, `lib/core`, `lib/infra` |
| Grep sterilitas #1 — presentation bebas Dio/SQLite/Prefs | ✅ nol hasil | `grep -rn -E "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation` → 0 |
| Grep sterilitas #2 — domain bebas import framework | ✅ nol hasil | `grep -rn -E "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase" lib/features/*/domain lib/core` → 0 |
| `flutter analyze` | ✅ 0 issue | `screenshots/terminal-analyze-format-test.txt` |
| `dart format --set-exit-if-changed .` | ✅ bersih (36 file) | file yang sama |
| `flutter test` | ✅ 15/15 (10 lama + 5 baru) | file yang sama |
| Repo bisa di-build dari clone baru | ✅ sejak PR-1 | `pubspec.yaml` + `analysis_options.yaml` ter-commit (sebelumnya di-ignore `.gitignore`) |
| README, cara jalan, screenshot | ✅ | README per minggu + folder `screenshots/` |
| PR kecil (< 300 baris) + commit konvensional | ✅ | 3 PR Minggu 8, masing-masing satu tujuan |

Yang dinilai di titik ini bukan jumlah fitur, tapi fondasi paruh kedua: dependency rule
masih terjaga setelah ada perubahan, semua gate mesin hijau, dan alur kerja sudah lewat
issue → branch → PR → review.

## 3. Checklist peer review (untuk reviewer)

Sebelum me-review, wajib checkout branch-nya, `flutter pub get`, `flutter test`, dan
jalankan aplikasinya dulu. Review tanpa menjalankan tidak sah.

Minimal yang harus dihasilkan reviewer:

- [ ] **2 temuan kebenaran** — cek: null safety (`note.id!` di `notes_page.dart`),
      state AsyncValue, jalur error sync (`SyncNotes`), edge case judul spasi.
- [ ] **1 temuan arsitektur** — cek: tidak ada import lintas layer, tidak ada
      repository yang dibuat manual di widget, entity bebas mapping.
- [ ] **1 temuan test** — cek: kasus sukses + gagal, apakah fake menutup perilaku nyata.
- [ ] **1 saran keterbacaan** (opsional diterapkan).
- [ ] Keputusan akhir: **Approve** atau **Request changes** dengan komentar
      pola: observasi → dampak → usulan konkret.

## 4. Refactoring challenge Minggu 8

- [x] Semua komentar *request changes* diterapkan sampai approve (lihat
      `ai-review-vs-keputusan.md`: temuan #1–#3 diperbaiki, #4–#5 ditolak beralasan).
- [x] Temuan gaya yang berulang dipindah ke otomatisasi: `dart format` + CI
      (`.github/workflows/ci.yml`) di PR-3.
- [x] Pekerjaan tetap dipecah PR kecil (3 PR, masing-masing < 300 baris berarti).
