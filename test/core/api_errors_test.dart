import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/api/mappers.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi_api/eabsensi_api.dart' as api;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_http.dart';

/// Pemetaan galat API-1, memakai contoh respons persis dari kontrak
/// (`api/openapi.yaml`).
void main() {
  late FakeAdapter http;
  late ApiClient client;

  setUp(() {
    http = FakeAdapter((r, i) => jsonBody(200, {'data': meJson()}));
    client = ApiClient(
      baseUrl: 'http://api.test/api',
      tokens: MemoryTokenStore('12|abc'),
      adapter: http,
    );
  });

  Future<Object> failureOf(int status, Object body, {String? retryAfter}) {
    http.handler = (r, i) => jsonBody(
      status,
      body,
      headers: {
        if (retryAfter != null) 'retry-after': [retryAfter],
      },
    );
    return client
        .send(
          () => client.punches.listPunches(),
          (r) => r is api.ListPunchesResponse200 ? r.body.data : null,
        )
        .then<Object>((_) => fail('harus gagal'), onError: (Object e) => e);
  }

  test(
    '401 Unauthenticated (token v1 tanpa refresh) -> sesi berakhir',
    () async {
      final e = await failureOf(401, {'message': 'Unauthenticated.'});
      expect(e, isA<UnauthenticatedFailure>());
    },
  );

  test(
    '422 kredensial -> RuleRejectedFailure dengan pesan apa adanya',
    () async {
      final e = await failureOf(422, {
        'message': 'Username atau kata sandi salah.',
      });
      expect(e, isA<RuleRejectedFailure>());
      expect((e as ApiFailure).message, 'Username atau kata sandi salah.');
    },
  );

  test('403 tanpa pegawai -> ForbiddenFailure dengan pesan kontrak', () async {
    final e = await failureOf(403, {
      'message': 'Akun ini belum terhubung ke data pegawai.',
    });
    expect(e, isA<ForbiddenFailure>());
    expect(
      (e as ApiFailure).message,
      'Akun ini belum terhubung ke data pegawai.',
    );
  });

  test('422 dengan errors.photo -> ValidationFailure per field', () async {
    final e = await failureOf(422, {
      'message': 'Foto wajib diunggah.',
      'errors': {
        'photo': ['Foto wajib diunggah.'],
      },
    });
    expect(e, isA<ValidationFailure>());
    expect((e as ValidationFailure).first('photo'), 'Foto wajib diunggah.');
  });

  test('429 Too Many Attempts dengan Retry-After: 42', () async {
    final e = await failureOf(429, {
      'message': 'Too Many Attempts.',
    }, retryAfter: '42');
    expect(e, isA<TooManyRequestsFailure>());
    expect(
      (e as TooManyRequestsFailure).retryAfter,
      const Duration(seconds: 42),
    );
    expect(e.message, contains('42 detik'));
  });

  test('413 -> "Ukuran foto terlalu besar." walau body bukan JSON', () async {
    http.handler = (r, i) => textBody(413, '<html>413</html>');
    final e = await client
        .send(
          () => client.punches.listPunches(),
          (r) => r is api.ListPunchesResponse200 ? r.body.data : null,
        )
        .then<Object>((_) => fail('harus gagal'), onError: (Object e) => e);
    expect((e as ApiFailure).message, 'Ukuran foto terlalu besar.');
  });

  test('503 -> server sibuk', () async {
    final e = await failureOf(503, {'message': 'Service Unavailable'});
    expect(
      (e as ApiFailure).message,
      'Server sedang sibuk. Coba lagi sebentar lagi.',
    );
  });

  test('404 -> NotFoundFailure dengan pesan umum', () async {
    final e = await failureOf(404, {'message': 'Not Found'});
    expect(e, isA<NotFoundFailure>());
  });

  test('tanpa jaringan -> OfflineFailure', () async {
    http.handler = (r, i) => offline(r);
    final e = await client
        .send(
          () => client.punches.listPunches(),
          (r) => r is api.ListPunchesResponse200 ? r.body.data : null,
        )
        .then<Object>((_) => fail('harus gagal'), onError: (Object e) => e);
    expect(e, isA<OfflineFailure>());
  });

  test('body bukan JSON -> UnknownFailure', () async {
    http.handler = (r, i) => textBody(422, 'galat server');
    final e = await client
        .send(
          () => client.punches.listPunches(),
          (r) => r is api.ListPunchesResponse200 ? r.body.data : null,
        )
        .then<Object>((_) => fail('harus gagal'), onError: (Object e) => e);
    expect(e, isA<UnknownFailure>());
    http.handler = (r, i) => textBody(200, 'bukan json', type: 'text/plain');
    final e2 = await client
        .send(
          () => client.punches.listPunches(),
          (r) => r is api.ListPunchesResponse200 ? r.body.data : null,
        )
        .then<Object>((_) => fail('harus gagal'), onError: (Object e) => e);
    expect(e2, isA<UnknownFailure>());
  });

  test(
    'setiap request membawa Accept JSON dan Bearer dari TokenStore',
    () async {
      http.handler = (r, i) => jsonBody(200, {'data': <Object>[]});
      await client.send(
        () => client.punches.listPunches(),
        (r) => r is api.ListPunchesResponse200 ? r.body.data : null,
      );
      final r = http.requests.single;
      expect(r.path, '/api/punches');
      expect(r.header('Accept'), 'application/json');
      expect(r.header('Authorization'), 'Bearer 12|abc');
    },
  );

  group('pemetaan ke domain', () {
    test('Me: username null dan employee null tidak membuat crash', () {
      final me = api.Me.fromJson(meJson(username: null, withEmployee: false));
      final profile = profileFromApi(me);
      expect(profile.username, 'Pegawai Kontrak');
      expect(profile.employee, isNull);
      expect(profile.requiresPhoto, isTrue);
      expect(profile.timezone, 'Asia/Jakarta');
    });

    test('Punch: jam dari offset string, bukan zona perangkat', () {
      Map<String, Object?> punch(String at) => {
        'id': 1,
        'punched_at': at,
        'source': 'mobile',
        'status': 'pending',
        'status_label': 'Menunggu persetujuan',
        'has_photo': true,
      };
      final wib = punchFromApi(
        api.Punch.fromJson(punch('2026-10-29T01:00:13+07:00')),
      );
      expect(
        [wib.punchedAt.day, wib.punchedAt.hour, wib.punchedAt.minute],
        [29, 1, 0],
      );
      final wita = punchFromApi(
        api.Punch.fromJson(punch('2026-10-29T07:58:12+08:00')),
      );
      expect(wita.punchedAt.hour, 7);
      expect(wita.statusLabel, 'Menunggu persetujuan');
    });
  });
}
