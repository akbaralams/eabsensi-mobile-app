// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_events_response.dart';
import '../models/post_events_event_check_in_response.dart';

part 'event_api.g.dart';

@RestApi()
abstract class EventApi {
  factory EventApi(Dio dio, {String? baseUrl}) = _EventApi;

  /// Event aktif hari ini yang boleh diikuti pegawai.
  ///
  /// Event untuk semua pegawai, atau untuk department pegawai beserta induknya.
  @GET('/events')
  Future<GetEventsResponse> listEvents();

  /// Check-in ke event (sekali per pegawai).
  ///
  /// Penolakan aturan (422, `message` saja):.
  /// - `Akun ini belum terhubung ke data pegawai.`.
  /// - `Pegawai tidak aktif.`.
  /// - `Event ini tidak aktif.`.
  /// - `Anda tidak termasuk peserta event ini.`.
  /// - `Check-in hanya bisa dilakukan pada tanggal event.`.
  /// - `Check-in dibuka pukul {mulai} sampai {selesai}.`.
  /// - `Anda sudah check-in di event ini.`.
  ///
  /// [photo] - JPG/PNG maks 4 MB; wajib bila `requires_photo`.
  ///
  /// [latitude] - Wajib bersama longitude.
  ///
  /// [longitude] - Wajib bersama latitude.
  ///
  /// [accuracy] - Akurasi lokasi dalam meter.
  @MultiPart()
  @POST('/events/{event}/check-in')
  Future<PostEventsEventCheckInResponse> checkInEvent({
    @Path('event') required int event,
    @Part(name: 'photo') MultipartFile? photo,
    @Part(name: 'latitude') num? latitude,
    @Part(name: 'longitude') num? longitude,
    @Part(name: 'accuracy') int? accuracy,
  });
}
