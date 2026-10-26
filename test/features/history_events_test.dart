import 'package:eabsensi/core/mock/mock_env.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/events/data/mock_event_repository.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:eabsensi/core/network/api_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

MockEnv _env(DateTime now) => MockEnv(
  tokens: MemoryTokenStore('t'),
  scenario: () => const MockScenario(requiresPhoto: false),
  now: () => now,
  latency: Duration.zero,
);

void main() {
  group('riwayat', () {
    testWidgets('navigasi bulan, tile dan baris per hari', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);
      await tester.tap(find.text('Laporan'));
      await settle(tester);

      expect(find.text('Riwayat Absensi'), findsOneWidget);
      expect(find.text('Oktober 2026'), findsOneWidget);
      expect(find.text('Hadir'), findsWidgets);
      expect(find.text('Terlambat'), findsWidgets);
      expect(find.text('Tidak Hadir'), findsWidgets);
      // Status per hari: teks + ikon pada chip, bukan hanya warna.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              RegExp(r'^\d\d:\d\d - \d\d:\d\d$').hasMatch(w.data ?? ''),
        ),
        findsWidgets,
      );

      await tester.tap(find.bySemanticsLabel('Bulan sebelumnya'));
      await settle(tester);
      expect(find.text('September 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Bulan berikutnya'));
      await settle(tester);
      expect(find.text('Oktober 2026'), findsOneWidget);

      // Bulan berjalan: tombol berikutnya tidak bergerak.
      await tester.tap(
        find.bySemanticsLabel('Bulan berikutnya'),
        warnIfMissed: false,
      );
      await settle(tester);
      expect(find.text('Oktober 2026'), findsOneWidget);
      handle.dispose();
    });
  });

  group('event', () {
    testWidgets('daftar event dan check-in Apel Kontrak', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Upacara'));
      await settle(tester);

      expect(find.text('Event Hari Ini'), findsOneWidget);
      expect(find.text('Apel Kontrak'), findsOneWidget);
      expect(find.text('Upacara Bendera'), findsOneWidget);
      expect(find.text('Sudah check-in'), findsOneWidget);
      expect(find.text('Belum check-in'), findsNWidgets(2));

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('event-1')),
          matching: find.text('Check-in'),
        ),
      );
      await settle(tester);
      expect(find.text('Check-in Apel Kontrak'), findsWidgets);
      await tester.tap(find.textContaining('Konfirmasi'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('shutter')));
      await settle(tester);

      expect(
        find.text('Check-in Apel Kontrak tercatat · waktu server'),
        findsOneWidget,
      );
      expect(find.text('Tercatat'), findsOneWidget);
    });

    testWidgets('di luar jam: pesan kontrak apa adanya', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Upacara'));
      await settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('event-3')),
          matching: find.text('Check-in'),
        ),
      );
      await settle(tester);
      await tester.tap(find.textContaining('Konfirmasi'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('shutter')));
      await settle(tester);
      expect(
        find.text('Check-in dibuka pukul 15:30 sampai 16:30.'),
        findsOneWidget,
      );
    });

    test('check-in kedua ditolak dengan pesan kontrak', () async {
      final repo = MockEventRepository(_env(DateTime(2026, 10, 26, 9, 41)));
      final first = await repo.checkIn(1, const EvidenceSubmission());
      expect(first.eventId, 1);
      expect(
        () => repo.checkIn(1, const EvidenceSubmission()),
        throwsA(
          isA<RuleRejectedFailure>().having(
            (e) => e.message,
            'message',
            'Anda sudah check-in di event ini.',
          ),
        ),
      );
    });
  });
}
