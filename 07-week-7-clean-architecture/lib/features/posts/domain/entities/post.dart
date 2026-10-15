/// Entity post (objek bisnis murni).
///
/// Tanpa mapping JSON — itu tugas `data/models/post_model.dart`.
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;
}
