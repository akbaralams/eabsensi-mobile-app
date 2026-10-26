import 'dart:async';

import '../../../core/mock/mock_env.dart';
import '../domain/location.dart';

/// Lokasi dummy mengikuti skenario uji: di dalam area, di luar area, izin
/// ditolak, atau tidak kunjung dapat lokasi.
class FakeLocationService implements LocationService {
  FakeLocationService(this._env);

  final MockEnv _env;

  static const office = OfficeArea(
    name: 'Kantor Pusat',
    latitude: -6.2000,
    longitude: 106.8166,
    radiusMeters: 150,
  );

  @override
  Future<LocationResult> current() async {
    if (_env.latency > Duration.zero) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
    switch (_env.scenario().location) {
      case LocationScenario.inside:
        return const LocationFound(
          LocationFix(
            latitude: -6.20012,
            longitude: 106.81655,
            accuracyMeters: 8,
          ),
        );
      case LocationScenario.outside:
        return const LocationFound(
          LocationFix(
            latitude: -6.2058,
            longitude: 106.8230,
            accuracyMeters: 14,
          ),
        );
      case LocationScenario.denied:
        return const LocationDenied();
      case LocationScenario.searching:
        return Completer<LocationResult>().future;
    }
  }
}
