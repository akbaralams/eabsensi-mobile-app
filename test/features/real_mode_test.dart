import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/api/api_providers.dart';
import 'package:eabsensi/core/clock/clock.dart';
import 'package:eabsensi/features/auth/data/api_auth_repository.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/auth/presentation/session_controller.dart';
import 'package:eabsensi/features/events/data/api_event_repository.dart';
import 'package:eabsensi/features/events/presentation/event_providers.dart';
import 'package:eabsensi/features/history/data/api_history_repository.dart';
import 'package:eabsensi/features/history/presentation/history_providers.dart';
import 'package:eabsensi/features/leaves/data/api_leave_repository.dart';
import 'package:eabsensi/features/leaves/presentation/leave_providers.dart';
import 'package:eabsensi/features/punch/data/api_punch_repository.dart';
import 'package:eabsensi/features/punch/presentation/punch_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_http.dart';
import '../helpers/pump_app.dart';

/// Server palsu sesuai kontrak: punch tersimpan di memori.
FakeHandler _server(List<Map<String, Object?>> punches) => (r, i) {
  final me = meJson(requiresPhoto: false, requiresApproval: true);
  switch ((r.options.method, r.path)) {
    case ('POST', '/api/v2/auth/login'):
      return jsonBody(200, {...tokenPairJson('a1'), 'user': me});
    case ('GET', '/api/me'):
      return jsonBody(200, {'data': me});
    case ('GET', '/api/punches'):
      return jsonBody(200, {'data': punches});
    case ('POST', '/api/punches'):
      final p = {
        'id': punches.length + 1,
        'punched_at': '2026-10-26T09:41:07+07:00',
        'source': 'mobile',
        'status': 'pending',
        'status_label': 'Menunggu persetujuan',
        'has_photo': false,
      };
      punches.add(p);
      return jsonBody(201, {'data': p});
    case ('GET', '/api/events'):
      return jsonBody(200, {'data': <Object>[]});
    case ('POST', '/api/v2/auth/logout'):
      return jsonBody(200, {'message': 'Berhasil keluar.'});
  }
  return jsonBody(404, {'message': 'Not Found'});
};

/// Repository nyata (lapisan API) di atas HTTP palsu: memastikan kabel mode
/// nyata (USE_MOCK=false) dari layar sampai request.
List<Override> _realMode(FakeAdapter http) => [
  apiClientProvider.overrideWith(
    (ref) => ApiClient(
      baseUrl: 'http://api.test/api',
      tokens: ref.watch(tokenStoreProvider),
      adapter: http,
    ),
  ),
  authRepositoryProvider.overrideWith(
    (ref) => ApiAuthRepository(ref.watch(apiClientProvider)),
  ),
  punchRepositoryProvider.overrideWith(
    (ref) => ApiPunchRepository(ref.watch(apiClientProvider)),
  ),
  eventRepositoryProvider.overrideWith(
    (ref) => ApiEventRepository(ref.watch(apiClientProvider)),
  ),
  leaveRepositoryProvider.overrideWith(
    (ref) => ApiLeaveRepository(ref.watch(apiClientProvider)),
  ),
  historyRepositoryProvider.overrideWith(
    (ref) => ApiHistoryRepository(
      ref.watch(punchRepositoryProvider),
      now: () => ref.read(clockProvider)(),
    ),
  ),
];

void main() {
  testWidgets('mode nyata: login v2, beranda dari /me, Check In, keluar', (
    tester,
  ) async {
    final punches = <Map<String, Object?>>[];
    final http = FakeAdapter(_server(punches));
    final container = await pumpApp(
      tester,
      signedIn: false,
      overrides: _realMode(http),
    );

    await tester.enterText(find.byKey(const Key('login-field')), 'kontrak');
    await tester.enterText(find.byKey(const Key('password-field')), 'rahasia');
    await tester.tap(find.text('Masuk'));
    await settle(tester);

    expect(find.text('Pegawai Kontrak'), findsWidgets);
    expect(http.requests.first.path, '/api/v2/auth/login');
    final tokens = await container.read(tokenStoreProvider).readTokens();
    expect(tokens?.refreshToken, 'r1');

    // requires_photo false: tanpa kamera; lokasi dikirim berpasangan.
    await tester.tap(find.text('Check In').first);
    await settle(tester);
    await tester.tap(find.text('Konfirmasi Check In'));
    await settle(tester);

    final post = http.requests.lastWhere((r) => r.options.method == 'POST');
    expect(post.path, '/api/punches');
    expect(post.bodyText, contains('name="latitude"'));
    expect(post.bodyText, isNot(contains('name="photo"')));
    expect(find.text('Menunggu atasan'), findsOneWidget);
    expect(find.text('09:41'), findsOneWidget);

    await tester.tap(find.text('Kembali ke Beranda'));
    await settle(tester);
    expect(find.text('Menunggu persetujuan'), findsOneWidget);

    // Keluar: token v2 dicabut di server lalu dihapus di perangkat.
    // Future Dio berjalan di jam palsu test: pompa sambil menunggu.
    final loggingOut = container.read(sessionProvider.notifier).logout();
    await settle(tester);
    await loggingOut;
    await settle(tester);
    expect(http.requests.last.path, '/api/v2/auth/logout');
    expect(await container.read(tokenStoreProvider).readTokens(), isNull);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('mode nyata: token dicabut (401, refresh 401) -> layar login', (
    tester,
  ) async {
    final http = FakeAdapter(
      (r, i) => jsonBody(401, {'message': 'Unauthenticated.'}),
    );
    await pumpApp(
      tester,
      overrides: _realMode(http),
      tokens: MemoryTokenStore.withTokens(
        AuthTokens(
          accessToken: 'a1',
          accessExpiresAt: DateTime(2026, 11, 2),
          refreshToken: 'r1',
        ),
      ),
    );
    expect(find.text('Masuk'), findsOneWidget);
    expect(
      http.requests.map((r) => r.path),
      containsAllInOrder(['/api/me', '/api/v2/auth/refresh']),
    );
  });
}
