import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Hasil sinkronisasi: berapa catatan yang berhasil dikirim, atau failure.
typedef SyncResult = ({int synced, Failure? failure});

/// Use case: sinkronkan catatan "kotor" (dirty).
///
/// Use case ini punya logika nyata (bukan sekadar meneruskan satu panggilan):
/// menghitung catatan dirty, menyimulasikan upload, lalu menandai bersih hanya
/// bila "server" menjawab sukses. Inilah alasan use case layak dibuat di sini.
class SyncNotes {
  const SyncNotes(this._repository);

  final NoteRepository _repository;

  Future<SyncResult> call() async {
    final counted = await _repository.countDirty();
    if (counted.failure != null) {
      return (synced: 0, failure: counted.failure);
    }
    if (counted.count == 0) {
      return (synced: 0, failure: null);
    }

    // Pada project nyata, kirim tiap catatan dirty ke REST API di sini, lalu
    // tandai bersih bila server menjawab 2xx. Codelab menyimulasikan upload.
    await Future<void>.delayed(const Duration(seconds: 1));

    final marked = await _repository.markAllSynced();
    if (marked.failure != null) {
      return (synced: 0, failure: marked.failure);
    }
    return (synced: counted.count, failure: null);
  }
}
