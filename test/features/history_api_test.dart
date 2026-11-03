import 'package:eabsensi/core/clock/clock.dart';
import 'package:eabsensi/core/format/id_format.dart';
import 'package:eabsensi/features/history/data/api_history_repository.dart';
import 'package:eabsensi/features/history/domain/history.dart';
import 'package:eabsensi/features/history/presentation/history_providers.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:eabsensi/features/punch/presentation/punch_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Punch _p(int id, DateTime at, PunchStatus s, String label) => Punch(
  id: id,
  punchedAt: at,
  source: 'mobile',
  status: s,
  statusLabel: label,
  hasPhoto: true,
);

/// Punch server per tanggal; mencatat tanggal yang diminta.
class _ServerPunches implements PunchRepository {
  final requested = <String>[];

  @override
  Future<List<Punch>> list(DateTime date) async {
    requested.add(IdFormat.apiDate(date));
    if (date.day == 21) {
      return [
        _p(1, DateTime(2026, 10, 21, 7, 52), PunchStatus.approved, 'Disetujui'),
        _p(
          2,
          DateTime(2026, 10, 21, 16, 5),
          PunchStatus.pending,
          'Menunggu persetujuan',
        ),
      ];
    }
    return const [];
  }

  @override
  Future<Punch> create(EvidenceSubmission evidence) =>
      throw UnimplementedError();
}

void main() {
  test('hari dari punch server: ditolak tidak dihitung, tanpa klasifikasi', () {
    final d = DateTime(2026, 10, 21);
    expect(dayFromPunches(d, const []).status, DayStatus.none);
    final rejected = dayFromPunches(d, [
      _p(1, DateTime(2026, 10, 21, 8), PunchStatus.rejected, 'Ditolak'),
    ]);
    expect(rejected.status, DayStatus.none);
    expect(rejected.punches, hasLength(1), reason: 'tetap tampil di detail');
    final approved = dayFromPunches(d, [
      _p(1, DateTime(2026, 10, 21, 8, 15), PunchStatus.approved, 'Disetujui'),
    ]);
    expect(approved.status, DayStatus.present);
    expect(approved.checkIn, '08:15');
  });

  test('daftar bulan tidak memanggil server per hari', () async {
    final punches = _ServerPunches();
    final repo = ApiHistoryRepository(punches, now: () => testNow);
    final month = await repo.month(2026, 10);
    expect(punches.requested, isEmpty);
    expect(month.days, hasLength(25), reason: '1-25 Oktober, sebelum hari ini');
    expect(month.days.every((d) => d.status == DayStatus.unknown), isTrue);
    expect(repo.supportsClassification, isFalse);
  });

  testWidgets(
    'Riwayat dari server: hari dimuat saat dibuka, tanpa status karangan',
    (tester) async {
      final punches = _ServerPunches();
      await pumpApp(
        tester,
        overrides: [
          punchRepositoryProvider.overrideWithValue(punches),
          historyRepositoryProvider.overrideWith(
            (ref) => ApiHistoryRepository(
              punches,
              now: () => ref.read(clockProvider)(),
            ),
          ),
        ],
      );
      await tester.tap(find.text('Riwayat'));
      await settle(tester);

      // Hanya punch hari ini yang dimuat.
      expect(punches.requested.toSet(), {'2026-10-26'});
      expect(find.text('Terlambat'), findsNothing);
      expect(find.text('Tidak Hadir'), findsNothing);
      expect(find.byKey(const Key('history-no-summary')), findsOneWidget);
      expect(find.text('Belum dimuat'), findsWidgets);

      await tester.tap(find.bySemanticsLabel(RegExp('^Rabu 21 Oktober')));
      await settle(tester);

      expect(punches.requested.where((d) => d == '2026-10-21'), hasLength(1));
      expect(find.text('Menunggu persetujuan'), findsOneWidget);
      expect(find.text('07:52'), findsWidgets);
      expect(find.text('16:05'), findsWidgets);

      // Tutup sheet: baris 21 Oktober kini memakai data server.
      await tester.tapAt(const Offset(20, 20));
      await settle(tester);
      expect(find.text('07:52 - 16:05'), findsOneWidget);
    },
  );
}
