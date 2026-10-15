/// Entity catatan (objek bisnis murni).
///
/// Tanpa `toMap/fromMap/toJson` — mapping hanya hidup di `data/models`.
/// Tanpa import Flutter/Dio/SQLite agar `domain` dapat diuji murni.
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
