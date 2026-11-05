import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/presentation/pages/notes_page.dart';

void main() {
  List<Note> sample() => [
    Note(title: 'Belajar Flutter', updatedAt: DateTime(2026, 11, 6)),
    Note(title: 'Belajar Riverpod', updatedAt: DateTime(2026, 11, 5)),
    Note(title: 'Belanja mingguan', updatedAt: DateTime(2026, 11, 4)),
  ];

  test('filterNotes menyaring judul yang mengandung kata kunci', () {
    final results = filterNotes(sample(), 'Riverpod');
    expect(results, hasLength(1));
    expect(results.first.title, 'Belajar Riverpod');
  });

  test('filterNotes dengan query kosong mengembalikan semua catatan', () {
    expect(filterNotes(sample(), ''), hasLength(3));
  });

  test('filterNotes tanpa hasil mengembalikan list kosong', () {
    expect(filterNotes(sample(), 'zzz-tidak-ada'), isEmpty);
  });
}
