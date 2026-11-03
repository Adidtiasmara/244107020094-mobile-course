# Panduan push & buka PR di GitHub

Semua branch sudah disiapkan lokal. Urutan kerjanya penting: merge PR-1 dulu,
baru PR-2, terakhir PR-3.

## 1. Push semua branch

```bash
git push origin main develop feature/build-scaffold feature/notes-title-validation feature/ci-github-actions feature/week8-review-docs
```

Kredensial diambil otomatis dari Windows Credential Manager (sama seperti push
minggu-minggu sebelumnya).

## 2. Buat issue dulu

Issues → New issue, tempel draft di bawah. Catat nomor issue-nya (misal #34), karena
body PR-2 memakai `Closes #<nomor>`.

**Judul:** Menekan Simpan dengan judul kosong tidak memberi umpan balik apa pun

```markdown
**Langkah reproduksi:**
1. Buka halaman Catatan Offline, tekan tombol + Catatan.
2. Biarkan judul kosong, langsung tekan Simpan.

**Yang terjadi:** dialog tertutup tanpa pesan. Tidak jelas catatan tersimpan atau tidak.

**Yang diharapkan:** validasi menolak judul kosong dan menampilkan pesan jelas,
aturan validasinya ada di use case (domain), bukan hanya di widget.

**Lingkup:** 07-week-7-clean-architecture (fitur notes).
```

## 3. Buka PR-1 — scaffold build

Compare: base `develop` ← compare `feature/build-scaffold`.

```markdown
## Masalah
Folder `07-week-7-clean-architecture/` tidak bisa di-build dari clone baru:
pubspec.yaml dan analysis_options.yaml di-ignore oleh .gitignore root, sehingga
`flutter pub get` / `flutter test` tidak bisa dijalankan reviewer maupun CI.
Hasil audit riwayat: lihat 08-week-8-mid-project-review/docs/review-checklist.md.

## Solusi
Commit pubspec.yaml, analysis_options.yaml, dan pubspec.lock untuk project minggu 7,
lalu hapus aturan ignore tiga file tersebut. Folder platform dan build tetap di-ignore.
pubspec.lock ikut dikomit karena ini aplikasi: versi dependency terkunci agar CI dan
reviewer memakai versi yang sama.

## Cara uji
- Clone fresh → `flutter pub get` di folder 07-week-7-clean-architecture → sukses.
- `flutter analyze` → No issues found.
- `flutter test` → 10/10 lulus (baseline sebelum perubahan fitur).

## Screenshot
Bukti terminal: 08-week-8-mid-project-review/screenshots/terminal-analyze-format-test.txt
```

Merge: **Create a merge commit** (jangan squash, agar hash commit yang dikutip
di dokumentasi tetap valid). Hapus branch setelah merge.

## 4. Buka PR-2 — validasi judul

Compare: base `develop` ← compare `feature/notes-title-validation`.
Ganti `#<nomor>` di bawah dengan nomor issue dari langkah 2.

```markdown
## Masalah
Closes #<nomor>

Di dialog "Catatan baru", menekan Simpan dengan judul kosong menutup dialog tanpa
pesan apa pun. Selain itu aturan validasi hanya ada di widget, bukan di domain,
sehingga tidak bisa diuji tanpa UI.

## Solusi
- Validasi judul pindah ke use case `AddNote`: judul kosong/spasi mengembalikan
  `ValidationFailure('Judul tidak boleh kosong')` tanpa menyentuh repository.
- Dialog menampilkan error inline dan tetap terbuka; tombol Simpan tidak lagi
  pop diam-diam.
- Perbaikan tambahan dari hasil review (08-week-8-mid-project-review/docs/ai-review-vs-keputusan.md):
  - hasil `AddNote` tidak dibuang lagi; gagal simpan muncul sebagai SnackBar,
  - dialog diekstrak ke `_AddNoteDialog` (StatefulWidget) sehingga controller
    tidak pernah dipakai setelah di-dispose saat animasi tutup.

## Cara uji
- Buka aplikasi → + Catatan → kosongkan judul → Simpan → muncul
  "Judul tidak boleh kosong", dialog tetap terbuka.
- Isi judul "Belajar minggu 8" → Simpan → catatan muncul di daftar.
- `flutter analyze` → No issues found.
- `flutter test` → 15/15 (3 unit test use case + 2 widget test dialog baru).

## Screenshot
Dialog error judul kosong + daftar catatan setelah simpan (screenshots/).
```

Minta **teman sekelas** me-review (peer review 15 menit — reviewer wajib checkout,
run, dan test manual dulu). Tindak lanjuti semua komentar sampai Approve, baru merge.
Jangan merge selama status masih Request changes.

## 5. Buka PR-3 — format + CI

Compare: base `develop` ← compare `feature/ci-github-actions`.

```markdown
## Masalah
Pemeriksaan gaya dan test masih manual. Saat review Minggu 8 ditemukan 13 file
yang belum rapi menurut `dart format` dan satu lint lama di infra/network.dart.

## Solusi
- `dart format .` untuk seluruh project minggu 7 (perubahan whitespace saja)
  + beri kurung kurawal pada if di infra/network.dart.
- Tambah .github/workflows/ci.yml: setiap pull_request menjalankan
  dart format check, flutter analyze, dan flutter test
  (working-directory 07-week-7-clean-architecture).
- Tambah .github/PULL_REQUEST_TEMPLATE.md sesuai anatomi PR di codelab.

## Cara uji
- `dart format --output=none --set-exit-if-changed .` → exit 0.
- `flutter analyze` → No issues found; `flutter test` → 15/15.
- CI baru aktif untuk PR setelahnya (workflow harus sudah ada di default branch
  target merge terlebih dahulu).

## Screenshot
Tab checks pada PR setelah workflow aktif.
```

Merge seperti PR-1.

## 6. PR-4 — dokumentasi minggu 8

Compare: base `develop` ← compare `feature/week8-review-docs`. Isi singkat:
"Dokumentasi review minggu 8 (review-checklist, ai-review-vs-keputusan, README
folder 08) dan update status progres di README utama." Merge setelah PR-2 & PR-3
agar hash commit yang dikutip sudah ada di develop.

## 7. Setelah semua merge

```bash
git checkout develop
git pull origin develop
```

Lalu update README utama: baris Minggu 8 dari "PR menunggu review" menjadi
"✅ Selesai" (commit `docs: tandai minggu 8 selesai` langsung ke main boleh untuk
perubahan README saja, atau lewat PR kecil). Issue #<nomor> otomatis tertutup oleh
merge PR-2.
