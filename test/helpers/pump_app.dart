import 'package:eabsensi/app.dart';
import 'package:eabsensi/core/api/no_retry.dart';
import 'package:eabsensi/core/clock/clock.dart';
import 'package:eabsensi/core/mock/mock_env.dart';
import 'package:eabsensi/core/storage/preferences.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/punch/data/fake_camera_service.dart';
import 'package:eabsensi/features/punch/domain/camera.dart';
import 'package:eabsensi/features/punch/presentation/location_map.dart';
import 'package:eabsensi/features/punch/presentation/punch_providers.dart';
import 'package:eabsensi/features/update/data/http_update_repository.dart';
import 'package:eabsensi/features/update/domain/app_update.dart';
import 'package:eabsensi/features/update/presentation/update_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Senin, 26 Oktober 2026 09:41 (jam tetap untuk semua test).
final testNow = DateTime(2026, 10, 26, 9, 41);

class _FixedScenario extends MockScenarioController {
  _FixedScenario(this._initial);

  final MockScenario _initial;

  @override
  MockScenario build() => _initial;
}

/// Menjalankan aplikasi penuh dengan data dummy, tanpa latensi dan tanpa
/// animasi/timer yang menggantung. Mengembalikan container untuk asersi.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  bool signedIn = true,
  MockScenario scenario = const MockScenario(),
  DateTime? now,
  Size size = const Size(390, 844),
  double textScale = 1,
  Map<String, Object> prefs = const {},
  CameraService camera = const FakeCameraService(),
  List<Override> overrides = const [],
  TokenStore? tokens,
  UpdateRepository updates = const DisabledUpdateRepository(),
  ApkInstaller? installer,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final clock = now ?? testNow;

  tester.view
    ..physicalSize = size * 3
    ..devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(
        disableAnimations: true,
        reduceMotion: true,
      );
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });

  final container = ProviderContainer(
    retry: noAutomaticRetry,
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      tokenStoreProvider.overrideWithValue(
        tokens ?? MemoryTokenStore(signedIn ? '7|test-token' : null),
      ),
      clockProvider.overrideWithValue(() => clock),
      tickingClockProvider.overrideWith((ref) => Stream.value(clock)),
      mapTilesEnabledProvider.overrideWithValue(false),
      cameraServiceProvider.overrideWithValue(camera),
      mockScenarioProvider.overrideWith(() => _FixedScenario(scenario)),
      mockEnvProvider.overrideWith(
        (ref) => MockEnv(
          tokens: ref.watch(tokenStoreProvider),
          scenario: () => ref.read(mockScenarioProvider),
          now: () => clock,
          latency: Duration.zero,
        ),
      ),
      // Tanpa channel platform dan tanpa jaringan: versi tetap, tidak ada rilis.
      appVersionProvider.overrideWith(
        (ref) => const AppVersion(name: '1.0.0', code: 10000),
      ),
      updateRepositoryProvider.overrideWithValue(updates),
      if (installer != null) apkInstallerProvider.overrideWithValue(installer),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const EabsensiApp()),
  );
  await settle(tester);
  return container;
}

Future<void> settle(WidgetTester tester) =>
    tester.pumpAndSettle(const Duration(milliseconds: 50));

/// Mengetuk menu beranda: digulir ke atas layar dulu, karena baris kedua grid
/// bisa tertutup navigasi bawah pada layar pendek.
Future<void> tapMenu(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await settle(tester);
  await tester.tap(find.text(label));
  await settle(tester);
}

/// Menggulir beranda ke kartu persetujuan (di bawah navigasi bila tidak
/// digulir lebih jauh) lalu mengetuknya.
Future<void> openApprovalsFromHome(WidgetTester tester) async {
  final card = find.text('Menunggu Persetujuan');
  await tester.scrollUntilVisible(
    card,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
  await settle(tester);
  await tester.tap(card);
  await settle(tester);
}
