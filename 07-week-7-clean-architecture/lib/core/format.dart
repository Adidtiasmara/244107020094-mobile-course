/// Fungsi murni yang dapat diuji tanpa widget (Refactoring Challenge #2).
///
/// Berisi formatting tanggal dan parsing rute. Tidak mengimpor Flutter.
library;

/// Format tanggal ringkas `dd/MM/yyyy HH:mm`.
///
/// Nilai epoch 0 (hasil `DateTime.fromMillisecondsSinceEpoch(0)` ketika kolom
/// tanggal hilang) ditampilkan sebagai `-`.
String formatDateTime(DateTime time) {
  if (time.millisecondsSinceEpoch == 0) return '-';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(time.day)}/${two(time.month)}/${time.year} '
      '${two(time.hour)}:${two(time.minute)}';
}

/// Mengurai id catatan dari segmen rute `/note/:id`.
///
/// Mengembalikan `null` bila kosong atau bukan angka, sehingga pemanggil dapat
/// memutuskan rute fallback tanpa melempar exception.
int? parseNoteId(String? raw) {
  if (raw == null) return null;
  return int.tryParse(raw.trim());
}
