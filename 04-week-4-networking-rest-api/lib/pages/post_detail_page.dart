import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({
    super.key,
    required this.postId,
    this.initialPost,
  });

  final int postId;
  final Post? initialPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cached = initialPost;
    if (cached != null) {
      return _DetailView(post: cached);
    }

    final detailAsync = ref.watch(postDetailProvider(postId));
    return detailAsync.when(
      loading: () => const Scaffold(
        appBar: _DetailAppBar(),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: const _DetailAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyErrorMessage(err),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(postDetailProvider(postId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (post) => _DetailView(post: post),
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) =>
      AppBar(title: const Text('Detail Post'));
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsProvider(post.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const _DetailAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(post.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Post #${post.id} · User ${post.userId}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(post.body, style: theme.textTheme.bodyLarge),
          const Divider(height: 40),
          Text('Komentar', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          commentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friendlyErrorMessage(err)),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.invalidate(commentsProvider(post.id)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return const Text('Belum ada komentar.');
              }
              return Column(
                children: [
                  for (final comment in comments)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(comment.name),
                        subtitle: Text(comment.body),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
