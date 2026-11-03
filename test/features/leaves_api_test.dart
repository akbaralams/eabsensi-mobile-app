import 'dart:convert';

import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/leaves/data/api_leave_repository.dart';
import 'package:eabsensi/features/leaves/domain/leave.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_http.dart';

Map<String, Object?> _leave(int id, String start, String end) => {
  'id': id,
  'type': 'Cuti',
  'attendance_status_id': 3,
  'start_date': start,
  'end_date': end,
  'reason': null,
  'status': 'pending',
  'status_label': 'Menunggu',
};

void main() {
  late FakeAdapter http;
  late ApiLeaveRepository repo;

  setUp(() {
    http = FakeAdapter((r, i) => jsonBody(200, {'data': <Object>[]}));
    repo = ApiLeaveRepository(
      ApiClient(
        baseUrl: 'http://api.test/api',
        tokens: MemoryTokenStore('12|abc'),
        adapter: http,
      ),
    );
  });

  test(
    'GET /leaves: data terbaru dulu, empat jenis bawaan berkategori benar',
    () async {
      http.handler = (r, i) => jsonBody(200, {
        'data': [
          _leave(1, '2026-09-01', '2026-09-02'),
          _leave(2, '2026-11-10', '2026-11-11'),
        ],
        'types': [
          {'id': 3, 'code': 'CUTI', 'name': 'Cuti'},
          {'id': 4, 'code': 'DINAS', 'name': 'Dinas luar'},
          {'id': 2, 'code': 'IZIN', 'name': 'Izin'},
          {'id': 1, 'code': 'SAKIT', 'name': 'Sakit'},
        ],
      });

      final o = await repo.load();

      expect(o.leaves.map((l) => l.id), [2, 1]);
      expect(o.leaves.first.status, LeaveStatus.pending);
      expect(
        {for (final t in o.types) t.code: t.category},
        {
          'CUTI': LeaveCategory.cuti,
          'DINAS': LeaveCategory.dinas,
          'IZIN': LeaveCategory.izin,
          'SAKIT': LeaveCategory.izin,
        },
      );
    },
  );

  test(
    'POST /leaves JSON: id jenis, tanggal YYYY-MM-DD, alasan opsional',
    () async {
      http.handler = (r, i) =>
          jsonBody(201, {'data': _leave(7, '2026-11-10', '2026-11-12')});

      final leave = await repo.create(
        LeaveDraft(
          attendanceStatusId: 3,
          startDate: DateTime(2026, 11, 10),
          endDate: DateTime(2026, 11, 12),
          reason: '  ',
        ),
      );

      expect(leave.id, 7);
      final r = http.requests.single;
      expect(r.path, '/api/leaves');
      expect(r.options.contentType, startsWith('application/json'));
      final body = jsonDecode(r.bodyText) as Map<String, Object?>;
      expect(body['attendance_status_id'], 3);
      expect(body['start_date'], '2026-11-10');
      expect(body['end_date'], '2026-11-12');
      expect(body['reason'], isNull);
    },
  );

  test('galat validasi per field dan pesan aturan apa adanya', () async {
    http.handler = (r, i) => jsonBody(422, {
      'message': 'Tanggal selesai tidak valid.',
      'errors': {
        'end_date': [
          'Tanggal selesai harus sama dengan atau setelah tanggal mulai.',
        ],
      },
    });
    final draft = LeaveDraft(
      attendanceStatusId: 3,
      startDate: DateTime(2026, 11, 10),
      endDate: DateTime(2026, 11, 9),
    );
    await expectLater(
      repo.create(draft),
      throwsA(
        isA<ValidationFailure>().having(
          (e) => e.first('end_date'),
          'end_date',
          isNotNull,
        ),
      ),
    );

    http.handler = (r, i) =>
        jsonBody(422, {'message': 'Rentang cuti maksimal 62 hari.'});
    await expectLater(
      repo.create(draft),
      throwsA(
        isA<RuleRejectedFailure>().having(
          (e) => e.message,
          'message',
          'Rentang cuti maksimal 62 hari.',
        ),
      ),
    );
  });

  test('field wajib kosong -> galat per field tanpa request', () async {
    await expectLater(
      repo.create(
        const LeaveDraft(
          attendanceStatusId: null,
          startDate: null,
          endDate: null,
        ),
      ),
      throwsA(
        isA<ValidationFailure>().having(
          (e) => e.errors.keys,
          'fields',
          containsAll(['attendance_status_id', 'start_date', 'end_date']),
        ),
      ),
    );
    expect(http.requests, isEmpty);
  });
}
