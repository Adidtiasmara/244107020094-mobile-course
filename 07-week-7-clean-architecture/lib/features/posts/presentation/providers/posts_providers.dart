import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../infra/database.dart';
import '../../../../infra/network.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    dio: ref.watch(dioProvider),
    openDb: openNotesDb,
  );
});

/// State halaman post: daftar, asal data (cache/jaringan), waktu cache, error.
class PostsState {
  const PostsState({
    required this.posts,
    required this.fromCache,
    this.cachedAt,
    this.failure,
  });

  final List<Post> posts;
  final bool fromCache;
  final DateTime? cachedAt;
  final Failure? failure;

  PostsState copyWith({
    List<Post>? posts,
    bool? fromCache,
    DateTime? cachedAt,
    Failure? failure,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      fromCache: fromCache ?? this.fromCache,
      cachedAt: cachedAt ?? this.cachedAt,
      failure: failure ?? this.failure,
    );
  }
}

/// Cache-first read: tampilkan cache lokal seketika, lalu refresh jaringan.
class PostsNotifier extends AsyncNotifier<PostsState> {
  @override
  Future<PostsState> build() async {
    final cached = await ref.watch(postRepositoryProvider).readCached();
    if (cached.posts.isNotEmpty) {
      return PostsState(
        posts: cached.posts,
        fromCache: true,
        cachedAt: cached.cachedAt,
      );
    }
    final fetched = await _fetchAndCache();
    if (fetched.failure != null) {
      throw Exception(fetched.failure!.message);
    }
    return fetched.state!;
  }

  Future<void> refresh() async {
    final fetched = await _fetchAndCache();
    if (fetched.failure != null) {
      final previous = state.value;
      if (previous != null && previous.posts.isNotEmpty) {
        // Pertahankan cache yang sudah tampil, catat kegagalan refresh.
        state = AsyncData(previous.copyWith(failure: fetched.failure));
      } else {
        state = AsyncError(fetched.failure!, StackTrace.current);
      }
      return;
    }
    state = AsyncData(fetched.state!);
  }

  Future<({PostsState? state, Failure? failure})> _fetchAndCache() async {
    if (ref.read(forceOfflineProvider)) {
      return (state: null, failure: const NetworkFailure('Mode offline aktif.'));
    }
    final result = await ref.read(postRepositoryProvider).fetchPosts();
    if (result.failure != null) {
      return (state: null, failure: result.failure);
    }
    await ref.read(postRepositoryProvider).writeCached(result.posts);
    return (
      state: PostsState(
        posts: result.posts,
        fromCache: false,
        cachedAt: DateTime.now(),
      ),
      failure: null,
    );
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, PostsState>(
  PostsNotifier.new,
  retry: (retryCount, error) => null,
);
