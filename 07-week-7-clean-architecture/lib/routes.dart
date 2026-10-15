import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/format.dart';
import 'features/notes/presentation/pages/note_detail_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';
import 'features/posts/presentation/pages/posts_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

/// Satu sumber kebenaran untuk seluruh path rute aplikasi.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String settings = '/settings';
  static const String posts = '/posts';
  static const String noteDetailPattern = '/note/:id';

  static String noteDetail(int id) => '/note/$id';
}

/// Router GoRouter. Parsing `:id` memakai fungsi murni `parseNoteId` dari
/// `core/format.dart` (Refactoring Challenge #2).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const NotesPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.posts,
        builder: (context, state) => const PostsPage(),
      ),
      GoRoute(
        path: AppRoutes.noteDetailPattern,
        builder: (context, state) {
          final id = parseNoteId(state.pathParameters['id']) ?? 0;
          return NoteDetailPage(noteId: id);
        },
      ),
    ],
  );
});
