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

/// Fake yang mencatat setiap pemanggilan `addNote`.
///
/// Dipakai untuk membuktikan validasi judul ditolak di use case SEBELUM
/// repository tersentuh. Catatan yang ditambahkan ikut dikembalikan oleh
/// `fetchNotes` sehingga alur simpan-ke-daftar bisa diuji sampai UI.
class RecordingNoteRepository extends FakeNoteRepository {
  RecordingNoteRepository({super.items});

  int addCalls = 0;
  final List<Note> addedNotes = [];

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: [...items, ...addedNotes], failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCalls++;
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime(2026, 11, 3),
      dirty: true,
    );
    addedNotes.add(note);
    return (note: note, failure: null);
  }
}
