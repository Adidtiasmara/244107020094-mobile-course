# AI Review vs Keputusan — Minggu 8

Sesuai AI Prompt Challenge Minggu 8, PR `feat(notes)` di-review ulang dengan bantuan AI
(Model: GLM via ZCode CLI) yang berperan sebagai senior Flutter developer. Setiap temuan
AI kemudian diverifikasi sendiri sebelum diputuskan: dicari buktinya (grep, test, atau
reproduksi manual). Yang tidak punya bukti, ditolak.

## Prompt yang dipakai

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

Ditujukan pada diff PR validasi judul (`89b92e6`) plus file fitur `notes` yang tersentuh.

## Tabel temuan vs keputusan

| # | Level | Temuan AI | Verifikasi | Keputusan | Tindak lanjut |
|---|-------|-----------|------------|-----------|---------------|
| 1 | Blocker | `NotesNotifier.add()` membuang hasil `AddNote`. Kalau repository gagal (mis. SQLite error), UI tidak menampilkan apa-apa dan user merasa catatan tersimpan. | Baca `notes_providers.dart`: `await ref.read(addNoteProvider).call(...)` tanpa menampung return. Tidak ada jalur error ke UI. | **Terima** | `fix(notes): tampilkan gagal simpan dan perbaiki lifecycle dialog` (9acc5d8) — hasil use case diteruskan, SnackBar muncul saat `failure != null`, refresh hanya saat sukses. |
| 2 | Blocker | `TextEditingController` di `_openAddDialog` di-dispose setelah `showDialog` selesai, padahal animasi tutup dialog masih memainkan TextField → risiko *use after dispose*. | Widget test baru `add_note_dialog_test.dart` reproduksi bug-nya: `A TextEditingController was used after being disposed`. | **Terima** (dibuktikan test gagal sebelum perbaikan) | Commit yang sama (9acc5d8) — dialog diekstrak ke `_AddNoteDialog` (StatefulWidget) yang punya controller sendiri dan dispose di `dispose()`. |
| 3 | Saran (test) | `expect(result.note!.dirty, isTrue)` di `add_note_test.dart` menguji nilai hardcode milik fake, bukan perilaku sistem nyata. | `fakes.dart`: fake memang meng-hardcode `dirty: true` saat `addNote`. Assertion hanya menguji fake-nya sendiri. | **Terima** | `test(notes): uji dialog tambah catatan` (d2b64b2) — assertion diganti `repo.addCalls, 1` yang benar-benar menguji use case. |
| 4 | Saran | Validasi judul duplikat: ada di dialog (UI) dan di use case (domain). AI mengusulkan salah satu dihapus. | Kedua validasi memang ada, tetapi beda peran: validasi domain adalah aturan bisnis, error text di dialog adalah umpan balik UX. | **Tolak** | Alasan: aturan bisnis harus tetap hidup walau UI berubah — `add_note_test.dart` membuktikan use case menolak judul kosong **tanpa UI sama sekali**. Menghapus validasi domain justru melanggar prinsip yang diajarkan Minggu 7. |
| 5 | Saran | Pindahkan string `'Judul tidak boleh kosong'` ke konstanta terpusat agar tidak ditulis dua kali. | String memang muncul 2x, tetapi di dua konteks berbeda (pesan `Failure` domain vs `errorText` dialog). Setelah perbaikan #1, kegagalan domain juga mengalir ke SnackBar. | **Tolak** | Alasan: ekstraksi konstanta untuk satu string yang perannya beda adalah abstraksi prematur; formatter/CI sudah menangani gaya, jadi ini bukan temuan kebenaran maupun arsitektur. |

## Hasil verifikasi (checklist codelab)

- [x] ≥ 2 temuan AI terbukti benar dengan bukti: #1 (baca kode + jalur error hilang), #2 (test gagal → lulus), #3 (grep hardcode di fakes.dart)
- [x] ≥ 1 temuan ditolak dengan alasan tertulis: #4 dan #5
- [x] Keputusan per file tercatat: `add_note.dart`, `notes_providers.dart`, `notes_page.dart`, `add_note_test.dart`, `fakes.dart`
- [x] Semua keputusan bisa dijelaskan tanpa membuka kembali jawaban AI
- [x] `flutter analyze` 0 issue, `dart format` bersih, `flutter test` 15/15 setelah perbaikan (bukti: `screenshots/terminal-analyze-format-test.txt`)

## Catatan

AI reviewer cepat menangkap dua bug nyata (#1 dan #2) yang lolos saat PR dibuat, tetapi
sarannya tidak semua layak diterima (#4 bahkan bertentangan dengan dependency rule
Minggu 7 kalau diikuti). Pelajaran: temuan AI = hipotesis, bukan keputusan.
