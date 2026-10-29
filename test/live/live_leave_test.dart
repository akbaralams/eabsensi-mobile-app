// Cuti terhadap backend sungguhan; lihat test/live/live.dart. Membuat satu
// pengajuan `kontrak` (dihapus saat fixture dimuat ulang).
@Tags(['live'])
library;

import 'package:eabsensi/core/api/api_client.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/api_auth_repository.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/leaves/data/api_leave_repository.dart';
import 'package:eabsensi/features/leaves/domain/leave.dart';
import 'package:flutter_test/flutter_test.dart';

import 'live.dart';

void main() {
  setUpAll(enableRealHttp);

  test(
    'ajukan cuti, tumpang tindih dan > 62 hari ditolak apa adanya',
    () async {
      final client = ApiClient(baseUrl: liveApi, tokens: MemoryTokenStore());
      await ApiAuthRepository(client).login(
        login: 'kontrak',
        password: livePassword,
        deviceName: liveDevice('leave'),
      );
      final repo = ApiLeaveRepository(client);

      final overview = await repo.load();
      // ignore: avoid_print
      print(
        overview.types.map((t) => '${t.code}=${t.category.name}').join(', '),
      );
      final byCode = {for (final t in overview.types) t.code: t};
      expect(byCode['CUTI']?.category, LeaveCategory.cuti);
      expect(byCode['IZIN']?.category, LeaveCategory.izin);
      expect(byCode['SAKIT']?.category, LeaveCategory.izin);
      expect(byCode['DINAS']?.category, LeaveCategory.dinas);

      // Tanggal jauh di depan agar tidak bertabrakan dengan data lain.
      final start = DateTime(DateTime.now().year + 1, 2, 10);
      final draft = LeaveDraft(
        attendanceStatusId: byCode['CUTI']!.id,
        startDate: start,
        endDate: start.add(const Duration(days: 1)),
        reason: 'Uji aplikasi (test/live)',
      );
      final leave = await repo.create(draft);
      expect(leave.status, LeaveStatus.pending);
      // ignore: avoid_print
      print('cuti ${leave.id} "${leave.statusLabel}"');

      final after = await repo.load();
      expect(after.leaves.first.startDate.isBefore(start), isFalse);
      expect(after.leaves.map((l) => l.id), contains(leave.id));

      await expectLater(
        repo.create(draft),
        throwsA(
          isA<RuleRejectedFailure>().having(
            (e) => e.message,
            'message',
            'Pegawai sudah punya pengajuan yang menunggu atau disetujui pada '
                'tanggal tersebut.',
          ),
        ),
      );

      final far = DateTime(DateTime.now().year + 1, 6, 1);
      await expectLater(
        repo.create(
          LeaveDraft(
            attendanceStatusId: byCode['IZIN']!.id,
            startDate: far,
            endDate: far.add(const Duration(days: 62)),
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
    },
    skip: liveSkip,
  );
}
