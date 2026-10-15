import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Use case: hapus catatan berdasarkan id.
class DeleteNote {
  const DeleteNote(this._repository);

  final NoteRepository _repository;

  Future<({Failure? failure})> call(int id) {
    return _repository.deleteNote(id);
  }
}
