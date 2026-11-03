import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case: tambah catatan baru.
///
/// Judul divalidasi di sini (domain), bukan hanya di widget, supaya aturan
/// bisnis bisa diuji tanpa UI. Catatan baru selalu ditandai `dirty` oleh
/// repository agar masuk antrean sync.
class AddNote {
  const AddNote(this._repository);

  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) async {
    if (title.trim().isEmpty) {
      return (
        note: null,
        failure: const ValidationFailure('Judul tidak boleh kosong'),
      );
    }
    return _repository.addNote(title: title, body: body);
  }
}
