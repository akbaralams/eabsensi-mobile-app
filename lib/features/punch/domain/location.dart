import 'package:flutter/foundation.dart';

@immutable
class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    this.isMocked = false,
    this.isApproximate = false,
    this.capturedAt,
  });

  /// Batas `location_age_seconds` di kontrak API.
  static const maxAgeSeconds = 86400;

  final double latitude;
  final double longitude;
  final int accuracyMeters;

  /// Sistem operasi melaporkan lokasi ini berasal dari aplikasi pengubah lokasi.
  final bool isMocked;

  /// Pengguna hanya mengizinkan lokasi perkiraan, bukan lokasi tepat.
  final bool isApproximate;

  /// Waktu GPS mengambil lokasi ini (jam perangkat).
  final DateTime? capturedAt;

  /// Umur lokasi saat [now], dibatasi ke rentang yang diterima API.
  int ageSeconds(DateTime now) {
    final at = capturedAt;
    if (at == null) return 0;
    return now.difference(at).inSeconds.clamp(0, maxAgeSeconds);
  }
}

/// Lingkaran lokasi kerja yang berlaku, dari `work_location` di API. Hanya untuk
/// tampilan peta dan panduan; server yang memutuskan lokasi sah.
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

/// Hasil mengambil lokasi. Tanpa lokasi kerja yang berlaku, punch tetap bisa
/// dilanjutkan walau lokasi tidak didapat.
sealed class LocationResult {
  const LocationResult();
}

final class LocationFound extends LocationResult {
  const LocationFound(this.fix);

  final LocationFix fix;
}

/// GPS mati atau izin lokasi ditolak.
final class LocationDenied extends LocationResult {
  const LocationDenied();
}

/// Izin ada, tetapi GPS tidak mendapat posisi dalam batas waktu.
final class LocationUnavailable extends LocationResult {
  const LocationUnavailable();
}

abstract class LocationService {
  Future<LocationResult> current();

  /// Buka pengaturan yang relevan: GPS bila mati, selain itu izin aplikasi.
  Future<void> openSettings();
}

/// Nama jalan dari koordinat (reverse geocoding), hanya untuk tampilan agar
/// pegawai yakin lokasinya benar. Yang dikirim ke server tetap koordinat.
/// `null` bila tidak tersedia (tanpa jaringan, geocoder perangkat tidak ada).
abstract class AddressService {
  Future<String?> lookup(double latitude, double longitude);
}

/// Pemeriksaan keutuhan perangkat. Hasilnya hanya sinyal untuk server dan bisa
/// dipalsukan pada aplikasi yang dimodifikasi.
abstract class DeviceIntegrityService {
  Future<bool> isRooted();
}
