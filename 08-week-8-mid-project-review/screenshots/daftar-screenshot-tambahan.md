# Screenshot tambahan yang perlu diambil manual

Bukti mesin (analyze / format / test) sudah direkam sebagai teks di
`terminal-analyze-format-test.txt`. Screenshot berikut perlu diambil saat
aplikasi dan PR sudah berjalan:

1. `dialog-error-judul-kosong.png` — dialog "Catatan baru" dengan pesan
   "Judul tidak boleh kosong" saat Simpan ditekan tanpa judul.
2. `catatan-berhasil-tersimpan.png` — daftar catatan setelah simpan dengan judul valid.
3. `pr-halaman.png` — halaman PR-2 di GitHub (bisa dipakai juga sebagai screenshot
   wajib di body PR).
4. `ci-checks-hijau.png` — tab Checks pada PR setelah workflow CI aktif.
5. (opsional) `merge-commit.png` — merge commit PR-2 di branch develop.

Cara menjalankan aplikasi untuk screenshot 1–2:

```bash
cd 07-week-7-clean-architecture
flutter create . --platforms=android,windows
flutter run
```
