import '../../domain/entities/post.dart';

/// Model post: representasi JSON + mapping ke entity.
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
  });

  factory PostModel.fromJson(Map<String, Object?> json) {
    return PostModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      };

  Post toEntity() => Post(id: id, userId: userId, title: title, body: body);
}
