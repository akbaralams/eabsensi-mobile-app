// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'clients/auth_api.dart';
import 'clients/punch_api.dart';
import 'clients/event_api.dart';
import 'clients/cuti_api.dart';

/// eAbsensi API mobile `v1.0.0`.
///
/// API untuk aplikasi pegawai (Flutter). Deskripsi naratif dan aturan bisnis ada di `docs/mobile-api.md`;.
/// perilakunya dijaga suite test kontrak `tests/contract/mobile` (Hurl). File ini bentuk mesin dari kontrak.
/// yang sama, untuk membangkitkan client dan memeriksa implementasi.
///
/// Semua respons JSON. Klien sebaiknya mengirim `Accept: application/json`.
/// Waktu yang dikembalikan selalu ISO 8601 di zona waktu bisnis (`timezone` di profil, default `Asia/Jakarta`).
///
/// **Dua bentuk 422.** Galat validasi berisi `message` + `errors` (nama field dijamin, teks pesan informatif).
/// Penolakan aturan bisnis berisi `message` saja; teksnya bagian dari kontrak dan aman ditampilkan apa adanya.
///
/// **Batas laju.** Login: 60/menit per IP dan 5/menit per akun+IP. Semua endpoint ber-token: 120/menit per token.
/// Punch, check-in event, dan pengajuan cuti: tambahan 20/menit per pengguna. Melebihi batas: 429.
///
class MobileApiClient {
  MobileApiClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0.0';

  AuthApi? _auth;
  PunchApi? _punch;
  EventApi? _event;
  CutiApi? _cuti;

  AuthApi get auth => _auth ??= AuthApi(_dio, baseUrl: _baseUrl);

  PunchApi get punch => _punch ??= PunchApi(_dio, baseUrl: _baseUrl);

  EventApi get event => _event ??= EventApi(_dio, baseUrl: _baseUrl);

  CutiApi get cuti => _cuti ??= CutiApi(_dio, baseUrl: _baseUrl);
}
