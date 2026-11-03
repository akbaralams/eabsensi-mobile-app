import 'dart:io';

import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/mock/mock_env.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/events/data/api_event_repository.dart';
import 'package:eabsensi/features/events/data/mock_event_repository.dart';
import 'package:eabsensi/features/events/domain/event_item.dart';
import 'package:eabsensi/features/events/presentation/event_providers.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_http.dart';
import '../helpers/pump_app.dart';

/// Event yang dihapus setelah daftar dimuat: check-in 404.
class _GoneEventRepository implements EventRepository {
  _GoneEventRepository(this._inner);

  final EventRepository _inner;
  int loads = 0;

  @override
  Future<List<EventItem>> listToday() {
    loads++;
    return _inner.listToday();
  }

  @override
  Future<EventCheckIn> checkIn(int eventId, EvidenceSubmission evidence) =>
      Future.error(const NotFoundFailure());
}

void main() {
  group('ApiEventRepository', () {
    late FakeAdapter http;
    late ApiEventRepository repo;

    setUp(() {
      http = FakeAdapter((r, i) => jsonBody(200, {'data': <Object>[]}));
      repo = ApiEventRepository(
        ApiClient(
          baseUrl: 'http://api.test/api',
          tokens: MemoryTokenStore('12|abc'),
          adapter: http,
        ),
      );
    });

    test('GET /events dipetakan ke domain', () async {
      http.handler = (r, i) => jsonBody(200, {
        'data': [
          {
            'id': 5,
            'name': 'Apel Kontrak',
            'event_date': '2026-10-30',
            'starts_at': '00:00',
            'ends_at': '23:59',
            'checked_in': false,
          },
        ],
      });
      final events = await repo.listToday();
      expect(events.single.name, 'Apel Kontrak');
      expect(events.single.eventDate, DateTime(2026, 10, 30));
      expect(events.single.checkedIn, isFalse);
    });

    test('check-in multipart ke /events/{id}/check-in', () async {
      final dir = Directory.systemTemp.createTempSync('event_api_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final photo = File('${dir.path}/f.jpg')..writeAsBytesSync([1, 2, 3]);
      http.handler = (r, i) => jsonBody(201, {
        'data': {'event_id': 5, 'checked_in_at': '2026-10-30T07:05:00+07:00'},
      });

      final c = await repo.checkIn(
        5,
        EvidenceSubmission(photoPath: photo.path, latitude: 1, longitude: 2),
      );

      expect(c.eventId, 5);
      expect(c.checkedInAt.hour, 7);
      final r = http.requests.single;
      expect(r.path, '/api/events/5/check-in');
      expect(r.bodyText, contains('name="photo"'));
    });

    test('404 (event dihapus) -> NotFoundFailure', () async {
      http.handler = (r, i) => jsonBody(404, {'message': 'Not Found'});
      await expectLater(
        repo.checkIn(5, const EvidenceSubmission()),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  testWidgets('check-in 404: pesan singkat dan daftar event dimuat ulang', (
    tester,
  ) async {
    late _GoneEventRepository gone;
    await pumpApp(
      tester,
      overrides: [
        eventRepositoryProvider.overrideWith((ref) {
          return gone = _GoneEventRepository(
            MockEventRepository(ref.watch(mockEnvProvider)),
          );
        }),
      ],
    );
    await tester.tap(find.text('Upacara'));
    await settle(tester);
    final before = gone.loads;

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('event-1')),
        matching: find.text('Check-in'),
      ),
    );
    await settle(tester);
    await tester.tap(find.textContaining('Konfirmasi'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('shutter')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('submit-photo')));
    await settle(tester);

    expect(find.text('Event tidak tersedia'), findsOneWidget);
    await tester.tap(find.text('Lihat daftar event'));
    await settle(tester);
    expect(find.text('Event Hari Ini'), findsOneWidget);
    expect(gone.loads, greaterThan(before));
  });
}
