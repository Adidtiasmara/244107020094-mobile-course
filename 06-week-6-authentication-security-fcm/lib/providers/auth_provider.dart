import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
  );
});

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

/// Status login. Sumber kebenarannya adalah keberadaan access token di
/// secure storage, bukan flag di memori, sehingga sesi bertahan setelah
/// aplikasi ditutup.
class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}

/// Token FCM terkini. `null` berarti belum diambil.
class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final fcmTokenProvider =
    NotifierProvider<FcmTokenNotifier, String?>(FcmTokenNotifier.new);

/// Status izin notifikasi: `null` belum ditanya, `true` diberikan, `false` ditolak.
class NotificationPermissionNotifier extends Notifier<bool?> {
  @override
  bool? build() => null;

  void set(bool? value) => state = value;
}

final notificationPermissionProvider =
    NotifierProvider<NotificationPermissionNotifier, bool?>(
  NotificationPermissionNotifier.new,
);

/// Status langganan topik broadcast pengumuman kampus.
class SubscribedTopicNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final subscribedTopicProvider =
    NotifierProvider<SubscribedTopicNotifier, bool>(
  SubscribedTopicNotifier.new,
);
