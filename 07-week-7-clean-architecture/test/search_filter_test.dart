import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/domain/usecases/search_notes.dart';
import 'package:week7_clean_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week7_clean_notes/features/notes/presentation/providers/notes_providers.dart';

import 'fakes.dart';

void main() {
  const search = SearchNotes();

  List<Note> sample() => [
    Note(title: 'Belajar Flutter', updatedAt: DateTime(2026, 11, 6)),
    Note(title: 'Belajar Riverpod', updatedAt: DateTime(2026, 11, 5)),
    Note(title: 'Belanja mingguan', updatedAt: DateTime(2026, 11, 4)),
  ];

  test('SearchNotes menyaring judul yang mengandung kata kunci', () {
    final results = search.call(notes: sample(), query: 'Riverpod');
    expect(results, hasLength(1));
    expect(results.first.title, 'Belajar Riverpod');
  });

  test('SearchNotes mengabaikan huruf besar/kecil', () {
    final results = search.call(notes: sample(), query: 'belajar');
    expect(results, hasLength(2));
  });

  test('SearchNotes dengan query kosong mengembalikan semua catatan', () {
    expect(search.call(notes: sample(), query: ''), hasLength(3));
  });

  test('SearchNotes query spasi mengembalikan semua catatan', () {
    expect(search.call(notes: sample(), query: '   '), hasLength(3));
  });

  test('SearchNotes tanpa hasil mengembalikan list kosong', () {
    expect(search.call(notes: sample(), query: 'zzz-tidak-ada'), isEmpty);
  });

  testWidgets(
    'pencarian tanpa hasil menampilkan empty state dan tombol hapus',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(
              RecordingNoteRepository(
                items: [
                  Note(
                    title: 'Belajar Flutter',
                    updatedAt: DateTime(2026, 11, 6),
                  ),
                  Note(
                    title: 'Belanja mingguan',
                    updatedAt: DateTime(2026, 11, 5),
                  ),
                ],
              ),
            ),
          ],
          child: const MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz-tidak-ada');
      await tester.pumpAndSettle();
      expect(
        find.text('Tidak ada catatan dengan judul "zzz-tidak-ada".'),
        findsOneWidget,
      );
      expect(find.text('Belajar Flutter'), findsNothing);

      await tester.tap(find.text('Hapus pencarian'));
      await tester.pumpAndSettle();
      expect(find.text('Belajar Flutter'), findsOneWidget);
      expect(find.text('Belanja mingguan'), findsOneWidget);
    },
  );
}
