import 'package:eabsensi/core/mock/mock_env.dart';
import 'package:eabsensi/features/punch/presentation/punch_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Future<void> _punchFromHome(WidgetTester tester, String button) async {
  await tester.tap(find.text(button).first);
  await settle(tester);
  await tester.tap(find.textContaining('Konfirmasi'));
  await settle(tester);
}

Future<void> _shoot(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('shutter')));
  await settle(tester);
}

void main() {
  testWidgets('Check In: lokasi -> foto -> hasil pending dengan waktu server', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Check In').first);
    await settle(tester);

    expect(find.text('Di dalam area kantor'), findsOneWidget);
    expect(find.text('Akurasi lokasi: 8 meter'), findsOneWidget);
    expect(find.text('Konfirmasi Check In'), findsOneWidget);

    await tester.tap(find.text('Konfirmasi Check In'));
    await settle(tester);
    expect(find.text('Ambil foto'), findsOneWidget);

    await _shoot(tester);
    expect(find.byKey(const Key('result-time')), findsOneWidget);
    expect(find.text('09:41'), findsOneWidget);
    expect(find.text('Menunggu atasan'), findsOneWidget);
    expect(find.textContaining('Check In tercatat'), findsOneWidget);

    await tester.tap(find.text('Kembali ke Beranda'));
    await settle(tester);
    expect(find.text('Menunggu persetujuan'), findsOneWidget);
    expect(find.text('09:41'), findsWidgets);
  });

  testWidgets(
    'tanpa requires_photo dan tanpa approval: langsung terkirim, Disetujui',
    (tester) async {
      await pumpApp(
        tester,
        scenario: const MockScenario(
          requiresPhoto: false,
          requiresApproval: false,
        ),
      );
      await tester.tap(find.text('Check In').first);
      await settle(tester);
      await tester.tap(find.text('Konfirmasi Check In'));
      await settle(tester);
      expect(find.text('Ambil foto'), findsNothing);
      expect(find.text('Disetujui'), findsOneWidget);
      await tester.tap(find.text('Kembali ke Beranda'));
      await settle(tester);
      expect(find.text('Sudah Check In'), findsOneWidget);
    },
  );

  testWidgets('punch kedua terlalu cepat: pesan server apa adanya', (
    tester,
  ) async {
    await pumpApp(tester);
    await _punchFromHome(tester, 'Check In');
    await _shoot(tester);
    await tester.tap(find.text('Kembali ke Beranda'));
    await settle(tester);

    await _punchFromHome(tester, 'Check Out');
    await _shoot(tester);
    expect(
      find.text('Tunggu 60 detik sebelum melakukan punch lagi.'),
      findsOneWidget,
    );
    expect(find.text('Belum bisa dicatat'), findsOneWidget);
  });

  testWidgets('offline saat kirim: layar galat offline, tanpa antrean', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    await tester.tap(find.text('Check In').first);
    await settle(tester);
    await tester.tap(find.text('Konfirmasi Check In'));
    await settle(tester);

    container
        .read(mockScenarioProvider.notifier)
        .update((s) => s.copyWith(offline: true));
    await _shoot(tester);

    expect(find.text('Tidak ada koneksi'), findsOneWidget);
    expect(find.textContaining('membutuhkan jaringan'), findsOneWidget);

    // Setelah jaringan pulih, "Coba lagi" mengirim ulang dan berhasil.
    container
        .read(mockScenarioProvider.notifier)
        .update((s) => s.copyWith(offline: false));
    await tester.tap(find.text('Coba lagi'));
    await settle(tester);
    expect(find.byKey(const Key('result-time')), findsOneWidget);
  });

  testWidgets('di luar area: status amber dengan teks, konfirmasi tetap bisa', (
    tester,
  ) async {
    await pumpApp(
      tester,
      scenario: const MockScenario(location: LocationScenario.outside),
    );
    await tester.tap(find.text('Check In').first);
    await settle(tester);
    expect(find.text('Di luar area kantor'), findsOneWidget);
    expect(find.text('Konfirmasi Check In'), findsOneWidget);
  });

  testWidgets('izin lokasi ditolak: lanjut tanpa lokasi', (tester) async {
    await pumpApp(
      tester,
      scenario: const MockScenario(
        location: LocationScenario.denied,
        requiresPhoto: false,
      ),
    );
    await tester.tap(find.text('Check In').first);
    await settle(tester);
    expect(find.text('Lokasi tidak tersedia'), findsOneWidget);
    expect(find.textContaining('tanpa lokasi'), findsOneWidget);
    await tester.tap(find.text('Konfirmasi Check In'));
    await settle(tester);
    expect(find.byKey(const Key('result-time')), findsOneWidget);
  });

  testWidgets('menunggu lokasi: tombol nonaktif', (tester) async {
    await pumpApp(
      tester,
      scenario: const MockScenario(location: LocationScenario.searching),
    );
    await tester.tap(find.text('Check In').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Mencari lokasi…'), findsOneWidget);
    expect(find.text('Menunggu lokasi…'), findsOneWidget);
    expect(find.textContaining('Konfirmasi'), findsNothing);
  });

  testWidgets('tab Absensi membuka Check Out setelah ada punch masuk', (
    tester,
  ) async {
    await pumpApp(
      tester,
      scenario: const MockScenario(
        requiresPhoto: false,
        requiresApproval: false,
      ),
    );
    await tester.tap(find.text('Absensi'));
    await settle(tester);
    expect(find.text('Konfirmasi Check In'), findsOneWidget);
    await tester.tap(find.text('Konfirmasi Check In'));
    await settle(tester);
    await tester.tap(find.text('Kembali ke Beranda'));
    await settle(tester);

    await tester.tap(find.text('Absensi'));
    await settle(tester);
    expect(find.text('Konfirmasi Check Out'), findsOneWidget);
  });

  test('alur menandai fase lokasi dengan benar', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(punchFlowProvider).phase, LocationPhase.locating);
  });
}
