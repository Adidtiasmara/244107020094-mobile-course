import 'package:dio/dio.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';
import 'package:week4_api/data/repositories/post_repository.dart';

/// Repository palsu: tidak pernah melakukan HTTP sungguhan.
class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false}) : super(Dio());

  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }

  @override
  Future<Post> fetchPost(int id) async {
    final all = items ?? const <Post>[];
    for (final post in all) {
      if (post.id == id) return post;
    }
    final request = RequestOptions(path: '/posts/$id');
    throw DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: request, statusCode: 404),
    );
  }

  @override
  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async {
    return fetchPosts();
  }
}

class FakeCommentRepository extends CommentRepository {
  FakeCommentRepository({this.items, this.throwError = false}) : super(Dio());

  final List<Comment>? items;
  final bool throwError;

  @override
  Future<List<Comment>> fetchComments(int postId) async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }
}
