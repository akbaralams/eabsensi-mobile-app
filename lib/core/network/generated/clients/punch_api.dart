// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_punches_response.dart';
import '../models/post_punches_response.dart';

part 'punch_api.g.dart';

@RestApi()
abstract class PunchApi {
  factory PunchApi(Dio dio, {String? baseUrl}) = _PunchApi;

  /// Punch milik sendiri pada satu hari (semua status).
  ///
  /// [date] - Tanggal di zona bisnis. Kosong atau tidak valid berarti hari ini.
  @GET('/punches')
  Future<GetPunchesResponse> listPunches({@Query('date') String? date});

  /// Catat punch (waktu dari server).
  ///
  /// Field waktu dari klien diabaikan. Status `pending` bila profil `requires_approval` (belum dihitung sebagai.
  /// kehadiran sampai disetujui atasan), selain itu `approved`.
  ///
  /// Penolakan aturan (422, `message` saja):.
  /// - `Akun ini belum terhubung ke data pegawai.`.
  /// - `Pegawai tidak aktif.`.
  /// - `Tunggu {n} detik sebelum melakukan punch lagi.` (n = `ATTENDANCE_MOBILE_MIN_INTERVAL`, default 60).
  /// - `Periode bulan ini sudah ditutup.`.
  ///
  /// [photo] - JPG/PNG maks 4 MB; wajib bila `requires_photo`.
  ///
  /// [latitude] - Wajib bersama longitude.
  ///
  /// [longitude] - Wajib bersama latitude.
  ///
  /// [accuracy] - Akurasi lokasi dalam meter.
  @MultiPart()
  @POST('/punches')
  Future<PostPunchesResponse> createPunch({
    @Part(name: 'photo') MultipartFile? photo,
    @Part(name: 'latitude') num? latitude,
    @Part(name: 'longitude') num? longitude,
    @Part(name: 'accuracy') int? accuracy,
  });
}
