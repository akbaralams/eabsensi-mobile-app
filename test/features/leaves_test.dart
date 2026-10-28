import 'package:eabsensi/core/mock/mock_env.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/leaves/data/mock_leave_repository.dart';
import 'package:eabsensi/features/leaves/domain/leave.dart';
import 'package:eabsensi/features/leaves/presentation/leave_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

class _RejectingRepo implements LeaveRepository {
  _RejectingRepo(this.failure);

  final ApiFailure failure;

  @override
  Future<LeaveOverview> load() async =>
      const LeaveOverview(leaves: [], types: MockLeaveRepository.types);

  @override
  Future<Leave> create(LeaveDraft draft) async => throw failure;
}

Future<void> _openLeaves(WidgetTester tester) async {
  await tester.tap(find.text('Cuti/Izin'));
  await settle(tester);
}

Future<void> _pickType(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const Key('leave-type')));
  await settle(tester);
  await tester.tap(find.text(name).last);
  await settle(tester);
}

Future<void> _pickDay(WidgetTester tester, Key field, String day) async {
  await tester.tap(find.byKey(field));
  await settle(tester);
  await tester.tap(find.text(day).last);
  await tester.pump();
  await tester.tap(
    find
        .descendant(of: find.byType(Dialog), matching: find.byType(TextButton))
        .last,
  );
  await settle(tester);
}

Future<void> _submit(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await settle(tester);
}

MockEnv _env() => MockEnv(
  tokens: MemoryTokenStore('t'),
  scenario: () => const MockScenario(),
  now: () => testNow,
  latency: Duration.zero,
);

void main() {
  testWidgets('kosong: galat validasi per field', (tester) async {
    await pumpApp(tester);
    await _openLeaves(tester);
    await _submit(tester, 'Ajukan Cuti');
    expect(find.text('Jenis pengajuan wajib dipilih.'), findsOneWidget);
    expect(find.text('Tanggal mulai wajib diisi.'), findsOneWidget);
    expect(find.text('Tanggal selesai wajib diisi.'), findsOneWidget);
  });

  testWidgets('ajukan cuti: toast dan muncul di Pengajuan terakhir', (
    tester,
  ) async {
    await pumpApp(tester);
    await _openLeaves(tester);
    await _pickType(tester, 'Cuti Tahunan');
    await _pickDay(tester, const Key('leave-start'), '27');
    await _pickDay(tester, const Key('leave-end'), '28');
    expect(find.text('2 hari · batas satu pengajuan 62 hari'), findsOneWidget);

    await _submit(tester, 'Ajukan Cuti');
    expect(find.text('Pengajuan terkirim, menunggu atasan'), findsOneWidget);
    // Seed (menunggu) + pengajuan baru.
    expect(find.text('Cuti Tahunan'), findsNWidgets(2));
    expect(find.text('Menunggu'), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('422 aturan: pesan ditampilkan apa adanya di kotak aturan', (
    tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [
        leaveRepositoryProvider.overrideWithValue(
          _RejectingRepo(
            const RuleRejectedFailure('Rentang cuti maksimal 62 hari.'),
          ),
        ),
      ],
    );
    await _openLeaves(tester);
    await _pickType(tester, 'Cuti Tahunan');
    await _pickDay(tester, const Key('leave-start'), '27');
    await _pickDay(tester, const Key('leave-end'), '28');
    await _submit(tester, 'Ajukan Cuti');
    expect(find.byKey(const Key('rule-box')), findsOneWidget);
    expect(find.text('Rentang cuti maksimal 62 hari.'), findsOneWidget);
  });

  testWidgets('422 validasi: pesan per field dari errors', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        leaveRepositoryProvider.overrideWithValue(
          _RejectingRepo(
            const ValidationFailure('Data yang diberikan tidak valid.', {
              'reason': ['Alasan terlalu panjang.'],
            }),
          ),
        ),
      ],
    );
    await _openLeaves(tester);
    await _pickType(tester, 'Cuti Tahunan');
    await _pickDay(tester, const Key('leave-start'), '27');
    await _pickDay(tester, const Key('leave-end'), '28');
    await _submit(tester, 'Ajukan Cuti');
    expect(find.text('Alasan terlalu panjang.'), findsOneWidget);
    expect(find.byKey(const Key('rule-box')), findsNothing);
  });

  testWidgets('kategori mengubah daftar jenis', (tester) async {
    await pumpApp(tester);
    await _openLeaves(tester);
    await tester.tap(find.text('Dinas Luar').first);
    await settle(tester);
    await tester.tap(find.byKey(const Key('leave-type')));
    await settle(tester);
    final sheet = find.byType(BottomSheet);
    expect(
      find.descendant(of: sheet, matching: find.text('Dinas Luar Dalam Kota')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Cuti Tahunan')),
      findsNothing,
    );
  });

  group('aturan kontrak (mock)', () {
    test('rentang lebih dari 62 hari ditolak', () async {
      final repo = MockLeaveRepository(_env());
      expect(
        () => repo.create(
          LeaveDraft(
            attendanceStatusId: 1,
            startDate: DateTime(2027, 1, 1),
            endDate: DateTime(2027, 3, 5),
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

    test('tumpang tindih dengan pengajuan aktif ditolak', () async {
      final repo = MockLeaveRepository(_env());
      final seed = (await repo.load()).leaves.first;
      expect(
        () => repo.create(
          LeaveDraft(
            attendanceStatusId: 1,
            startDate: seed.startDate,
            endDate: seed.startDate,
          ),
        ),
        throwsA(
          isA<RuleRejectedFailure>().having(
            (e) => e.message,
            'message',
            'Pegawai sudah punya pengajuan yang menunggu atau disetujui pada tanggal tersebut.',
          ),
        ),
      );
    });

    test('selesai sebelum mulai: galat validasi end_date', () async {
      final repo = MockLeaveRepository(_env());
      expect(
        () => repo.create(
          LeaveDraft(
            attendanceStatusId: 1,
            startDate: DateTime(2026, 12, 5),
            endDate: DateTime(2026, 12, 1),
          ),
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (e) => e.first('end_date'),
            'end_date',
            isNotNull,
          ),
        ),
      );
    });

    test('kategori dari kode jenis', () {
      expect(LeaveCategory.forCode('C-BESAR'), LeaveCategory.cuti);
      expect(LeaveCategory.forCode('I-SAKIT'), LeaveCategory.izin);
      expect(LeaveCategory.forCode('D-LUAR'), LeaveCategory.dinas);
      expect(LeaveCategory.forCode('X-LAIN'), LeaveCategory.lainnya);
    });
  });
}
