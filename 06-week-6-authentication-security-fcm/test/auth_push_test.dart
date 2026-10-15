import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/messaging/push_service.dart';
import 'package:campus_notify/messaging/route_parser.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore extends TokenStore {
  FakeTokenStore({this.access, this.refresh});

  String? access;
  String? refresh;

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class FakeAuthRepository extends AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (password != 'rahasia123') {
      throw Exception('Email atau kata sandi tidak valid');
    }
    return AuthSession(
      access: 'access-$email',
      refresh: 'refresh-$email',
    );
  }
}

void main() {
  group('routeFromMessage', () {
    test('menangani route kosong dan tanpa garis miring', () {
      expect(routeFromMessage({}), AppRoutes.home);
      expect(routeFromMessage({'route': ''}), AppRoutes.home);
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('mengabaikan spasi di sekitar route', () {
      expect(routeFromMessage({'route': '  /debug  '}), AppRoutes.debug);
    });
  });

  group('announcementIdFromMessage', () {
    test('mengambil id dari field id', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(announcementIdFromMessage(data), '3');
    });

    test('jatuh ke segmen terakhir rute bila id tidak ada', () {
      expect(announcementIdFromMessage({'route': '/pengumuman/7'}), '7');
    });

    test('mengembalikan null untuk payload beranda', () {
      expect(announcementIdFromMessage({}), isNull);
      expect(announcementIdFromMessage({'route': '/'}), isNull);
    });
  });

  group('maskToken', () {
    test('menyisakan 12 karakter pertama lalu elipsis', () {
      expect(maskToken('abcdefghijklmnop'), 'abcdefghijkl...');
    });

    test('tidak memotong token yang lebih pendek dari batas', () {
      expect(maskToken('short'), 'short');
    });
  });

  group('AuthRepository', () {
    test('login menolak email tanpa @', () {
      final repository = AuthRepository();
      expect(
        () => repository.login(email: 'salah', password: 'rahasia123'),
        throwsException,
      );
    });

    test('login menolak kata sandi pendek', () {
      final repository = AuthRepository();
      expect(
        () => repository.login(email: 'a@b.com', password: '123'),
        throwsException,
      );
    });

    test('login menolak kata sandi yang salah', () {
      final repository = AuthRepository();
      expect(
        () => repository.login(email: 'a@b.com', password: 'salahsekali'),
        throwsException,
      );
    });

    test('login sukses mengembalikan pasangan access dan refresh', () async {
      final repository = AuthRepository();
      final session = await repository.login(
        email: 'mahasiswa@jti.polinema.ac.id',
        password: 'rahasia123',
      );
      expect(session.access, contains('mahasiswa@jti.polinema.ac.id'));
      expect(session.refresh, isNotEmpty);
    });

    test('refresh gagal bila refresh token kosong', () {
      final repository = AuthRepository();
      expect(() => repository.refresh(''), throwsException);
    });

    test('refresh sukses mengembalikan access token baru', () async {
      final repository = AuthRepository();
      final renewed = await repository.refresh('mock-refresh');
      expect(renewed, startsWith('mock-access-renewed-'));
    });
  });

  group('AuthNotifier', () {
    test('status login dibaca dari keberadaan access token', () async {
      final store = FakeTokenStore(access: 'ada');
      final container = ProviderContainer(
        overrides: [tokenStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      expect(await container.read(authStateProvider.future), isTrue);
    });

    test('login menyimpan token dan menandai status login', () async {
      final store = FakeTokenStore();
      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(authStateProvider.future), isFalse);

      await container
          .read(authStateProvider.notifier)
          .login('a@b.com', 'rahasia123');

      expect(container.read(authStateProvider).value, isTrue);
      expect(store.access, 'access-a@b.com');
      expect(store.refresh, 'refresh-a@b.com');
    });

    test('login gagal tidak menyimpan token', () async {
      final store = FakeTokenStore();
      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(authStateProvider.notifier)
          .login('a@b.com', 'salah');

      expect(container.read(authStateProvider).hasError, isTrue);
      expect(store.access, isNull);
    });

    test('logout membersihkan token dan memaksa login ulang', () async {
      final store = FakeTokenStore(access: 'ada', refresh: 'ada');
      final container = ProviderContainer(
        overrides: [tokenStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      expect(await container.read(authStateProvider.future), isTrue);

      await container.read(authStateProvider.notifier).logout();

      expect(store.access, isNull);
      expect(await container.read(authStateProvider.future), isFalse);
    });
  });
}
