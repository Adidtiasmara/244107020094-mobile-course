import '../../../../core/failures.dart';
import '../entities/post.dart';

/// Hasil ambil post dari jaringan.
typedef PostsResult = ({List<Post> posts, Failure? failure});

/// Hasil baca cache lokal beserta waktu cache.
typedef CachedPostsResult = ({
  List<Post> posts,
  DateTime? cachedAt,
  Failure? failure,
});

/// Kontrak repository post: jaringan + cache lokal.
///
/// Cache disatukan di kontrak ini karena perilaku offline-first (baca cache
/// dulu, lalu refresh jaringan) adalah aturan yang dipakai presentation.
abstract class PostRepository {
  Future<PostsResult> fetchPosts();

  Future<CachedPostsResult> readCached();

  Future<({Failure? failure})> writeCached(List<Post> posts);
}
