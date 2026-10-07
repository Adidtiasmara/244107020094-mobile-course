import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

void main() {
  testWidgets('NoteTile menampilkan badge belum tersinkron saat dirty',
      (tester) async {
    final note = Note(
      id: 1,
      title: 'Catatan uji',
      body: 'Isi catatan',
      updatedAt: DateTime(2026, 9, 18, 10, 30),
      dirty: true,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: NoteTile(note: note))),
    );

    expect(find.text('Catatan uji'), findsOneWidget);
    expect(find.text('Isi catatan'), findsOneWidget);
    expect(find.text('Belum tersinkron'), findsOneWidget);
  });

  testWidgets('NoteTile tidak menampilkan badge saat sudah sinkron',
      (tester) async {
    final note = Note(
      id: 2,
      title: 'Sudah sinkron',
      updatedAt: DateTime(2026, 9, 18, 10, 30),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: NoteTile(note: note))),
    );

    expect(find.text('Belum tersinkron'), findsNothing);
  });
}
