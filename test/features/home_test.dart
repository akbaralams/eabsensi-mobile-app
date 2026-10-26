import 'package:eabsensi/core/design/design.dart';
import 'package:eabsensi/features/menus/data/static_menu_repository.dart';
import 'package:eabsensi/features/menus/domain/menu_item.dart';
import 'package:eabsensi/features/menus/presentation/menu_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('beranda: salam per jam, nama, tanggal, jam, status awal', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Selamat pagi,'), findsOneWidget);
    expect(find.text('Andi Setiawan'), findsOneWidget);
    expect(find.text('Senin, 26 Oktober 2026'), findsOneWidget);
    expect(find.byKey(const Key('hero-clock')), findsOneWidget);
    expect(find.text('09:41'), findsOneWidget);
    expect(find.text('Belum Check In'), findsOneWidget);
    expect(find.text('Belum absen'), findsOneWidget);
    expect(find.text('Status Kehadiran Hari Ini'), findsOneWidget);
    expect(find.text('0j 0m'), findsOneWidget);
    expect(find.text('Kantor Pusat'), findsOneWidget);
  });

  testWidgets('menu dinamis tampil dari data; nonaktif terkunci', (
    tester,
  ) async {
    await pumpApp(tester);
    for (final label in ['Cuti', 'Izin', 'Sakit', 'Dinas Luar', 'Upacara']) {
      expect(find.text(label), findsOneWidget);
    }
    // Nonaktif: terbaca "nonaktif" oleh screen reader dan tidak bisa ditekan.
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Lembur, nonaktif')),
      isSemantics(isEnabled: false, hasEnabledState: true),
    );
    handle.dispose();

    await tester.tap(find.text('Lembur'), warnIfMissed: false);
    await settle(tester);
    expect(find.text('Lembur segera tersedia'), findsNothing);
    expect(find.text('Selamat pagi,'), findsOneWidget);
  });

  testWidgets('menu nonaktif mode sembunyi: tidak muncul', (tester) async {
    await pumpApp(
      tester,
      overrides: [
        menuInactiveModeProvider.overrideWithValue(MenuInactiveMode.hidden),
      ],
    );
    expect(find.text('Cuti'), findsOneWidget);
    expect(find.text('Lembur'), findsNothing);
    expect(find.text('WFH'), findsNothing);
  });

  testWidgets('mengganti data statis mengubah grid tanpa mengubah kode UI', (
    tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [
        menuRepositoryProvider.overrideWithValue(
          const StaticMenuRepository([
            MenuItemData(
              id: 'baru',
              label: 'Menu Baru',
              icon: 'flag',
              tone: MenuTone.teal,
              isActive: true,
              action: ComingSoonAction(),
              sort: 1,
            ),
          ]),
        ),
      ],
    );
    expect(find.text('Menu Baru'), findsOneWidget);
    expect(find.text('Cuti'), findsNothing);
    await tester.tap(find.text('Menu Baru'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Menu Baru segera tersedia'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('menu Sakit membuka form dengan kategori dan jenis terpilih', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Sakit'));
    await settle(tester);
    expect(find.text('Ajukan Cuti / Izin'), findsOneWidget);
    expect(find.text('Jenis Izin'), findsOneWidget);
    final field = tester.widget<TextField>(find.byKey(const Key('leave-type')));
    expect(field.controller?.text, 'Sakit');
    expect(find.text('Ajukan Izin'), findsOneWidget);
  });

  testWidgets('banner event dan kartu persetujuan (atasan) tampil', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(
      find.text('3 menunggu persetujuanmu'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Apel Kontrak · 00.00'), findsOneWidget);
    expect(find.text('3 menunggu persetujuanmu'), findsOneWidget);
  });

  testWidgets('mode gelap: tema gelap dipakai di beranda', (tester) async {
    await pumpApp(tester, prefs: {'theme_mode': 'dark'});
    final context = tester.element(find.text('Andi Setiawan'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.colors.isDark, isTrue);
  });

  testWidgets('teks sistem 1.3x dan layar 360 lebar tidak overflow', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(360, 780), textScale: 1.3);
    expect(tester.takeException(), isNull);
    expect(find.text('Andi Setiawan'), findsOneWidget);
  });
}
