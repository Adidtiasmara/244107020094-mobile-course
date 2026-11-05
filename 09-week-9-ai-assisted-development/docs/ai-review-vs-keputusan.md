# AI Review vs Keputusan — Minggu 9 (AI Prompt Challenge)

Prompt baku modul dijalankan pada kode pencarian final (setelah refactor):

```text
Review this Flutter search code as a senior dev.
Context: feature-first (presentation->domain<-data),
Riverpod, SQLite + Dio.
Focus: correctness, architecture, tests. Ignore style.
Give 3 findings + blocker/suggestion level + reasons.
```

Setiap temuan diverifikasi sebelum diputuskan: dicari buktinya dengan test,
grep, atau penalaran arsitektur. Diperiksa ulang prinsip Minggu 8: temuan AI
adalah hipotesis, bukan keputusan.

## Tabel temuan vs keputusan

| # | Level | Temuan AI | Verifikasi | Keputusan | Tindak lanjut |
|---|-------|-----------|------------|-----------|---------------|
| 1 | Saran | Query berisi spasi saja (`"   "`) lolos `isEmpty` sehingga diperlakukan sebagai pencarian aktif → `contains("   ")` nyaris selalu 0 hasil → empty state "Tidak ada catatan..." yang menyesatkan. Usul: trim query di use case. | Test merah: `SearchNotes query spasi mengembalikan semua catatan` gagal (`Expected: length <3>, Actual: 0`) — bukti di `screenshots/terminal-red-test-trim.txt`. | **Terima** | `fix(notes): query spasi dianggap tanpa kata kunci` (8e84e14) — `query.trim().toLowerCase()` sebelum cek kosong; test hijau 21/21. |
| 2 | Saran | Tambahkan debounce ~300 ms pada query agar tidak memfilter di setiap keystroke. | Klasifikasi di modul: performa, bukan kebenaran/arsitektur. Sumber data lokal (list in-memory dari SQLite); filter O(n) di bawah 1 ms untuk ribuan catatan; debounce menambah latensi UI + state timer yang harus di-dispose. | **Tolak** | Alasan: over-engineering tanpa manfaat terukur pada skala data ini; kalau nanti datanya ribuan dan terasa lambat, bukti dulu lewat profiling (Minggu 11), baru optimasi. |
| 3 | Saran | Perluas pencarian ke field `body`, bukan hanya `title`. | Bukan cacat kode — perubahan spesifikasi fitur. Prompt & kebutuhan fitur memang "pencarian judul"; memperluas diam-diam mengubah perilaku yang sudah ditest. | **Tolak** | Alasan: scope creep. Kalau nanti diminta, jadi fitur terpisah dengan test-nya sendiri (dan dokumentasi prompt baru di ai-log). |

## Hasil verifikasi (checklist modul)

- [x] ≥ 1 temuan AI terbukti benar lalu diperbaiki: #1 (test merah → fix → hijau)
- [x] ≥ 1 temuan ditolak dengan alasan teknis tertulis: #2 dan #3
- [x] Keputusan per file tercatat di `docs/ai-log.md` §7
- [x] Semua keputusan bisa dijelaskan tanpa membuka kembali jawaban AI
- [x] `flutter analyze` 0 issue, `dart format` bersih, `flutter test` 21/21 (bukti: `screenshots/terminal-analyze-format-test.txt`)

## Ringkasan seluruh siklus Minggu 9

| Tahap | Artefak |
|---|---|
| Prompt 5 slot | `docs/ai-log.md` §1 |
| Output mentah AI | `docs/ai-log.md` §2 (commit `1436242`, apa adanya) |
| Bug terbukti + red test | case-sensitive filter — `screenshots/terminal-red-test.txt`, fix `5310c73` |
| Refactor ke domain | `SearchNotes` + provider — commit `c53ea06` |
| Prompt challenge | 1 diterima (`8e84e14`), 2 ditolak — tabel di atas |
