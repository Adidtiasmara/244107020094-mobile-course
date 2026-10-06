import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    // pumpAndSettle menunggu dialog tertutup penuh; dengan pump() satu frame,
    // TextField dialog masih ada sehingga teks terhitung dua kali.
    await tester.pumpAndSettle();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('berpindah ke halaman statistik lewat GoRouter', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(delay: Duration.zero, failureRate: 0),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.tap(find.text('Tugas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tugas uji');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();

    expect(find.text('Total tugas'), findsOneWidget);
    expect(find.text('Belum selesai'), findsOneWidget);
  });
}
