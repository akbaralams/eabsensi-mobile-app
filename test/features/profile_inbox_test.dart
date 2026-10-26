import 'package:eabsensi/core/design/design.dart';
import 'package:eabsensi/core/format/id_format.dart';
import 'package:eabsensi/features/home/presentation/attendance_summary.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Punch _punch(int id, DateTime at, PunchStatus s) => Punch(
  id: id,
  punchedAt: at,
  source: 'mobile',
  status: s,
  statusLabel: s.name,
  hasPhoto: true,
);

void main() {
  group('profil', () {
    testWidgets('identitas dari /me dan pilihan mode gelap tersimpan', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.text('Profil').last);
      await settle(tester);

      expect(find.text('Andi Setiawan'), findsOneWidget);
      expect(find.text('Nomor pegawai 2010011004'), findsOneWidget);
      expect(find.text('Dinas Komunikasi dan Informatika'), findsOneWidget);

      await tester.tap(find.text('Mode Gelap'));
      await settle(tester);
      expect(find.text('Mode tampilan'), findsOneWidget);
      await tester.tap(find.text('Gelap'));
      await settle(tester);

      final context = tester.element(find.text('Andi Setiawan'));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(find.text('Gelap'), findsOneWidget);
    });

    testWidgets('keluar meminta konfirmasi lalu kembali ke login', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.text('Profil').last);
      await settle(tester);
      await tester.scrollUntilVisible(
        find.text('Keluar'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('Keluar'));
      await settle(tester);
      expect(find.text('Keluar dari aplikasi?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await settle(tester);
      expect(find.text('Andi Setiawan'), findsOneWidget);

      await tester.tap(find.text('Keluar'));
      await settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Keluar'),
        ),
      );
      await settle(tester);
      expect(find.text('NIP / Username'), findsOneWidget);
    });
  });

  group('notifikasi dan persetujuan (data contoh)', () {
    testWidgets('bel membuka notifikasi dengan catatan data contoh', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(PhosphorIconsRegular.bell));
      await settle(tester);
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.textContaining('menunggu kontrak API'), findsOneWidget);
      expect(
        find.textContaining('menunggu persetujuan atasan'),
        findsOneWidget,
      );
    });

    testWidgets('Setujui menghapus kartu dan menampilkan toast', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.scrollUntilVisible(
        find.text('3 menunggu persetujuanmu'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('3 menunggu persetujuanmu'));
      await settle(tester);
      expect(find.text('Rina Maharani'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('approval-1')),
          matching: find.text('Setujui'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(find.text('Pengajuan disetujui'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await settle(tester);
      expect(find.text('Rina Maharani'), findsNothing);
    });
  });

  group('unit', () {
    test('salam per jam', () {
      expect(IdFormat.greeting(DateTime(2026, 1, 1, 10, 59)), 'Selamat pagi,');
      expect(IdFormat.greeting(DateTime(2026, 1, 1, 11)), 'Selamat siang,');
      expect(IdFormat.greeting(DateTime(2026, 1, 1, 14, 59)), 'Selamat siang,');
      expect(IdFormat.greeting(DateTime(2026, 1, 1, 15)), 'Selamat sore,');
      expect(IdFormat.greeting(DateTime(2026, 1, 1, 18)), 'Selamat malam,');
    });

    test('format tanggal Indonesia', () {
      final d = DateTime(2026, 10, 26, 7, 5);
      expect(IdFormat.longDate(d), 'Senin, 26 Oktober 2026');
      expect(IdFormat.time(d), '07:05');
      expect(IdFormat.apiDate(d), '2026-10-26');
      expect(IdFormat.initials('Andi Setiawan'), 'AS');
    });

    test('ringkasan absen dari punch server', () {
      final t = DateTime(2026, 10, 26, 8);
      expect(AttendanceSummary.from(const []).phase, DayPhase.none);
      expect(
        AttendanceSummary.from([_punch(1, t, PunchStatus.approved)]).phase,
        DayPhase.checkedIn,
      );
      expect(
        AttendanceSummary.from([_punch(1, t, PunchStatus.pending)]).phase,
        DayPhase.pending,
      );
      final both = AttendanceSummary.from([
        _punch(1, t, PunchStatus.approved),
        _punch(2, t.add(const Duration(hours: 8)), PunchStatus.approved),
      ]);
      expect(both.phase, DayPhase.checkedOut);
      expect(both.workDuration(t), const Duration(hours: 8));
      expect(both.nextIsCheckOut, isTrue);
    });
  });
}
