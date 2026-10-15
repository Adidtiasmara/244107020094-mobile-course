import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/notes/domain/usecases/sync_notes.dart';

import 'fakes.dart';

void main() {
  test('SyncNotes menandai bersih dan melaporkan jumlah', () async {
    final repo = FakeNoteRepository(dirtyCount: 3);
    final result = await SyncNotes(repo).call();
    expect(result.failure, isNull);
    expect(result.synced, 3);
    expect(repo.markedSynced, isTrue);
  });

  test('SyncNotes tidak menyentuh server saat tidak ada catatan dirty',
      () async {
    final repo = FakeNoteRepository(dirtyCount: 0);
    final result = await SyncNotes(repo).call();
    expect(result.synced, 0);
    expect(repo.markedSynced, isFalse);
  });

  test('SyncNotes meneruskan failure tanpa melempar', () async {
    final repo = FakeNoteRepository(fail: true);
    final result = await SyncNotes(repo).call();
    expect(result.failure, isA<LocalFailure>());
  });
}
