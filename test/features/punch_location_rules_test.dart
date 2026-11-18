import 'package:eabsensi/core/api/mappers.dart';
import 'package:eabsensi/core/mock/mock_env.dart';
import 'package:eabsensi/features/punch/data/platform_device_integrity_service.dart';
import 'package:eabsensi/features/punch/domain/location.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:eabsensi/features/punch/presentation/punch_details.dart';
import 'package:eabsensi/features/punch/presentation/punch_providers.dart';
import 'package:eabsensi_api/eabsensi_api.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

const _target = PunchTarget(PunchKind.checkIn);

const _office = OfficeArea(
  name: 'Kantor Pusat',
  latitude: -6.2,
  longitude: 106.8,
  radiusMeters: 100,
);

LocationFix _fix({
  bool isMocked = false,
  bool isApproximate = false,
  DateTime? capturedAt,
  double latitude = -6.2,
}) => LocationFix(
  latitude: latitude,
  longitude: 106.8,
  accuracyMeters: 10,
  isMocked: isMocked,
  isApproximate: isApproximate,
  capturedAt: capturedAt,
);

/// Lokasi berurutan sesuai daftar; hasil terakhir dipakai berulang.
class _StubLocation implements LocationService {
  _StubLocation(this.results);

  final List<LocationResult> results;
  int calls = 0;
  int settingsOpened = 0;

  @override
  Future<LocationResult> current() async {
    final index = calls.clamp(0, results.length - 1);
    calls++;
    return results[index];
  }

  @override
  Future<void> openSettings() async => settingsOpened++;
}

class _StubPunches implements PunchRepository {
  _StubPunches({this.flags = const []});

  final List<String> flags;
  EvidenceSubmission? sent;

  @override
  Future<List<Punch>> list(DateTime date) async => const [];

  @override
  Future<Punch> create(EvidenceSubmission evidence) async {
    sent = evidence;
    return Punch(
      id: 1,
      punchedAt: DateTime(2026, 10, 26, 9, 41),
      source: 'mobile',
      status: PunchStatus.approved,
      statusLabel: 'Disetujui',
      hasPhoto: false,
      locationFlags: flags,
    );
  }
}

