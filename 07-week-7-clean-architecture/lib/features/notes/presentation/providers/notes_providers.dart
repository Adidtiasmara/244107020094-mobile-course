import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infra/database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';

/// Satu-satunya tempat wiring fitur `notes` (dependency injection).
///
/// `presentation` bergantung pada kontrak `NoteRepository` (domain); implementasi
/// SQLite (data) hanya dirakit di sini. `openDb` disuntikkan agar mudah diganti
/// fake saat test.

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final getNoteProvider = Provider<GetNote>((ref) {
  return GetNote(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

final syncNotesProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

/// State daftar catatan untuk UI.
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.notes;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getNotesProvider).call();
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return result.notes;
    });
  }

  Future<void> add({required String title, String body = ''}) async {
    await ref.read(addNoteProvider).call(title: title, body: body);
    await refresh();
  }

  Future<void> remove(int id) async {
    await ref.read(deleteNoteProvider).call(id);
    await refresh();
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

/// Jumlah catatan belum tersinkron (derived dari daftar catatan).
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final notes = await ref.watch(notesProvider.future);
  return notes.where((note) => note.dirty).length;
});

/// Detail catatan dibaca dari repository lokal, bukan state halaman list.
final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final result = await ref.watch(getNoteProvider).call(id);
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.note;
});
