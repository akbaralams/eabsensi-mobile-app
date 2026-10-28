import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eabsensi/core/network/api_error_mapper.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/stub_api.dart';

/// Contoh respons diambil dari kontrak (`docs/openapi/mobile-api.yaml`).
Future<Object?> _get(StubAdapter adapter) =>
    apiCall(() async => (await stubDio(adapter).get<Object?>('/me')).data);

Future<ApiFailure> _failure(StubAdapter adapter) async {
  try {
    await _get(adapter);
  } on ApiFailure catch (e) {
    return e;
  }
  fail('Seharusnya melempar ApiFailure');
}

void main() {
  test('200 dikembalikan apa adanya', () async {
    final data = await _get(stubReturning(200, {'data': meJson}));
    expect((data! as Map)['data'], isNotNull);
  });

  test('401 -> UnauthenticatedFailure', () async {
    final f = await _failure(
      stubReturning(401, {'message': 'Unauthenticated.'}),
    );
    expect(f, isA<UnauthenticatedFailure>());
  });

  test('403 -> ForbiddenFailure dengan pesan server apa adanya', () async {
    final f = await _failure(
      stubReturning(403, {
        'message': 'Akun ini belum terhubung ke data pegawai.',
      }),
    );
    expect(f, isA<ForbiddenFailure>());
    expect(f.message, 'Akun ini belum terhubung ke data pegawai.');
  });

  test('422 message saja -> RuleRejectedFailure, pesan apa adanya', () async {
    final f = await _failure(
      stubReturning(422, {
        'message': 'Tunggu 60 detik sebelum melakukan punch lagi.',
      }),
    );
    expect(f, isA<RuleRejectedFailure>());
    expect(f.message, 'Tunggu 60 detik sebelum melakukan punch lagi.');
  });

  test('422 dengan errors -> ValidationFailure per field', () async {
    final f = await _failure(
      stubReturning(422, {
        'message': 'The photo field is required.',
        'errors': {
          'photo': ['The photo field is required.'],
          'latitude': [
            'The latitude field is required when longitude is present.',
          ],
        },
      }),
    );
    expect(f, isA<ValidationFailure>());
    final v = f as ValidationFailure;
    expect(v.first('photo'), 'The photo field is required.');
    expect(v.first('latitude'), contains('latitude'));
    expect(v.first('longitude'), isNull);
  });

  test(
    '422 dengan errors kosong diperlakukan sebagai penolakan aturan',
    () async {
      final f = await _failure(
        stubReturning(422, {
          'message': 'Periode bulan ini sudah ditutup.',
          'errors': <String, Object?>{},
        }),
      );
      expect(f, isA<RuleRejectedFailure>());
    },
  );

  test('429 -> TooManyRequestsFailure', () async {
    final f = await _failure(
      stubReturning(429, {'message': 'Too Many Attempts.'}),
    );
    expect(f, isA<TooManyRequestsFailure>());
  });

  test('404 membawa pesan server; 5xx memakai pesan umum', () async {
    final nf = await _failure(
      stubReturning(404, {'message': 'Data tidak ditemukan.'}),
    );
    expect(nf, isA<UnknownFailure>());
    expect(nf.message, 'Data tidak ditemukan.');

    final server = await _failure(
      StubAdapter(
        (_) async => ResponseBody.fromString(
          '<html>Server Error</html>',
          500,
          headers: {
            Headers.contentTypeHeader: ['text/html'],
          },
        ),
      ),
    );
    expect(server, isA<UnknownFailure>());
    expect(server.message, isNot(contains('html')));
  });

  test('tanpa jaringan dan timeout -> OfflineFailure', () async {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      final f = await _failure(
        StubAdapter(
          (o) async => throw DioException(requestOptions: o, type: type),
        ),
      );
      expect(f, isA<OfflineFailure>(), reason: '$type');
    }
    final socket = await _failure(
      StubAdapter(
        (o) async => throw DioException(
          requestOptions: o,
          error: const SocketException('Network is unreachable'),
        ),
      ),
    );
    expect(socket, isA<OfflineFailure>());
  });

  test(
    'respons tidak sesuai kontrak menjadi UnknownFailure, bukan crash',
    () async {
      final result = apiCall<int>(() async => int.parse('bukan angka'));
      await expectLater(result, throwsA(isA<UnknownFailure>()));
    },
  );
}