void main() {
  group('alasan absen diblokir saat lokasi wajib', () {
    PunchFlowState flow(
      LocationPhase phase, {
      LocationFix? fix,
      bool required = true,
    }) => PunchFlowState(
      target: _target,
      locationRequired: required,
      phase: phase,
      fix: fix,
    );

    test('GPS mati, timeout, lokasi palsu, dan lokasi perkiraan diblokir', () {
      expect(flow(LocationPhase.denied).canConfirm, isFalse);
      expect(flow(LocationPhase.unavailable).canConfirm, isFalse);
      expect(
        flow(LocationPhase.inside, fix: _fix(isMocked: true)).blockReason,
        contains('Lokasi palsu'),
      );
      expect(
        flow(LocationPhase.inside, fix: _fix(isApproximate: true)).blockReason,
        contains('lokasi tepat'),
      );
    });

    test('di luar radius tidak diblokir, karena tetap tercatat', () {
      final state = flow(LocationPhase.outside, fix: _fix());
      expect(state.blockReason, isNull);
      expect(state.canConfirm, isTrue);
      expect(PunchDetails.locationNote(state, _office), contains('ditandai'));
    });

    test('tanpa lokasi wajib, absen tetap bisa dilanjutkan', () {
      final state = flow(LocationPhase.denied, required: false);
      expect(state.blockReason, isNull);
      expect(state.canConfirm, isTrue);
    });
  });

  test('umur lokasi dibatasi ke rentang kontrak API', () {
    final now = DateTime(2026, 10, 26, 9, 41);
    expect(_fix().ageSeconds(now), 0);
    expect(
      _fix(capturedAt: now.subtract(const Duration(seconds: 45)))
          .ageSeconds(now),
      45,
    );
    expect(
      _fix(capturedAt: now.add(const Duration(minutes: 1))).ageSeconds(now),
      0,
    );
    expect(
      _fix(capturedAt: now.subtract(const Duration(days: 3))).ageSeconds(now),
      LocationFix.maxAgeSeconds,
    );
  });

  test('profil dan event memetakan lokasi kerja dari API', () {
    final me = api.Me.fromJson({
      'id': 1,
      'name': 'Ani',
      'username': 'ani',
      'employee': null,
      'timezone': 'Asia/Jakarta',
      'requires_photo': true,
      'requires_approval': true,
      'work_location': {
        'name': 'Kantor Pusat',
        'latitude': -6.2,
        'longitude': 106.8,
        'radius_meters': 100,
      },
    });
    final area = profileFromApi(me).workLocation;
    expect(area?.name, 'Kantor Pusat');
    expect(area?.latitude, -6.2);
    expect(area?.radiusMeters, 100);

    final noLocation = api.Me.fromJson({
      'id': 1,
      'name': 'Ani',
      'username': 'ani',
      'employee': null,
      'timezone': 'Asia/Jakarta',
      'requires_photo': true,
      'requires_approval': true,
      'work_location': null,
    });
    expect(profileFromApi(noLocation).workLocation, isNull);
  });

  testWidgets('lokasi wajib tetapi izin ditolak: arahkan ke pengaturan', (
    tester,
  ) async {
    final location = _StubLocation([
      const LocationDenied(),
      LocationFound(_fix()),
    ]);
    await pumpApp(
      tester,
      overrides: [
        locationRequiredProvider.overrideWithValue(true),
        locationServiceProvider.overrideWithValue(location),
      ],
    );
    await tester.tap(find.text('Check In').first);
    await settle(tester);

    expect(find.text('Konfirmasi Check In'), findsNothing);
    expect(find.textContaining('Lokasi wajib untuk absen'), findsOneWidget);

    await tester.ensureVisible(find.text('Buka Pengaturan'));
    await settle(tester);
    await tester.tap(find.text('Buka Pengaturan'));
    await settle(tester);
    expect(location.settingsOpened, 1);

    await tester.tap(find.text('Coba Lagi'));
    await settle(tester);
    expect(find.text('Konfirmasi Check In'), findsOneWidget);
  });

  testWidgets('lokasi palsu terdeteksi: konfirmasi tidak tersedia', (
    tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [
        locationRequiredProvider.overrideWithValue(true),
        locationServiceProvider.overrideWithValue(
          _StubLocation([LocationFound(_fix(isMocked: true))]),
        ),
      ],
    );
    await tester.tap(find.text('Check In').first);
    await settle(tester);

    expect(find.text('Konfirmasi Check In'), findsNothing);
    expect(find.textContaining('Lokasi palsu terdeteksi'), findsOneWidget);
  });

  testWidgets('tanda dari server tampil di layar hasil', (tester) async {
    await pumpApp(
      tester,
      scenario: const MockScenario(requiresPhoto: false),
      overrides: [
        punchRepositoryProvider.overrideWithValue(
          _StubPunches(flags: const ['outside_radius', 'tanda_baru']),
        ),
      ],
    );
    await tester.tap(find.text('Check In').first);
    await settle(tester);
    await tester.tap(find.text('Konfirmasi Check In'));
    await settle(tester);

    expect(find.byKey(const Key('result-location-flags')), findsOneWidget);
    expect(
      find.text('Ditandai untuk ditinjau: Di luar radius, Perlu ditinjau.'),
      findsOneWidget,
    );
  });

  group('bukti yang dikirim', () {
    ProviderContainer containerWith(
      LocationService location,
      PunchRepository punches, {
      bool rooted = false,
    }) {
      final container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(location),
          punchRepositoryProvider.overrideWithValue(punches),
          addressServiceProvider.overrideWithValue(_NoAddress()),
          deviceIntegrityProvider.overrideWithValue(
            FakeDeviceIntegrityService(rooted: rooted),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('lokasi segar dikirim dengan sinyal integritas', () async {
      final punches = _StubPunches();
      final container = containerWith(
        _StubLocation([LocationFound(_fix(capturedAt: DateTime.now()))]),
        punches,
        rooted: true,
      );
      final flow = container.read(punchFlowProvider.notifier);

      await flow.start(_target);
      await flow.submit();

      expect(punches.sent?.latitude, -6.2);
      expect(punches.sent?.isMocked, isFalse);
      expect(punches.sent?.locationAgeSeconds, lessThanOrEqualTo(1));
      expect(punches.sent?.deviceRooted, isTrue);
    });

    test('lokasi lama diambil ulang sebelum dikirim', () async {
      final location = _StubLocation([
        LocationFound(
          _fix(capturedAt: DateTime.now().subtract(const Duration(minutes: 2))),
        ),
        LocationFound(_fix(capturedAt: DateTime.now(), latitude: -6.3)),
      ]);
      final punches = _StubPunches();
      final container = containerWith(location, punches);
      final flow = container.read(punchFlowProvider.notifier);

      await flow.start(_target);
      await flow.submit();

      expect(location.calls, 2);
      expect(punches.sent?.latitude, -6.3);
    });
  });
}

class _NoAddress implements AddressService {
  @override
  Future<String?> lookup(double latitude, double longitude) async => null;
}
