import 'package:eabsensi/core/clock/business_time.dart';
import 'package:eabsensi/features/punch/data/geocoding_address_service.dart';
import 'package:eabsensi/features/punch/domain/location.dart';
import 'package:eabsensi/features/punch/presentation/punch_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

class _NoAddress implements AddressService {
  @override
  Future<String?> lookup(double latitude, double longitude) async => null;
}

void main() {
  group('composeAddress', () {
    test('baris alamat Android: tanpa kode pos dan negara', () {
      expect(
        composeAddress(
          street:
              'Jl. Pondok Benda No.12, Pd. Benda, Kec. Pamulang, '
              'Kota Tangerang Selatan, Banten 15416, Indonesia',
          postalCode: '15416',
          country: 'Indonesia',
        ),
        'Jl. Pondok Benda No.12, Pd. Benda, Kec. Pamulang, '
        'Kota Tangerang Selatan, Banten',
      );
    });

    test('disusun dari bagian: jalan, nomor, kelurahan, kota', () {
      expect(
        composeAddress(
          street: 'Jalan Ganesha 3',
          thoroughfare: 'Jalan Ganesha',
          subThoroughfare: '3',
          subLocality: 'Pamulang Barat',
          locality: 'Pamulang',
          subAdministrativeArea: 'Kota Tangerang Selatan',
        ),
        'Jalan Ganesha No. 3, Pamulang Barat, Pamulang, '
        'Kota Tangerang Selatan',
      );
    });

    test('bagian yang berulang dilewati; kosong -> null', () {
      expect(
        composeAddress(
          thoroughfare: 'Jl. Prambanan',
          subLocality: 'Pamulang',
          locality: 'pamulang',
        ),
        'Jl. Prambanan, Pamulang',
      );
      expect(composeAddress(street: '  ', locality: ''), isNull);
    });
  });

  test('singkatan zona Indonesia', () {
    expect(zoneAbbreviation('Asia/Jakarta'), 'WIB');
    expect(zoneAbbreviation('Asia/Makassar'), 'WITA');
    expect(zoneAbbreviation('Asia/Jayapura'), 'WIT');
    expect(zoneAbbreviation('Europe/Paris'), isNull);
    expect(zoneAbbreviation(null), isNull);
  });

  testWidgets('layar lokasi: nama jalan, koordinat, tanggal, dan jam', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Check In').first);
    await settle(tester);

    expect(
      find.text('Jl. Medan Merdeka Barat No. 12, Gambir, Jakarta Pusat'),
      findsOneWidget,
    );
    expect(find.text('Kantor Pusat · -6.20012, 106.81655'), findsOneWidget);
    expect(find.text('Senin, 26 Oktober 2026'), findsOneWidget);
    expect(find.text('09:41:00 WIB'), findsOneWidget);
    expect(find.text('Jam resmi dicatat server saat dikirim'), findsOneWidget);
  });

  testWidgets('nama jalan tidak tersedia: koordinat tetap tampil', (
    tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [addressServiceProvider.overrideWithValue(_NoAddress())],
    );
    await tester.tap(find.text('Check In').first);
    await settle(tester);

    expect(find.text('Nama jalan tidak tersedia'), findsOneWidget);
    expect(find.text('Kantor Pusat · -6.20012, 106.81655'), findsOneWidget);
  });
}
