import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'api_client.dart';
import 'local/db.dart';
import 'local/note.dart';
import 'models/post.dart';
import 'network_errors.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'sync.dart';

/// Database tunggal yang dipakai seluruh repository.
final notesDbProvider = FutureProvider<Database>((ref) => openNotesDb());

/// Seluruh akses key-value terpusat di repository ini.
final prefsRepositoryProvider =
    Provider<PrefsRepository>((ref) => PrefsRepository());

final lastOpenedProvider = FutureProvider<String?>(
  (ref) => ref.watch(prefsRepositoryProvider).getLastOpened(),
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

/// Toggle offline deterministik agar demo/testing tidak bergantung pada Wi-Fi.
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

/// Jumlah catatan yang belum tersinkron (derived dari daftar catatan).
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final notes = await ref.watch(notesProvider.future);
  return notes.where((note) => note.dirty).length;
});

/// Detail catatan dibaca langsung dari repository lokal (bukan state list),
/// sehingga halaman `/note/:id` tetap benar meski dibuka langsung.
final noteDetailProvider = FutureProvider.family<Note?, int>(
  (ref, id) => ref.watch(noteRepositoryProvider).fetchNote(id),
);

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

class PostsState {
  const PostsState({
    required this.posts,
    required this.fromCache,
    this.cachedAt,
    this.error,
  });

  final List<Post> posts;
  final bool fromCache;
  final DateTime? cachedAt;
  final Object? error;

  PostsState copyWith({
    List<Post>? posts,
    bool? fromCache,
    DateTime? cachedAt,
    Object? error,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      fromCache: fromCache ?? this.fromCache,
      cachedAt: cachedAt ?? this.cachedAt,
      error: error ?? this.error,
    );
  }
}

class PostsNotifier extends AsyncNotifier<PostsState> {
  @override
  Future<PostsState> build() async {
    final db = await ref.watch(notesDbProvider.future);
    final cached = await readCachedPosts(db);
    final cachedAt = await cachedPostsAt(db);
    // Cache-first: tampilkan cache lokal seketika bila ada.
    if (cached.isNotEmpty) {
      return PostsState(posts: cached, fromCache: true, cachedAt: cachedAt);
    }
    return _fetchAndCache(db);
  }

  Future<void> refresh() async {
    try {
      final db = await ref.read(notesDbProvider.future);
      state = AsyncData(await _fetchAndCache(db));
    } catch (e, st) {
      final previous = state.value;
      if (previous != null && previous.posts.isNotEmpty) {
        // Pertahankan cache yang sudah tampil, catat error refresh.
        state = AsyncData(previous.copyWith(error: e));
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  Future<PostsState> _fetchAndCache(Database db) async {
    if (ref.read(forceOfflineProvider)) {
      throw const OfflineException();
    }
    final posts = await ref.read(postRepositoryProvider).fetchPosts();
    await writeCachedPosts(db, posts);
    return PostsState(posts: posts, fromCache: false, cachedAt: DateTime.now());
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, PostsState>(
  PostsNotifier.new,
  retry: (retryCount, error) => null,
);
