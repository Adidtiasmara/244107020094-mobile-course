import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case: ambil satu catatan berdasarkan id (dipakai halaman `/note/:id`).
class GetNote {
  const GetNote(this._repository);

  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call(int id) {
    return _repository.getNote(id);
  }
}
