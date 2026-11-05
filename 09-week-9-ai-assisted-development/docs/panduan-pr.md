# Panduan PR Minggu 9

## Urutan penting

PR Minggu 9 **dibuka setelah PR Minggu 8 (#2–#5) selesai di-merge**, supaya diff-nya
bersih (hanya berisi perubahan pencarian, bukan ikut membawa perubahan Minggu 8).
Branch `feature/notes-search` sudah dibangun di atas seluruh pekerjaan Minggu 8.

## Setelah Minggu 8 merge

```bash
git checkout develop
git pull origin develop
git checkout feature/notes-search
git rebase develop   # opsional, untuk riwayat linear
git push origin feature/notes-search
```

Lalu buka PR: base `develop` ← compare `feature/notes-search`, dengan isi:

```markdown
## Masalah
Tidak ada cara mencari catatan selain scroll manual; daftar bisa panjang
(offline-first sejak Minggu 5).

## Solusi
- Pencarian judul catatan dengan use case `SearchNotes` (domain, murni Dart,
  tidak peka huruf besar/kecil, query spasi = tanpa kata kunci).
- Query sebagai provider Riverpod (`noteQueryProvider`); halaman hanya
  menampilkan hasil — aturan pencarian tidak ada di widget.
- Empty state "Tidak ada catatan dengan judul `<query>`" + tombol Hapus pencarian.
- Dibuat lewat siklus AI-assisted modul Minggu 9: prompt 5 slot -> output mentah
  disimpan -> verify -> bug case-sensitive dibuktikan red test -> fix ->
  refactor ke domain. Detail: 09-week-9-ai-assisted-development/docs/ai-log.md
  dan docs/ai-review-vs-keputusan.md.

## Cara uji
- Ketik `belajar` -> catatan berjudul `Belajar ...` tetap tampil.
- Ketik `zzz-tidak-ada` -> empty state + tombol Hapus pencarian berfungsi.
- Kosongkan/spasi saja -> semua catatan tampil.
- `flutter analyze` -> No issues found.
- `flutter test` -> 21/21 (4 unit SearchNotes + 1 widget test empty state).

## Screenshot
search-query-cocok.png, search-empty-state.png, search-query-kosong.png
(09-week-9-ai-assisted-development/screenshots/)
```

Review oleh teman seperti biasa (reviewer wajib checkout + run + test), setelah
approve -> merge **Create a merge commit**, hapus branch.

## Checklist deliverable modul Minggu 9

- [x] Satu fitur kecil berbasis AI (search + empty state), kode AI ≤ 80 baris
- [x] `docs/ai-log.md`: prompt, konteks, output mentah, verifikasi, bug + red test
- [x] Bukti mesin hijau di README (analyze + test 21/21)
- [x] Tabel terima/tolak saran AI dengan bukti (1 terima, 2 tolak)
- [x] Refactor ke use case domain; fungsi ≤ 40 baris
- [ ] Merge PR via review sejawat (setelah PR Minggu 8)
