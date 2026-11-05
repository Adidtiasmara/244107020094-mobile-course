import '../entities/note.dart';

/// Use case: cari catatan berdasarkan judul.
///
/// Pencarian tidak peka huruf besar/kecil; query kosong mengembalikan daftar
/// apa adanya. Murni Dart (tanpa import Flutter/SQLite/Dio) agar bisa diuji
/// tanpa UI dan bebas dari framework.
class SearchNotes {
  const SearchNotes();

  List<Note> call({required List<Note> notes, required String query}) {
    if (query.isEmpty) return notes;
    final keyword = query.toLowerCase();
    return notes
        .where((note) => note.title.toLowerCase().contains(keyword))
        .toList();
  }
}
