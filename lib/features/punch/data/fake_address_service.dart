import '../../../core/geo/geo.dart';
import '../../../core/mock/mock_env.dart';
import '../domain/location.dart';
import 'fake_location_service.dart';

/// Nama jalan dummy: alamat kantor bila di dalam area, selain itu jalan di
/// dekatnya.
class FakeAddressService implements AddressService {
  FakeAddressService(this._env);

  final MockEnv _env;

  static const insideAddress =
      'Jl. Medan Merdeka Barat No. 12, Gambir, Jakarta Pusat';
  static const outsideAddress = 'Jl. Kebon Sirih No. 5, Menteng, Jakarta Pusat';

  @override
  Future<String?> lookup(double latitude, double longitude) async {
    if (_env.latency > Duration.zero) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    const office = FakeLocationService.office;
    final inside =
        distanceMeters(
          latitude,
          longitude,
          office.latitude,
          office.longitude,
        ) <=
        office.radiusMeters;
    return inside ? insideAddress : outsideAddress;
  }
}
