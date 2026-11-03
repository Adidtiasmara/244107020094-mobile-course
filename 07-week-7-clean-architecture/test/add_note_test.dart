import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/domain/usecases/add_note.dart';

import 'fakes.dart';

/// Fake yang mencatat apakah `addNote` benar-benar dipanggil.
///
/// Dipakai untuk membuktikan validasi judul ditolak di use case SEBELUM
/// menyentuh repository.
class RecordingNoteRepository extends FakeNoteRepository {
  int addCalls = 0;

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCalls++;
    return (
      note: Note(
        title: title,
        body: body,
        updatedAt: DateTime(2026, 11, 3),
        dirty: true,
      ),
      failure: null,
    );
  }
}

void main() {
  test('AddNote menolak judul kosong tanpa menyentuh repository', () async {
    final repo = RecordingNoteRepository();
    final result = await AddNote(repo).call(title: '', body: 'isi');
    expect(result.failure, isA<ValidationFailure>());
    expect(result.failure!.message, 'Judul tidak boleh kosong');
    expect(result.note, isNull);
    expect(repo.addCalls, 0);
  });

  test('AddNote menolak judul yang hanya berisi spasi', () async {
    final repo = RecordingNoteRepository();
    final result = await AddNote(repo).call(title: '   ');
    expect(result.failure, isA<ValidationFailure>());
    expect(repo.addCalls, 0);
  });

  test('AddNote meneruskan judul valid ke repository', () async {
    final repo = RecordingNoteRepository();
    final result = await AddNote(repo).call(title: 'Belajar minggu 8');
    expect(result.failure, isNull);
    expect(result.note!.title, 'Belajar minggu 8');
    expect(result.note!.dirty, isTrue);
    expect(repo.addCalls, 1);
  });
}
