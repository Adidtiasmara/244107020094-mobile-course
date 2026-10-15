import '../../../../core/failures.dart';
import '../entities/note.dart';

/// Hasil operasi daftar catatan: sukses berisi `notes`, gagal berisi `failure`.
typedef NotesResult = ({List<Note> notes, Failure? failure});

/// Hasil operasi satu catatan.
typedef NoteResult = ({Note? note, Failure? failure});

/// Hasil operasi yang tidak mengembalikan data.
typedef VoidResult = ({Failure? failure});

/// Hasil penghitungan catatan belum tersinkron.
typedef CountResult = ({int count, Failure? failure});

/// Kontrak repository catatan.
///
/// Interface tinggal di `domain`; implementasi (SQLite) di `data`. Presentation
/// hanya bergantung pada kontrak ini, bukan pada `sqflite`. Setiap operasi
/// mengembalikan record sukses/gagal agar exception tidak bocor ke UI.
abstract class NoteRepository {
  Future<NotesResult> fetchNotes();

  Future<NoteResult> getNote(int id);

  Future<NoteResult> addNote({required String title, String body});

  Future<VoidResult> deleteNote(int id);

  Future<CountResult> countDirty();

  Future<VoidResult> markAllSynced();
}
