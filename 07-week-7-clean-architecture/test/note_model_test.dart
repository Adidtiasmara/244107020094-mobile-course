import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/features/notes/data/models/note_model.dart';

void main() {
  test('NoteModel.fromMap aman terhadap field yang hilang', () {
    final model = NoteModel.fromMap({'title': 'Belanja'});
    expect(model.title, 'Belanja');
    expect(model.body, '');
    expect(model.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final model = NoteModel(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = NoteModel.fromMap(model.toMap());
    expect(restored.dirty, isTrue);
  });

  test('toEntity menghasilkan entity murni', () {
    final model = NoteModel(
      id: 5,
      title: 't',
      body: 'b',
      updatedAt: DateTime(2026, 9, 18),
    );
    final entity = model.toEntity();
    expect(entity.id, 5);
    expect(entity.title, 't');
    expect(entity.body, 'b');
  });
}
