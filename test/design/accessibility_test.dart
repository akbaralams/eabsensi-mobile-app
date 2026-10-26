import 'package:eabsensi/core/design/design.dart';
import 'package:eabsensi/core/design/gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    group('galeri komponen (${mode.name})', () {
      Future<SemanticsHandle> pumpGallery(WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        tester.view
          ..physicalSize = const Size(390 * 3, 3000)
          ..devicePixelRatio = 3;
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(
              disableAnimations: true,
              reduceMotion: true,
            );
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearAllTestValues();
        });
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            home: const GalleryPage(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        return handle;
      }

      testWidgets('target sentuh minimal 48dp', (tester) async {
        final handle = await pumpGallery(tester);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('semua target sentuh berlabel', (tester) async {
        final handle = await pumpGallery(tester);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    });
  }

  testWidgets('menu nonaktif dibaca "nonaktif" oleh screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: MenuTile(
            icon: PhosphorIconsRegular.moonStars,
            label: 'Lembur',
            tone: MenuTone.amber,
            enabled: false,
            onTap: null,
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Lembur, nonaktif')),
      isSemantics(
        label: 'Lembur, nonaktif',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('status chip selalu punya teks, bukan hanya warna', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              StatusChip(label: 'Terlambat', variant: StatusVariant.late),
              StatusChip(label: 'Tidak hadir', variant: StatusVariant.absent),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Terlambat'), findsOneWidget);
    expect(find.text('Tidak hadir'), findsOneWidget);
    expect(find.byType(PhosphorIcon), findsNWidgets(2));
  });
}
