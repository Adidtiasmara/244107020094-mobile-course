import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week7_clean_notes/features/notes/presentation/providers/notes_providers.dart';

import 'fakes.dart';

Future<void> _pumpNotesPage(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(RecordingNoteRepository()),
      ],
      child: const MaterialApp(home: NotesPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Dialog tambah menampilkan error saat judul kosong', (
    tester,
  ) async {
    await _pumpNotesPage(tester);

    await tester.tap(find.text('Catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan baru'), findsOneWidget);

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Judul tidak boleh kosong'), findsOneWidget);
    // Dialog tetap terbuka agar pengguna bisa memperbaiki input.
    expect(find.text('Catatan baru'), findsOneWidget);
  });

  testWidgets('Judul valid menyimpan catatan dan menutup dialog', (
    tester,
  ) async {
    await _pumpNotesPage(tester);

    await tester.tap(find.text('Catatan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Judul'),
      'Belajar minggu 8',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan baru'), findsNothing);
    expect(find.text('Belajar minggu 8'), findsOneWidget);
  });
}
