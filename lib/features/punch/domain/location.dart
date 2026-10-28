import 'package:flutter/foundation.dart';

@immutable
class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final int accuracyMeters;
}

/// Lingkaran geofence kantor, hanya untuk tampilan peta. Kontrak belum
/// menyediakan koordinat kantor; server yang memutuskan lokasi sah.
@immutable
class OfficeArea {
  const OfficeArea({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
}

/// Hasil izin lokasi: lokasi dikirim bila izin diberikan, punch tetap bisa
/// dilanjutkan tanpa lokasi bila ditolak.
sealed class LocationResult {
  const LocationResult();
}

final class LocationFound extends LocationResult {
  const LocationFound(this.fix);

  final LocationFix fix;
}

final class LocationDenied extends LocationResult {
  const LocationDenied();
}

abstract class LocationService {
  Future<LocationResult> current();
}
