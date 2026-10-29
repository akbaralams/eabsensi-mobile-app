// Uji terhadap backend sungguhan (bukan bagian `flutter test` biasa; dilewati
// tanpa LIVE_API). Data uji dari repo API: tests/contract/fixtures.sql.
//
//   flutter test test/live --dart-define=LIVE_API=http://127.0.0.1:8081/api
//   # refresh diam-diam (backend dengan MOBILE_ACCESS_TOKEN_TTL_MINUTES=2):
//   flutter test test/live/live_auth_test.dart --dart-define=LIVE_API=... \
//     --dart-define=LIVE_SLOW=true
@Tags(['live'])
library;

import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/api_auth_repository.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'live.dart';

void main() {
  setUpAll(enableRealHttp);

  ({ApiClient client, ApiAuthRepository repo, MemoryTokenStore tokens})
  fresh() {
    final tokens = MemoryTokenStore();
    final client = ApiClient(baseUrl: liveApi, tokens: tokens);
    return (client: client, repo: ApiAuthRepository(client), tokens: tokens);
  }

  test('login kontrak berhasil dan profil tampil', () async {
    final s = fresh();
    final profile = await s.repo.login(
      login: 'kontrak',
      password: livePassword,
      deviceName: liveDevice('auth'),
    );
    expect(profile.username, 'kontrak');
    expect(profile.employee, isNotNull);
    expect(profile.timezone, isNotEmpty);
    final me = await s.repo.fetchMe();
    expect(me.id, profile.id);
    final stored = (await s.tokens.readTokens())!;
    // ignore: avoid_print
    print(
      'backend ${stored.canRefresh ? 'v2 (refresh token)' : 'v1 (Laravel)'}; '
      'token berlaku sampai ${stored.accessExpiresAt}',
    );
    await s.repo.logout();
  }, skip: liveSkip);

  test('kontrak.tanpa-pegawai -> pesan kontrak apa adanya', () async {
    final s = fresh();
    await expectLater(
      s.repo.login(
        login: 'kontrak.tanpa-pegawai',
        password: livePassword,
        deviceName: liveDevice('auth'),
      ),
      throwsA(
        isA<ForbiddenFailure>().having(
          (e) => e.message,
          'message',
          'Akun ini belum terhubung ke data pegawai.',
        ),
      ),
    );
  }, skip: liveSkip);

  test('kontrak.akun-nonaktif -> pesan kontrak apa adanya', () async {
    final s = fresh();
    await expectLater(
      s.repo.login(
        login: 'kontrak.akun-nonaktif',
        password: livePassword,
        deviceName: liveDevice('auth'),
      ),
      throwsA(
        isA<RuleRejectedFailure>().having(
          (e) => e.message,
          'message',
          'Username atau kata sandi salah.',
        ),
      ),
    );
  }, skip: liveSkip);

  test(
    'token dicabut (login ulang perangkat yang sama) -> sesi berakhir',
    () async {
      final device = liveDevice('revoke');
      final a = fresh();
      await a.repo.login(
        login: 'kontrak',
        password: livePassword,
        deviceName: device,
      );
      final b = fresh();
      await b.repo.login(
        login: 'kontrak',
        password: livePassword,
        deviceName: device,
      );
      // Token dan refresh token A sudah dicabut oleh login B.
      await expectLater(
        a.repo.fetchMe(),
        throwsA(isA<UnauthenticatedFailure>()),
      );
      expect(await a.tokens.readTokens(), isNull);
      await b.repo.logout();
      await expectLater(
        b.repo.fetchMe(),
        throwsA(isA<UnauthenticatedFailure>()),
        reason: 'keluar mencabut token di server',
      );
    },
    skip: liveSkip,
  );

  test(
    'token akses kedaluwarsa (TTL 2 menit) -> tetap masuk setelah 3 menit',
    () async {
      final s = fresh();
      await s.repo.login(
        login: 'kontrak',
        password: livePassword,
        deviceName: liveDevice('ttl'),
      );
      final first = (await s.tokens.readTokens())!;
      await Future<void>.delayed(const Duration(minutes: 3));
      final me = await s.repo.fetchMe();
      expect(me.username, 'kontrak');
      final now = (await s.tokens.readTokens())!;
      expect(now.accessToken, isNot(first.accessToken));
      expect(s.client.refresher.exchanges, 1);
      await s.repo.logout();
    },
    skip: liveSkip ?? liveSlowSkip,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
