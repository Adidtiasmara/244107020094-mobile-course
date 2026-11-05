# Screenshot manual — uji 3 query (wajib modul)

Jalankan aplikasi, lalu ambil screenshot untuk 3 kondisi berikut:

## 1. Query yang cocok (tidak peka huruf besar/kecil)

1. Buat 2–3 catatan (mis. judul `Belajar Flutter`, `Belanja mingguan`).
2. Ketik `belajar` (huruf kecil) di kotak cari.
3. **Harapan:** dua catatan `Belajar ...` tetap tampil.
4. Screenshot → `search-query-cocok.png`.

## 2. Query tidak cocok (empty state)

1. Ganti query menjadi `zzz-tidak-ada`.
2. **Harapan:** muncul "Tidak ada catatan dengan judul `zzz-tidak-ada`."
   beserta tombol **Hapus pencarian**.
3. Screenshot → `search-empty-state.png`.
4. Tekan **Hapus pencarian** → daftar kembali normal (bisa ikut di-screenshot).

## 3. Query kosong/spasi

1. Kosongkan kotak cari (atau isi dengan spasi saja).
2. **Harapan:** semua catatan tampil, tidak ada empty state palsu.
3. Screenshot → `search-query-kosong.png`.

## Cara menjalankan

```bash
cd 07-week-7-clean-architecture
flutter create . --platforms=android,windows
flutter run
```

Bukti mesin (analyze/format/test) tidak butuh screenshot manual — tersimpan
sebagai teks di `terminal-analyze-format-test.txt`.
