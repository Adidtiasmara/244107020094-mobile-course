# AI Challenge - Week 4

Dokumen ini mencatat prompt, output awal AI, verifikasi terhadap checklist
modul, perbaikan yang dilakukan, dan hasil testing untuk bagian **AI Prompt
Challenge** pada praktikum Networking & REST API.

## 1. Prompt yang digunakan

Prompt diambil persis dari modul:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

AI assistant yang dipakai: opencode (model `inferhub/cb/deepseek-v4.1-flash`).

## 2. Output awal AI

`lib/data/models/comment.dart` (versi awal):

```dart
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}
```

`lib/data/repositories/comment_repository.dart` (versi awal):

```dart
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
```

`lib/data/providers.dart` (versi awal, dipotong):

```dart
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  CommentsNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() async {
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}

final commentsProvider =
    AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(
        CommentsNotifier.new);
```

Unit test `fromJson` dengan field hilang juga dihasilkan, lalu dijalankan.

## 3. Verifikasi terhadap AI Verification Checklist

| Checklist modul | Temuan pada output awal | Tindakan |
| :--- | :--- | :--- |
| UI memanggil Dio langsung atau lewat repository? | Repository dipakai, UI hanya `ref.watch` provider | Aman |
| `fromJson` aman null? | Sudah memakai `as String? ?? ''` dan `(as num?)?.toInt() ?? 0` | Dipertahankan |
| Semua `DioExceptionType` dipetakan ke pesan pengguna? | AI hanya menangani `connectionError`, belum timeout/404/500 | Dilengkapi di `friendlyErrorMessage` (lihat bagian 4) |
| `baseUrl`/timeout terpusat di satu client? | AI menaruh timeout di dalam method repository, bukan di client | Dipindah ke `createDio()` agar satu sumber |
| Test menguji field hilang atau hanya happy path? | Sudah menguji field hilang | Ditambah edge case 404 dan provider sukses/gagal |
| `flutter analyze` dan `flutter test` lolos? | Lolos setelah perbaikan (lihat bagian 5) | `dart analyze` bersih, 10 test lulus |

## 4. Perbaikan yang dilakukan

### 4.1 Timeout dipindah ke client terpusat

Output awal menaruh timeout per-method. Modul meminta konfigurasi terpusat,
sehingga `connectTimeout`/`receiveTimeout` diletakkan di `createDio()` dan
repository hanya memanggil `_dio.get(...)`.

### 4.2 Pemetaan error diperluas dan diekstrak

AI hanya menangani `connectionError`. `friendlyErrorMessage` diperluas untuk
`connectionTimeout`/`sendTimeout`/`receiveTimeout`, `connectionError`, serta
`badResponse` (404, 401/403, dan 5xx), lalu diekstrak ke
`lib/data/network_errors.dart` (Refactoring Challenge poin 2) supaya dipakai
ulang oleh halaman paged, non-paged, dan detail.

### 4.3 Auto-retry Riverpod 3 dinonaktifkan

Riverpod 3 otomatis mengulang provider yang gagal (exponential backoff),
sehingga error tidak bertahan dan test provider menggantung. Perbaikan:
`retry: (retryCount, error) => null` pada `AsyncNotifierProvider`, agar retry
tetap manual lewat tombol **Coba lagi**.

### 4.4 Detail post + komentar (integrasi, bukan dari AI)

Repository komentar dipakai pada halaman detail post (`/post/:id`). Saat post
sudah dimuat dari daftar, data dikirim lewat `extra`; bila halaman dibuka
langsung, `postDetailProvider` mengambil ulang dari repository. Komentar
ditampilkan dengan empat state: loading, error + retry, empty, dan success.

### 4.5 Widget test dan fake repository

`FakePostRepository` dan `FakeCommentRepository` di `test/fakes.dart` tidak
pernah melakukan HTTP sungguhan. Widget test membangun `PagedPostPage` dengan
override repository palsu untuk memverifikasi data tampil tanpa internet.

## 5. Hasil testing

Perintah dan hasil (dijalankan di dalam `week4_api/`):

```text
$ dart analyze
Analyzing week4_api...
No issues found!

$ flutter test
00:00 +0: loading test/widget_test.dart
00:00 +0: test/comment_test.dart: Comment.fromJson aman terhadap field yang hilang
00:00 +1: test/post_test.dart: fromJson aman terhadap field yang hilang
00:00 +2: test/widget_test.dart: PostTile menampilkan judul, isi, dan id post
...
00:01 +9: test/widget_test.dart: PagedPostPage menampilkan data dari repository palsu
00:02 +10: All tests passed!
```

Catatan: `flutter analyze` tidak bisa dijalankan di environment ini karena
cache Flutter SDK lokal kehilangan folder `dev/`
(`PathNotFoundException: .../.cache/flutter_sdk/dev/`). Sebagai gantinya
dipakai `dart analyze` pada package yang sama, yang menganalisis `lib/` dan
`test/` dengan rules `flutter_lints` yang sama dan menghasilkan
`No issues found!`.

## 6. Keputusan teknis

- Memakai `AsyncNotifier` + `AsyncValue` (bukan tiga boolean) supaya loading,
  error, dan data tidak bisa berada di kondisi saling bertentangan.
- UI tidak pernah memanggil Dio langsung; semua akses data lewat repository
  dan provider. Ini menjaga UI tetap bisa diuji dengan repository palsu.
- Repository tidak menelan exception; exception dibiarkan naik agar provider
  mengubahnya menjadi `AsyncError`.
- Pagination memakai guard `if (state.isLoadingMore || !state.hasMore) return;`
  untuk mencegah request ganda dan berhenti saat data habis.
- `friendlyErrorMessage` diekstrak ke satu file agar pesan error konsisten di
  semua halaman.
