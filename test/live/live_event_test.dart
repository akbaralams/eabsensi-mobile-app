// Event terhadap backend sungguhan; lihat test/live/live.dart. Butuh fixture
// segar (check-in "Apel Kontrak" hanya sekali per pegawai):
//   psql ... -f ../eabsensi-mobile-api/tests/contract/fixtures.sql
@Tags(['live'])
library;

import 'dart:io';

import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/api_auth_repository.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/events/data/api_event_repository.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:flutter_test/flutter_test.dart';

import 'live.dart';

void main() {
  setUpAll(enableRealHttp);

  test('check-in Apel Kontrak, lalu check-in kedua ditolak', () async {
    final client = ApiClient(baseUrl: liveApi, tokens: MemoryTokenStore());
    await ApiAuthRepository(client).login(
      login: 'kontrak',
      password: livePassword,
      deviceName: liveDevice('event'),
    );
    final repo = ApiEventRepository(client);

    final events = await repo.listToday();
    // ignore: avoid_print
    print(events.map((e) => '${e.id} ${e.name} ${e.checkedIn}').join('; '));
    expect(
      events.map((e) => e.name),
      isNot(contains('Apel Kontrak Department Lain')),
      reason: 'event department lain tidak terlihat',
    );
    final apel = events.singleWhere((e) => e.name == 'Apel Kontrak');
    expect(apel.checkedIn, isFalse, reason: 'muat ulang fixture dulu');

    final evidence = EvidenceSubmission(
      photoPath: File('test/live/fixtures/selfie-480x720.jpg').path,
      latitude: -6.1754,
      longitude: 106.8272,
      accuracy: 9,
    );
    final checkIn = await repo.checkIn(apel.id, evidence);
    expect(checkIn.eventId, apel.id);

    final after = await repo.listToday();
    expect(after.singleWhere((e) => e.id == apel.id).checkedIn, isTrue);

    await expectLater(
      repo.checkIn(apel.id, evidence),
      throwsA(
        isA<RuleRejectedFailure>().having(
          (e) => e.message,
          'message',
          'Anda sudah check-in di event ini.',
        ),
      ),
    );

    await expectLater(
      repo.checkIn(999999999, evidence),
      throwsA(isA<NotFoundFailure>()),
      reason: 'event tidak ada -> 404',
    );
  }, skip: liveSkip);
}
