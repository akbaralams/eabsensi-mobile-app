import 'package:eabsensi/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tiap komponen bersama: terang dan gelap, skala teks 1.0 dan 1.3.
Widget _app(ThemeMode mode, double scale, Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: mode,
  builder: (context, c) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: c!,
  ),
  home: AppScaffold(
    safeTop: false,
    body: Padding(
      padding: const EdgeInsets.all(AppSpace.screenH),
      child: SingleChildScrollView(child: child),
    ),
  ),
);

Widget _gap() => const SizedBox(height: 12);

void goldenGroup(String name, double height, Widget Function() build) {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('$name ${mode.name} x$scale', (tester) async {
        tester.view
          ..physicalSize = Size(390, height * (scale > 1 ? 1.5 : 1))
          ..devicePixelRatio = 1;
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(
              disableAnimations: true,
              reduceMotion: true,
            );
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearAllTestValues();
        });
        await tester.pumpWidget(_app(mode, scale, build()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$name-${mode.name}-x$scale.png'),
        );
      });
    }
  }
}

void main() {
  goldenGroup('tombol', 520, () {
    return Column(
      children: [
        PrimaryButton(
          label: 'Masuk',
          icon: PhosphorIconsBold.arrowRight,
          onPressed: () {},
        ),
        _gap(),
        const PrimaryButton(label: 'Menunggu lokasi…', onPressed: null),
        _gap(),
        PrimaryButton(label: 'Memproses', loading: true, onPressed: () {}),
        _gap(),
        OutlineButton(
          label: 'SSO Perusahaan',
          icon: PhosphorIconsRegular.buildings,
          onPressed: () {},
        ),
        _gap(),
        const OutlineButton(label: 'Batal', onPressed: null),
        _gap(),
        Row(
          children: [
            IconCircleButton(
              icon: PhosphorIconsRegular.bell,
              semanticLabel: 'Notifikasi',
              showBadge: true,
              onPressed: () {},
            ),
            IconCircleButton(
              icon: PhosphorIconsRegular.gearSix,
              semanticLabel: 'Pengaturan',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  });

  goldenGroup('field', 520, () {
    return const Column(
      children: [
        AppTextField(hint: 'NIP / Username', icon: PhosphorIconsRegular.user),
        SizedBox(height: 12),
        AppTextField(
          hint: 'Password',
          icon: PhosphorIconsRegular.lock,
          obscure: true,
        ),
        SizedBox(height: 12),
        AppTextField(
          hint: 'Password',
          icon: PhosphorIconsRegular.lock,
          errorText: 'Password wajib diisi.',
        ),
        SizedBox(height: 12),
        AppTextField(
          label: 'Alasan',
          hint: 'Tulis alasan pengajuan',
          maxLines: 4,
          minLines: 3,
        ),
      ],
    );
  });

  goldenGroup('segmented-chip', 420, () {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillSegmented<String>(
          value: 'login',
          onChanged: (_) {},
          items: const [
            SegmentItem(value: 'login', label: 'Login'),
            SegmentItem(value: 'sso', label: 'SSO'),
          ],
        ),
        _gap(),
        PillSegmented<String>(
          gradient: true,
          value: 'cuti',
          onChanged: (_) {},
          items: const [
            SegmentItem(value: 'cuti', label: 'Cuti'),
            SegmentItem(value: 'izin', label: 'Izin'),
            SegmentItem(value: 'dinas', label: 'Dinas Luar'),
            SegmentItem(value: 'lain', label: 'Lainnya'),
          ],
        ),
        _gap(),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusChip(label: 'Hadir', variant: StatusVariant.success),
            StatusChip(label: 'Terlambat', variant: StatusVariant.late),
            StatusChip(
              label: 'Menunggu atasan',
              variant: StatusVariant.pending,
            ),
            StatusChip(label: 'Tidak hadir', variant: StatusVariant.absent),
            StatusChip(label: 'Belum check-in', variant: StatusVariant.neutral),
            StatusChip(
              label: 'Sudah Check In',
              variant: StatusVariant.success,
              large: true,
            ),
          ],
        ),
      ],
    );
  });

  goldenGroup('kartu-menu', 460, () {
    return Column(
      children: [
        const AppCard(child: Text('Kartu utama')),
        _gap(),
        const AppCard(secondary: true, child: Text('Kartu sekunder')),
        _gap(),
        Builder(
          builder: (context) => GridView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpace.grid,
              crossAxisSpacing: AppSpace.grid,
              mainAxisExtent: menuTileExtent(context),
            ),
            children: [
              MenuTile(
                icon: PhosphorIconsRegular.umbrella,
                label: 'Cuti',
                tone: MenuTone.mint,
                onTap: () {},
              ),
              MenuTile(
                icon: PhosphorIconsRegular.hand,
                label: 'Izin',
                tone: MenuTone.teal,
                onTap: () {},
              ),
              MenuTile(
                icon: PhosphorIconsRegular.briefcase,
                label: 'Dinas Luar',
                tone: MenuTone.amber,
                onTap: () {},
              ),
              const MenuTile(
                icon: PhosphorIconsRegular.moonStars,
                label: 'Lembur',
                tone: MenuTone.amber,
                enabled: false,
                onTap: null,
              ),
            ],
          ),
        ),
      ],
    );
  });

  goldenGroup('header-nav-logo', 420, () {
    return Column(
      children: [
        const PageHeader(title: 'Riwayat Absensi'),
        _gap(),
        const LogoMark(size: 40),
        _gap(),
        BottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: const [
            BottomNavItem(
              label: 'Beranda',
              icon: PhosphorIconsRegular.house,
              activeIcon: PhosphorIconsFill.house,
            ),
            BottomNavItem(
              label: 'Absensi',
              icon: PhosphorIconsRegular.clipboardText,
              activeIcon: PhosphorIconsFill.clipboardText,
            ),
            BottomNavItem(
              label: 'Cuti/Izin',
              icon: PhosphorIconsRegular.files,
              activeIcon: PhosphorIconsFill.files,
            ),
            BottomNavItem(
              label: 'Laporan',
              icon: PhosphorIconsRegular.fileText,
              activeIcon: PhosphorIconsFill.fileText,
            ),
            BottomNavItem(
              label: 'Profil',
              icon: PhosphorIconsRegular.user,
              activeIcon: PhosphorIconsFill.user,
            ),
          ],
        ),
      ],
    );
  });

  testWidgets('AppToast menampilkan pesan lalu hilang', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => AppToast.show(context, 'Pengajuan terkirim'),
              child: const Text('tampil'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('tampil'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Pengajuan terkirim'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Pengajuan terkirim'), findsNothing);
  });
}
