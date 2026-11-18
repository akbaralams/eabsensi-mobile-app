import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../domain/location.dart';

/// Lokasi nyata dari perangkat. Izin ditolak -> [LocationDenied], GPS tidak
/// mendapat posisi dalam batas waktu -> [LocationUnavailable].
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationResult> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationDenied();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationDenied();
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final precision = await Geolocator.getLocationAccuracy();
      return LocationFound(
        LocationFix(
          latitude: p.latitude,
          longitude: p.longitude,
          accuracyMeters: p.accuracy.round(),
          isMocked: p.isMocked,
          isApproximate: precision == LocationAccuracyStatus.reduced,
          capturedAt: p.timestamp.toLocal(),
        ),
      );
    } on TimeoutException {
      return const LocationUnavailable();
    } on LocationServiceDisabledException {
      return const LocationDenied();
    } on PermissionDeniedException {
      return const LocationDenied();
    }
  }

  @override
  Future<void> openSettings() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openLocationSettings();
    }
  }
}
