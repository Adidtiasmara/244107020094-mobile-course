import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'models/post.dart';
import 'repositories/note_repository.dart';

/// Sinkronisasi catatan "kotor" (dirty).
///
/// Codelab ini belum punya backend tulis, jadi upload disimulasikan dengan
/// delay. Yang dinilai adalah mekanismenya: catatan hanya ditandai bersih
/// setelah "server" menjawab sukses.
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Pada project nyata, kirim tiap catatan dirty ke REST API di sini,
  // lalu tandai bersih bila server menjawab 2xx.
  await Future<void>.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

/// Cache-first read untuk data API.
///
/// Baca cache lokal seketika agar UI tidak blank saat offline, lalu refresh
/// dari jaringan di background dan simpan hasilnya untuk kunjungan berikutnya.
Future<List<Post>> readCachedPosts(Database db) async {
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows
      .map((row) {
        final payload = row['payload'] as String? ?? '{}';
        final decoded = jsonDecode(payload);
        if (decoded is Map) {
          return Post.fromJson(decoded.cast<String, Object?>());
        }
        return null;
      })
      .whereType<Post>()
      .toList();
}

Future<DateTime?> cachedPostsAt(Database db) async {
  final rows = await db.query(
    'cached_posts',
    columns: ['cached_at'],
    orderBy: 'cached_at DESC',
    limit: 1,
  );
  if (rows.isEmpty) return null;
  return DateTime.tryParse(rows.first['cached_at'] as String? ?? '');
}

Future<void> writeCachedPosts(Database db, List<Post> posts) async {
  final cachedAt = DateTime.now().toIso8601String();
  final batch = db.batch();
  batch.delete('cached_posts');
  for (final post in posts) {
    batch.insert('cached_posts', {
      'id': post.id,
      'payload': jsonEncode(post.toJson()),
      'cached_at': cachedAt,
    });
  }
  await batch.commit(noResult: true);
}
