import 'dart:convert';

import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/core/storage/preferences.dart';
import 'package:eabsensi/features/auth/data/api_auth_repository.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/auth/presentation/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_http.dart';

const _unauth = {'message': 'Unauthenticated.'};

void main() {
  late FakeAdapter http;
  late MemoryTokenStore tokens;
  late ApiClient client;
  late ApiAuthRepository repo;
  final now = DateTime.utc(2026, 10, 30, 3);

  AuthTokens v2(String access, {String refresh = 'r1', DateTime? expires}) =>
      AuthTokens(
        accessToken: access,
        accessExpiresAt: expires ?? now.add(const Duration(days: 7)),
        refreshToken: refresh,
        refreshExpiresAt: now.add(const Duration(days: 90)),
      );

  void setUpWith(AuthTokens? initial, FakeHandler handler) {
    http = FakeAdapter(handler);
    tokens = MemoryTokenStore.withTokens(initial);
    client = ApiClient(
      baseUrl: 'http://api.test/api',
      tokens: tokens,
      adapter: http,
    );
    repo = ApiAuthRepository(client, now: () => now);
  }

  Iterable<SeenRequest> refreshes() =>
      http.requests.where((r) => r.path == '/api/v2/auth/refresh');

  group('interceptor refresh token', () {
    test(
      '401 -> refresh sekali, lalu request diulang dengan token baru',
      () async {
        setUpWith(v2('a1'), (r, i) {
          if (r.path == '/api/v2/auth/refresh') {
            return jsonBody(200, tokenPairJson('a2', refresh: 'r2'));
          }
          return r.header('Authorization') == 'Bearer a2'
              ? jsonBody(200, {'data': meJson()})
              : jsonBody(401, _unauth);
        });

        final profile = await repo.fetchMe();

        expect(profile.username, 'kontrak');
        expect(refreshes(), hasLength(1));
        final sent = jsonDecode(refreshes().single.bodyText) as Map;
        expect(sent['refresh_token'], 'r1');
        expect(
          refreshes().single.header('Authorization'),
          isNull,
          reason: 'refresh token tidak dikirim sebagai Bearer',
        );
        final stored = (await tokens.readTokens())!;
        expect(stored.accessToken, 'a2');
        expect(stored.refreshToken, 'r2');
        expect(http.requests.map((r) => r.path), [
          '/api/me',
          '/api/v2/auth/refresh',
          '/api/me',
        ]);
      },
    );

    test(
      'refresh satu per satu: request serentak menunggu satu refresh',
      () async {
        setUpWith(v2('a1'), (r, i) async {
          if (r.path == '/api/v2/auth/refresh') {
            await Future<void>.delayed(const Duration(milliseconds: 30));
            return jsonBody(200, tokenPairJson('a2', refresh: 'r2'));
          }
          return r.header('Authorization') == 'Bearer a2'
              ? jsonBody(200, {'data': meJson()})
              : jsonBody(401, _unauth);
        });

        final results = await Future.wait([
          repo.fetchMe(),
          repo.fetchMe(),
          repo.fetchMe(),
        ]);

        expect(results, hasLength(3));
        expect(refreshes(), hasLength(1));
        expect(client.refresher.exchanges, 1);
      },
    );

    test(
      '401 kedua setelah refresh -> sesi berakhir (kembali ke login)',
      () async {
        setUpWith(v2('a1'), (r, i) {
          if (r.path == '/api/v2/auth/refresh') {
            return jsonBody(200, tokenPairJson('a2'));
          }
          return jsonBody(401, _unauth);
        });
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            tokenStoreProvider.overrideWithValue(tokens),
            authRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);
        // Sesi selesai dibangun dulu (tanpa token), baru token dipasang.
        final initial = await tokens.readTokens();
        await tokens.clear();
        await container.read(sessionProvider.future);
        await tokens.writeTokens(initial!);

        await expectLater(
          withSession(container.read, repo.fetchMe),
          throwsA(isA<UnauthenticatedFailure>()),
        );
        expect(refreshes(), hasLength(1), reason: 'refresh hanya sekali');
        expect(await tokens.readTokens(), isNull);
        expect(container.read(sessionProvider).value, isNull);
      },
    );

    test('refresh ditolak 401 -> token dihapus, sesi berakhir', () async {
      setUpWith(v2('a1'), (r, i) => jsonBody(401, _unauth));
      await expectLater(repo.fetchMe(), throwsA(isA<UnauthenticatedFailure>()));
      expect(await tokens.readTokens(), isNull);
    });

    test('refresh ditolak 403 -> pesan server dibawa ke layar login', () async {
      const msg = 'Akun ini belum terhubung ke data pegawai.';
      setUpWith(v2('a1'), (r, i) {
        if (r.path == '/api/v2/auth/refresh') {
          return jsonBody(403, {'message': msg});
        }
        return jsonBody(401, _unauth);
      });
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenStoreProvider.overrideWithValue(tokens),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      // Sesi selesai dibangun dulu (tanpa token), baru token dipasang.
      final initial = await tokens.readTokens();
      await tokens.clear();
      await container.read(sessionProvider.future);
      await tokens.writeTokens(initial!);

      final error = await withSession(
        container.read,
        repo.fetchMe,
      ).then<Object>((_) => fail('harus gagal'), onError: (Object e) => e);

      expect(error, isA<UnauthenticatedFailure>());
      expect((error as ApiFailure).message, msg);
      expect(container.read(sessionNoticeProvider), msg);
    });

    test('token v1 (tanpa refresh token): 401 langsung ke login', () async {
      setUpWith(
        const AuthTokens(accessToken: 'v1'),
        (r, i) => jsonBody(401, _unauth),
      );
      await expectLater(repo.fetchMe(), throwsA(isA<UnauthenticatedFailure>()));
      expect(refreshes(), isEmpty);
    });
  });

  group('login', () {
    test('v2 lebih dulu: token akses + refresh token disimpan', () async {
      setUpWith(null, (r, i) {
        expect(r.path, '/api/v2/auth/login');
        return jsonBody(200, {...tokenPairJson('a1'), 'user': meJson()});
      });

      final profile = await repo.login(
        login: 'kontrak',
        password: 'rahasia',
        deviceName: 'eabsensi-android-1234',
      );

      expect(profile.employee?.employeeNumber, '2010011004');
      final sent = jsonDecode(http.requests.single.bodyText) as Map;
      expect(sent, {
        'login': 'kontrak',
        'password': 'rahasia',
        'device_name': 'eabsensi-android-1234',
      });
      final stored = (await tokens.readTokens())!;
      expect(stored.refreshToken, 'r1');
      expect(stored.accessExpiresAt, isNotNull);
    });

    test(
      'v2 404 (backend Laravel) -> jatuh ke v1 tanpa refresh token',
      () async {
        setUpWith(null, (r, i) {
          if (r.path == '/api/v2/auth/login') {
            return jsonBody(404, {'message': 'Not Found'});
          }
          return jsonBody(200, {'token': '12|v1', 'user': meJson()});
        });

        await repo.login(login: 'kontrak', password: 'x', deviceName: 'd');

        expect(http.requests.map((r) => r.path), [
          '/api/v2/auth/login',
          '/api/auth/login',
        ]);
        final stored = (await tokens.readTokens())!;
        expect(stored.accessToken, '12|v1');
        expect(stored.canRefresh, isFalse);
      },
    );

    test('pesan galat kontrak diteruskan apa adanya', () async {
      setUpWith(
        null,
        (r, i) => jsonBody(422, {'message': 'Username atau kata sandi salah.'}),
      );
      await expectLater(
        repo.login(
          login: 'kontrak.akun-nonaktif',
          password: 'x',
          deviceName: 'd',
        ),
        throwsA(
          isA<RuleRejectedFailure>().having(
            (e) => e.message,
            'message',
            'Username atau kata sandi salah.',
          ),
        ),
      );
      expect(http.requests, hasLength(1), reason: 'tidak jatuh ke v1');
    });
  });

  group('saat aplikasi dibuka', () {
    test('sisa token < 1 hari -> refresh diam-diam', () async {
      setUpWith(
        v2('a1', expires: now.add(const Duration(hours: 5))),
        (r, i) => jsonBody(200, tokenPairJson('a2')),
      );
      await repo.resume();
      expect(refreshes(), hasLength(1));
      expect((await tokens.readTokens())!.accessToken, 'a2');
    });

    test('sisa token masih panjang -> tidak refresh', () async {
      setUpWith(v2('a1'), (r, i) => fail('tidak boleh ada request'));
      await repo.resume();
      expect(http.requests, isEmpty);
    });

    test(
      'offline saat refresh awal -> diabaikan, token lama dipakai',
      () async {
        setUpWith(
          v2('a1', expires: now.add(const Duration(hours: 1))),
          (r, i) => offline(r),
        );
        await repo.resume();
        expect((await tokens.readTokens())!.accessToken, 'a1');
      },
    );
  });

  group('keluar', () {
    test('token v2 -> /v2/auth/logout', () async {
      setUpWith(
        v2('a1'),
        (r, i) => jsonBody(200, {'message': 'Berhasil keluar.'}),
      );
      await repo.logout();
      expect(http.requests.single.path, '/api/v2/auth/logout');
      expect(http.requests.single.header('Authorization'), 'Bearer a1');
    });

    test('token v1 -> /auth/logout', () async {
      setUpWith(
        const AuthTokens(accessToken: 'v1'),
        (r, i) => jsonBody(200, {'message': 'Berhasil keluar.'}),
      );
      await repo.logout();
      expect(http.requests.single.path, '/api/auth/logout');
    });
  });
}
