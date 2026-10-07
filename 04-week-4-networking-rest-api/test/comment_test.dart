import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/providers.dart';

import 'fakes.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang', () {
    final comment = Comment.fromJson({'id': 3});
    expect(comment.id, 3);
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('friendlyErrorMessage untuk bad response 404', () {
    final request = RequestOptions(path: '/posts/999');
    final err = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: request, statusCode: 404),
    );
    expect(friendlyErrorMessage(err), contains('404'));
  });

  test('commentsProvider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        commentRepositoryProvider.overrideWithValue(
          FakeCommentRepository(items: const [
            Comment(
              postId: 1,
              id: 1,
              name: 'Nama Pengomentar',
              email: 'a@b.c',
              body: 'Isi komentar',
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final comments = await container.read(commentsProvider(1).future);
    expect(comments.length, 1);
    expect(comments.single.name, 'Nama Pengomentar');
  });

  test('commentsProvider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        commentRepositoryProvider.overrideWithValue(
          FakeCommentRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(commentsProvider(1).future),
      throwsA(isA<DioException>()),
    );
  });
}
