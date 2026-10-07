import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/pages/paged_post_page.dart';
import 'package:week4_api/widgets/post_tile.dart';

import 'fakes.dart';

void main() {
  testWidgets('PostTile menampilkan judul, isi, dan id post',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PostTile(
            post: Post(userId: 1, id: 5, title: 'Judul', body: 'Isi'),
          ),
        ),
      ),
    );

    expect(find.text('Judul'), findsOneWidget);
    expect(find.text('Isi'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('PagedPostPage menampilkan data dari repository palsu',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(items: const [
              Post(userId: 1, id: 1, title: 'Judul Pertama', body: 'Isi'),
            ]),
          ),
        ],
        child: const MaterialApp(home: PagedPostPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Judul Pertama'), findsOneWidget);
    expect(find.text('Semua data termuat.'), findsOneWidget);
  });
}
