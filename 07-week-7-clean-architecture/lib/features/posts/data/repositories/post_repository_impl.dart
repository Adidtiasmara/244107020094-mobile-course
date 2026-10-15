import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../../../infra/network.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

/// Implementasi `PostRepository`: ambil dari Dio, cache ke SQLite.
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({
    required this.dio,
    required this.openDb,
  });

  final Dio dio;
  final Future<Database> Function() openDb;

  @override
  Future<({List<Post> posts, Failure? failure})> fetchPosts() async {
    try {
      final response = await dio.get<List<Object?>>('/posts');
      final data = response.data ?? const [];
      final posts = data
          .whereType<Map<Object?, Object?>>()
          .map((e) => PostModel.fromJson(e.cast<String, Object?>()).toEntity())
          .toList();
      return (posts: posts, failure: null);
    } catch (e) {
      return (posts: const <Post>[], failure: mapDioError(e));
    }
  }

  @override
  Future<({List<Post> posts, DateTime? cachedAt, Failure? failure})>
      readCached() async {
    try {
      final db = await openDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC');
      final posts = rows
          .map((row) {
            final payload = row['payload'] as String? ?? '{}';
            final decoded = jsonDecode(payload);
            if (decoded is Map) {
              return PostModel.fromJson(decoded.cast<String, Object?>())
                  .toEntity();
            }
            return null;
          })
          .whereType<Post>()
          .toList();
      final cachedAt = await _cachedAt(db);
      return (posts: posts, cachedAt: cachedAt, failure: null);
    } catch (e) {
      return (
        posts: const <Post>[],
        cachedAt: null,
        failure: LocalFailure('Gagal membaca cache: $e'),
      );
    }
  }

  @override
  Future<({Failure? failure})> writeCached(List<Post> posts) async {
    try {
      final db = await openDb();
      final cachedAt = DateTime.now().toIso8601String();
      final batch = db.batch();
      batch.delete('cached_posts');
      for (final post in posts) {
        batch.insert('cached_posts', {
          'id': post.id,
          'payload': jsonEncode(
            PostModel(
              id: post.id,
              userId: post.userId,
              title: post.title,
              body: post.body,
            ).toJson(),
          ),
          'cached_at': cachedAt,
        });
      }
      await batch.commit(noResult: true);
      return (failure: null);
    } catch (e) {
      return (failure: LocalFailure('Gagal menyimpan cache: $e'));
    }
  }

  Future<DateTime?> _cachedAt(Database db) async {
    final rows = await db.query(
      'cached_posts',
      columns: ['cached_at'],
      orderBy: 'cached_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.first['cached_at'] as String? ?? '');
  }
}
