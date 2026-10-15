import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

/// Membangun Dio terpusat dengan dua perilaku:
/// 1. Setiap request menempelkan `Authorization: Bearer <access>`.
/// 2. Saat menerima 401, coba tukar refresh token tepat satu kali lalu ulangi
///    request. Bila refresh ikut gagal, sesi dibersihkan agar user login ulang.
Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode != 401) {
          return handler.next(e);
        }

        final refresh = await store.readRefresh();
        if (refresh == null) {
          return handler.next(e);
        }

        try {
          final renewed = await auth.refresh(refresh);
          await store.save(access: renewed, refresh: refresh);
          final retry = await dio.fetch(
            e.requestOptions..headers['Authorization'] = 'Bearer $renewed',
          );
          return handler.resolve(retry);
        } catch (_) {
          await store.clear();
          return handler.next(e);
        }
      },
    ),
  );

  return dio;
}
