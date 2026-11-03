// Punch terhadap backend sungguhan; lihat test/live/live.dart. Tiap run
// mencatat satu punch `kontrak` (aturan interval 60 detik: beri jeda antar run).
@Tags(['live'])
library;

import 'dart:io';

import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/clock/business_time.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/api_auth_repository.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/punch/data/api_punch_repository.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:flutter_test/flutter_test.dart';

import 'live.dart';

const _photo = 'test/live/fixtures/selfie-480x720.jpg';

void main() {
  setUpAll(enableRealHttp);

  Future<(ApiPunchRepository, String)> signIn(String login) async {
    final client = ApiClient(baseUrl: liveApi, tokens: MemoryTokenStore());
    final profile = await ApiAuthRepository(client).login(
      login: login,
      password: livePassword,
      deviceName: liveDevice('punch'),
    );
    return (ApiPunchRepository(client), profile.timezone);
  }

  test(
    'punch kontrak, punch kedua < 60 dtk ditolak, riwayat hari ini',
    () async {
      final (repo, zone) = await signIn('kontrak');
      final photo = File(_photo);
      // ignore: avoid_print
      print('foto uji ${(photo.lengthSync() / 1024).toStringAsFixed(1)} KB');

      final punch = await repo.create(
        EvidenceSubmission(
          photoPath: photo.path,
          latitude: -6.1754,
          longitude: 106.8272,
          accuracy: 12,
        ),
      );
      expect(punch.hasPhoto, isTrue);
      expect(punch.source, 'mobile');
      // ignore: avoid_print
      print(
        'punch ${punch.id} ${punch.status.name} "${punch.statusLabel}" '
        'pukul ${punch.punchedAt} (zona $zone)',
      );

      // Jam punch = jam dinding zona bisnis sekarang (selisih < 2 menit).
      final businessNow = wallClockIn(zone, DateTime.now());
      expect(
        punch.punchedAt.difference(businessNow).inSeconds.abs(),
        lessThan(120),
      );

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

      final today = await repo.list(businessNow);
      expect(today.map((p) => p.id), contains(punch.id));
    },
    skip: liveSkip,
  );

  test('kontrak.pegawai-nonaktif -> "Pegawai tidak aktif."', () async {
    final (repo, _) = await signIn('kontrak.pegawai-nonaktif');
    await expectLater(
      repo.create(EvidenceSubmission(photoPath: File(_photo).path)),
      throwsA(
        isA<RuleRejectedFailure>().having(
          (e) => e.message,
          'message',
          'Pegawai tidak aktif.',
        ),
      ),
    );
  }, skip: liveSkip);

  test(
    'bukti kosong terkirim; requires_photo -> galat per field photo',
    () async {
      final (repo, _) = await signIn('kontrak');
      // Server memvalidasi field lebih dulu (sebelum aturan interval).
      await expectLater(
        repo.create(const EvidenceSubmission()),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.first('photo'),
            'photo',
            isNotNull,
          ),
        ),
      );
    },
    skip: liveSkip,
  );
}
