import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/remote_auth_repository.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/events/data/remote_event_repository.dart';
import 'package:eabsensi/features/leaves/data/remote_leave_repository.dart';
import 'package:eabsensi/features/leaves/domain/leave.dart';
import 'package:eabsensi/features/punch/data/remote_punch_repository.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/stub_api.dart';

void main() {
  group('auth', () {
    test('login: tanpa Bearer, simpan token, profil dipetakan', () async {
      final adapter = stubReturning(200, {'token': '12|abc', 'user': meJson});
      final tokens = MemoryTokenStore('stale|token');
      final repo = RemoteAuthRepository(
        stubClient(adapter, tokens: tokens),
        tokens,
      );

      final profile = await repo.login(
        login: 'kontrak',
        password: 'rahasia123',
        deviceName: 'eabsensi-android-1234abcd',
      );

      expect(adapter.last.method, 'POST');
      expect(adapter.last.uri.toString(), 'http://test/api/auth/login');
      expect(adapter.last.headers['Accept'], 'application/json');
      expect(adapter.last.headers.containsKey('Authorization'), isFalse);
      expect(adapter.last.data, {
        'login': 'kontrak',
        'password': 'rahasia123',
        'device_name': 'eabsensi-android-1234abcd',
      });
      expect(await tokens.read(), '12|abc');
      expect(profile.username, 'kontrak');
      expect(profile.employee?.department, 'Dinas Contoh');
      expect(profile.requiresPhoto, isTrue);
      expect(profile.isSupervisor, isFalse);
    });

    test('login gagal tidak menyimpan token', () async {
      final adapter = stubReturning(422, {
        'message': 'Username atau kata sandi salah.',
      });
      final tokens = MemoryTokenStore();
      final repo = RemoteAuthRepository(
        stubClient(adapter, tokens: tokens),
        tokens,
      );
      await expectLater(
        repo.login(login: 'x', password: 'y', deviceName: 'd'),
        throwsA(
          isA<RuleRejectedFailure>().having(
            (e) => e.message,
            'message',
            'Username atau kata sandi salah.',
          ),
        ),
      );
      expect(await tokens.read(), isNull);
    });

    test('/me: Bearer dari penyimpanan aman; pegawai bisa null', () async {
      final adapter = stubReturning(200, {
        'data': {...meJson, 'employee': null},
      });
      final tokens = MemoryTokenStore('7|rahasia');
      final repo = RemoteAuthRepository(
        stubClient(adapter, tokens: tokens),
        tokens,
      );
      final profile = await repo.fetchMe();
      expect(adapter.last.uri.path, '/api/me');
      expect(adapter.last.headers['Authorization'], 'Bearer 7|rahasia');
      expect(profile.employee, isNull);
    });

    test('/me 401 -> UnauthenticatedFailure', () async {
      final tokens = MemoryTokenStore('7|rahasia');
      final repo = RemoteAuthRepository(
        stubClient(
          stubReturning(401, {'message': 'Unauthenticated.'}),
          tokens: tokens,
        ),
        tokens,
      );
      await expectLater(repo.fetchMe(), throwsA(isA<UnauthenticatedFailure>()));
    });

    test('logout memanggil POST /auth/logout', () async {
      final adapter = stubReturning(200, {'message': 'Berhasil keluar.'});
      final tokens = MemoryTokenStore('7|rahasia');
      await RemoteAuthRepository(
        stubClient(adapter, tokens: tokens),
        tokens,
      ).logout();
      expect(adapter.last.method, 'POST');
      expect(adapter.last.uri.path, '/api/auth/logout');
    });
  });

  group('punch', () {
    late Directory dir;
    late File photo;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('eabsensi_test');
      photo = File('${dir.path}/foto.jpg')..writeAsBytesSync([1, 2, 3, 4]);
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test(
      'list: query date berformat yyyy-MM-dd, waktu = jam dinding bisnis',
      () async {
        final adapter = stubReturning(200, {
          'data': [punchJson],
        });
        final punches = await RemotePunchRepository(stubClient(adapter).punch)
            .list(DateTime(2026, 10, 5, 13, 45));

        expect(adapter.last.queryParameters['date'], '2026-10-05');
        expect(punches.single.punchedAt, DateTime(2026, 10, 25, 7, 58, 12));
        expect(punches.single.status, PunchStatus.pending);
        expect(punches.single.source, 'mobile');
        expect(punches.single.statusLabel, 'Menunggu persetujuan');
      },
    );

    test('status tidak dikenal tidak terbaca sebagai disetujui', () async {
      final adapter = stubReturning(200, {
        'data': [
          {...punchJson, 'status': 'baru', 'source': 'iot'},
        ],
      });
      final p = (await RemotePunchRepository(
        stubClient(adapter).punch,
      ).list(DateTime(2026, 10, 25))).single;
      expect(p.status, PunchStatus.pending);
      expect(p.source, 'unknown');
    });

    test('create: multipart dengan foto JPEG dan lokasi berpasangan', () async {
      final adapter = stubReturning(201, {'data': punchJson});
      final punch = await RemotePunchRepository(stubClient(adapter).punch)
          .create(
            EvidenceSubmission(
              photoPath: photo.path,
              latitude: -6.2088,
              longitude: 106.8456,
              accuracy: 12,
            ),
          );

      final form = adapter.last.data as FormData;
      expect(adapter.last.method, 'POST');
      expect(adapter.last.uri.path, '/api/punches');
      expect(adapter.last.headers['Authorization'], 'Bearer 7|rahasia');
      expect(
        {for (final f in form.fields) f.key: f.value},
        {'latitude': '-6.2088', 'longitude': '106.8456', 'accuracy': '12'},
      );
      final file = form.files.single;
      expect(file.key, 'photo');
      expect(file.value.filename, 'foto.jpg');
      expect(file.value.contentType.toString(), 'image/jpeg');
      expect(file.value.length, 4);
      expect(punch.id, 5);
    });

    test(
      'create: PNG bertipe image/png; tanpa foto dan lokasi hanya form kosong',
      () async {
        final png = File('${dir.path}/a.PNG')..writeAsBytesSync([1]);
        final adapter = stubReturning(201, {'data': punchJson});
        final repo = RemotePunchRepository(stubClient(adapter).punch);

        await repo.create(EvidenceSubmission(photoPath: png.path));
        expect(
          (adapter.last.data as FormData).files.single.value.contentType
              .toString(),
          'image/png',
        );

        await repo.create(const EvidenceSubmission());
        final form = adapter.last.data as FormData;
        expect(form.fields, isEmpty);
        expect(form.files, isEmpty);
      },
    );

    test('create: latitude tanpa longitude tidak dikirim', () async {
      final adapter = stubReturning(201, {'data': punchJson});
      await RemotePunchRepository(stubClient(adapter).punch)
          .create(const EvidenceSubmission(latitude: -6.2, accuracy: 10));
      expect((adapter.last.data as FormData).fields, isEmpty);
    });

    test('create: pesan aturan "Tunggu 60 detik" apa adanya', () async {
      final adapter = stubReturning(422, {
        'message': 'Tunggu 60 detik sebelum melakukan punch lagi.',
      });
      await expectLater(
        RemotePunchRepository(stubClient(adapter).punch)
            .create(const EvidenceSubmission()),
        throwsA(
          isA<RuleRejectedFailure>().having(
            (e) => e.message,
            'message',
            'Tunggu 60 detik sebelum melakukan punch lagi.',
          ),
        ),
      );
    });

    test('create: foto wajib -> galat per field', () async {
      final adapter = stubReturning(422, {
        'message': 'The photo field is required.',
        'errors': {
          'photo': ['The photo field is required.'],
        },
      });
      await expectLater(
        RemotePunchRepository(stubClient(adapter).punch)
            .create(const EvidenceSubmission()),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.first('photo'),
            'photo',
            'The photo field is required.',
          ),
        ),
      );
    });
  });

  group('event', () {
    test('listToday memetakan tanggal dan jam', () async {
      final adapter = stubReturning(200, {
        'data': [
          {
            'id': 3,
            'name': 'Upacara Bendera',
            'event_date': '2026-10-28',
            'starts_at': '07:00',
            'ends_at': '09:00',
            'checked_in': false,
          },
        ],
      });
      final e = (await RemoteEventRepository(
        stubClient(adapter).event,
      ).listToday()).single;
      expect(adapter.last.uri.path, '/api/events');
      expect(e.eventDate, DateTime(2026, 10, 28));
      expect(e.startsAt, '07:00');
      expect(e.checkedIn, isFalse);
    });

    test('checkIn: id di path, multipart, waktu dari server', () async {
      final adapter = stubReturning(201, {
        'data': {'event_id': 3, 'checked_in_at': '2026-10-28T07:12:00+07:00'},
      });
      final result = await RemoteEventRepository(stubClient(adapter).event)
          .checkIn(
            3,
            const EvidenceSubmission(
              latitude: -6.2,
              longitude: 106.8,
              accuracy: 8,
            ),
          );
      expect(adapter.last.method, 'POST');
      expect(adapter.last.uri.path, '/api/events/3/check-in');
      expect(adapter.last.data, isA<FormData>());
      expect(result.eventId, 3);
      expect(result.checkedInAt, DateTime(2026, 10, 28, 7, 12));
    });

    test('checkIn: aturan event dan 404 dipetakan', () async {
      final rule = stubReturning(422, {
        'message': 'Anda sudah check-in di event ini.',
      });
      await expectLater(
        RemoteEventRepository(stubClient(rule).event)
            .checkIn(3, const EvidenceSubmission()),
        throwsA(isA<RuleRejectedFailure>()),
      );
      final missing = stubReturning(404, {'message': 'Not Found.'});
      await expectLater(
        RemoteEventRepository(stubClient(missing).event)
            .checkIn(99, const EvidenceSubmission()),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });

  group('cuti', () {
    const leaveJson = {
      'id': 31,
      'type': 'Cuti Tahunan',
      'attendance_status_id': 1,
      'start_date': '2026-11-10',
      'end_date': '2026-11-12',
      'reason': null,
      'status': 'pending',
      'status_label': 'Menunggu',
    };

    test('load: pengajuan dan jenis', () async {
      final adapter = stubReturning(200, {
        'data': [leaveJson],
        'types': [
          {'id': 1, 'code': 'C-TAHUNAN', 'name': 'Cuti Tahunan'},
        ],
      });
      final overview = await RemoteLeaveRepository(stubClient(adapter).cuti)
          .load();
      expect(overview.leaves.single.startDate, DateTime(2026, 11, 10));
      expect(overview.leaves.single.reason, isNull);
      expect(overview.leaves.single.status, LeaveStatus.pending);
      expect(overview.types.single.category, LeaveCategory.cuti);
    });

    test(
      'create: tanggal dikirim sebagai yyyy-MM-dd, alasan dipangkas',
      () async {
        final adapter = stubReturning(201, {
          'data': {...leaveJson, 'reason': 'Acara keluarga'},
        });
        final leave = await RemoteLeaveRepository(stubClient(adapter).cuti)
            .create(
              LeaveDraft(
                attendanceStatusId: 1,
                startDate: DateTime(2026, 11, 10, 15),
                endDate: DateTime(2026, 11, 12),
                reason: '  Acara keluarga ',
              ),
            );
        expect(adapter.last.uri.path, '/api/leaves');
        expect(adapter.last.data, {
          'attendance_status_id': 1,
          'start_date': '2026-11-10',
          'end_date': '2026-11-12',
          'reason': 'Acara keluarga',
        });
        expect(leave.reason, 'Acara keluarga');
      },
    );

    test('create: alasan kosong dikirim null', () async {
      final adapter = stubReturning(201, {'data': leaveJson});
      await RemoteLeaveRepository(stubClient(adapter).cuti).create(
        LeaveDraft(
          attendanceStatusId: 1,
          startDate: DateTime(2026, 11, 10),
          endDate: DateTime(2026, 11, 12),
          reason: '   ',
        ),
      );
      expect((adapter.last.data as Map)['reason'], isNull);
    });

    test(
      'create: field wajib kosong -> galat per field tanpa memanggil server',
      () async {
        final adapter = stubReturning(201, {'data': leaveJson});
        await expectLater(
          RemoteLeaveRepository(stubClient(adapter).cuti).create(
            const LeaveDraft(
              attendanceStatusId: null,
              startDate: null,
              endDate: null,
            ),
          ),
          throwsA(
            isA<ValidationFailure>()
                .having(
                  (e) => e.first('attendance_status_id'),
                  'jenis',
                  isNotNull,
                )
                .having((e) => e.first('start_date'), 'mulai', isNotNull)
                .having((e) => e.first('end_date'), 'selesai', isNotNull),
          ),
        );
        expect(adapter.requests, isEmpty);
      },
    );

    test('create: aturan 62 hari dan tumpang tindih apa adanya', () async {
      final adapter = stubReturning(422, {
        'message': 'Rentang cuti maksimal 62 hari.',
      });
      await expectLater(
        RemoteLeaveRepository(stubClient(adapter).cuti).create(
          LeaveDraft(
            attendanceStatusId: 1,
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 6, 1),
          ),
        ),
        throwsA(
          isA<RuleRejectedFailure>().having(
            (e) => e.message,
            'message',
            'Rentang cuti maksimal 62 hari.',
          ),
        ),
      );
    });
  });
}
