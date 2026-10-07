import 'package:flutter/material.dart';
import '../data/models/post.dart';

class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    this.onTap,
    this.showBody = true,
  });

  final Post post;
  final VoidCallback? onTap;
  final bool showBody;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(post.id.toString())),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showBody
          ? Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
