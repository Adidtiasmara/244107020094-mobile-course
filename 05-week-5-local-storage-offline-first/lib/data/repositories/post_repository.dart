import 'package:dio/dio.dart';

import '../models/post.dart';

class PostRepository {
  PostRepository(this._dio);

  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List<Object?>>('/posts');
    final data = response.data ?? const [];
    return data
        .whereType<Map<Object?, Object?>>()
        .map((e) => Post.fromJson(e.cast<String, Object?>()))
        .toList();
  }
}
