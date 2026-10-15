import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/domain/repositories/note_repository.dart';

/// Repository palsu untuk menguji domain tanpa SQLite/Dio/Firebase.
///
/// Mengimplementasikan kontrak `NoteRepository` sehingga use case dapat diuji
/// murni. Hanya method yang dipakai test yang diisi; sisanya melempar
/// `UnimplementedError` agar pemakaian tak terduga langsung ketahuan.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({
    this.items = const [],
    this.fail = false,
    this.dirtyCount = 0,
  });

  final List<Note> items;
  final bool fail;
  final int dirtyCount;

  bool markedSynced = false;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> getNote(int id) async {
    if (fail) {
      return (note: null, failure: const LocalFailure('db locked (simulasi)'));
    }
    for (final note in items) {
      if (note.id == id) return (note: note, failure: null);
    }
    return (note: null, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<({Failure? failure})> deleteNote(int id) {
    throw UnimplementedError();
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    if (fail) {
      return (count: 0, failure: const LocalFailure('db locked (simulasi)'));
    }
    return (count: dirtyCount, failure: null);
  }

  @override
  Future<({Failure? failure})> markAllSynced() async {
    markedSynced = true;
    return (failure: null);
  }
}
