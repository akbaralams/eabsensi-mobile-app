import 'dart:io';

import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/punch/data/api_punch_repository.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_http.dart';

Map<String, Object?> _punch(int id, String at, {String status = 'pending'}) => {
  'id': id,
  'punched_at': at,
  'source': 'mobile',
  'status': status,
  'status_label': status == 'pending' ? 'Menunggu persetujuan' : 'Disetujui',
  'has_photo': true,
};

void main() {
  late FakeAdapter http;
  late ApiPunchRepository repo;
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('punch_api_test');
    http = FakeAdapter((r, i) => jsonBody(200, {'data': <Object>[]}));
    repo = ApiPunchRepository(
      ApiClient(
        baseUrl: 'http://api.test/api',
        tokens: MemoryTokenStore('12|abc'),
        adapter: http,
      ),
    );
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test('GET /punches?date= memakai tanggal zona bisnis', () async {
    http.handler = (r, i) => jsonBody(200, {
      'data': [
        _punch(1, '2026-10-30T07:52:10+07:00', status: 'approved'),
        _punch(2, '2026-10-30T16:05:00+07:00'),
      ],
    });

    final list = await repo.list(DateTime(2026, 10, 30, 0, 30));

    expect(http.requests.single.options.uri.query, 'date=2026-10-30');
    expect(list.map((p) => p.punchedAt.hour), [7, 16]);
    expect(list.last.status, PunchStatus.pending);
  });

  test(
    'POST /punches multipart: foto, lokasi berpasangan, tanpa waktu',
    () async {
      final photo = File('${tmp.path}/foto.jpg')
        ..writeAsBytesSync(List<int>.filled(2048, 7));
      http.handler = (r, i) =>
          jsonBody(201, {'data': _punch(9, '2026-10-30T07:58:12+07:00')});

      final punch = await repo.create(
        EvidenceSubmission(
          photoPath: photo.path,
          latitude: -6.2,
          longitude: 106.8,
          accuracy: 12,
        ),
      );

      expect(punch.status, PunchStatus.pending);
      expect(punch.punchedAt.hour, 7);
      final r = http.requests.single;
      expect(r.path, '/api/punches');
      expect(r.options.contentType, startsWith('multipart/form-data'));
      final body = r.bodyText;
      expect(body, contains('name="photo"; filename="bukti.jpg"'));
      expect(body, contains('content-type: image/jpeg'));
      expect(body, contains('name="latitude"'));
      expect(body, contains('-6.2'));
      expect(body, contains('name="longitude"'));
      expect(body, contains('name="accuracy"'));
      expect(body, isNot(contains('punched_at')));
    },
  );

  test('lokasi tidak lengkap tidak dikirim (harus berpasangan)', () async {
    final photo = File('${tmp.path}/foto.jpg')..writeAsBytesSync([1, 2, 3]);
    http.handler = (r, i) =>
        jsonBody(201, {'data': _punch(9, '2026-10-30T07:58:12+07:00')});

    await repo.create(EvidenceSubmission(photoPath: photo.path, latitude: 1));

    final body = http.requests.single.bodyText;
    expect(body, isNot(contains('name="latitude"')));
    expect(body, isNot(contains('name="accuracy"')));
  });

  test(
    'bukti kosong (foto tidak wajib, lokasi ditolak) tetap terkirim',
    () async {
      http.handler = (r, i) =>
          jsonBody(201, {'data': _punch(9, '2026-10-30T07:58:12+07:00')});

      final punch = await repo.create(const EvidenceSubmission());

      expect(punch.id, 9);
      final r = http.requests.single;
      expect(r.path, '/api/punches');
      expect(r.options.method, 'POST');
      expect(r.options.contentType, startsWith('multipart/form-data'));
      expect(r.header('Authorization'), 'Bearer 12|abc');
    },
  );

  test('penolakan aturan ditampilkan apa adanya', () async {
    final photo = File('${tmp.path}/foto.jpg')..writeAsBytesSync([1, 2, 3]);
    http.handler = (r, i) => jsonBody(422, {
      'message': 'Tunggu 60 detik sebelum melakukan punch lagi.',
    });

    await expectLater(
      repo.create(EvidenceSubmission(photoPath: photo.path)),
      throwsA(
        isA<RuleRejectedFailure>().having(
          (e) => e.message,
          'message',
          'Tunggu 60 detik sebelum melakukan punch lagi.',
        ),
      ),
    );
  });

  test(
    'tanpa jaringan -> OfflineFailure (tidak ada antrean offline)',
    () async {
      http.handler = (r, i) => offline(r);
      await expectLater(
        repo.create(const EvidenceSubmission()),
        throwsA(isA<OfflineFailure>()),
      );
      final photo = File('${tmp.path}/foto.jpg')..writeAsBytesSync([1, 2, 3]);
      await expectLater(
        repo.create(EvidenceSubmission(photoPath: photo.path)),
        throwsA(isA<OfflineFailure>()),
      );
    },
  );
}
