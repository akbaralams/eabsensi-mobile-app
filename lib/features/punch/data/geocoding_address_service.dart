import 'dart:async';

import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart';

import '../domain/location.dart';

/// Nama jalan dari geocoder bawaan perangkat (Android Geocoder / CLGeocoder),
/// tanpa API key. Galat apa pun (tanpa jaringan, batas pemakaian, plugin
/// tidak ada) menjadi `null`: tampilan jatuh ke koordinat.
class GeocodingAddressService implements AddressService {
  const GeocodingAddressService();

  static const _timeout = Duration(seconds: 8);

  @override
  Future<String?> lookup(double latitude, double longitude) async {
    try {
      final places = await Geocoding(locale: const Locale('id', 'ID'))
          .placemarkFromCoordinates(latitude, longitude)
          .timeout(_timeout);
      if (places.isEmpty) return null;
      final p = places.first;
      return composeAddress(
        street: p.street,
        thoroughfare: p.thoroughfare,
        subThoroughfare: p.subThoroughfare,
        subLocality: p.subLocality,
        locality: p.locality,
        subAdministrativeArea: p.subAdministrativeArea,
        country: p.country,
        postalCode: p.postalCode,
      );
    } on Object {
      return null;
    }
  }
}

/// Alamat ringkas dari bagian placemark.
///
/// Android mengisi `street` dengan baris alamat lengkap ("Jl. X No.1, Kel,
/// Kec, Kota, Provinsi 12345, Indonesia"): dipakai apa adanya tanpa negara dan
/// kode pos. Selain itu (iOS, atau baris alamat kosong) disusun dari jalan,
/// nomor, kelurahan, kecamatan/kota, dan kabupaten/kota.
String? composeAddress({
  String? street,
  String? thoroughfare,
  String? subThoroughfare,
  String? subLocality,
  String? locality,
  String? subAdministrativeArea,
  String? country,
  String? postalCode,
}) {
  String? clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  final line = clean(street);
  if (line != null && line.contains(',')) {
    final zip = clean(postalCode);
    final nation = clean(country)?.toLowerCase();
    final segments = [
      for (final raw in line.split(','))
        if (clean(zip == null ? raw : raw.replaceAll(zip, '')) case final seg?
            when seg.toLowerCase() != nation)
          seg,
    ];
    return segments.isEmpty ? null : segments.join(', ');
  }

  final road = clean(thoroughfare);
  final number = clean(subThoroughfare);
  final head = road == null
      ? line
      : number == null
      ? road
      : '$road ${RegExp(r'^\d').hasMatch(number) ? 'No. $number' : number}';

  final parts = <String>[];
  for (final part in [
    head,
    clean(subLocality),
    clean(locality),
    clean(subAdministrativeArea),
  ]) {
    if (part == null) continue;
    final lower = part.toLowerCase();
    if (parts.any((p) => p.toLowerCase() == lower)) continue;
    parts.add(part);
  }
  return parts.isEmpty ? null : parts.join(', ');
}
