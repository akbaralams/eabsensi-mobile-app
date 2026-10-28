// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_leaves_response.dart';
import '../models/leave_request.dart';
import '../models/post_leaves_response.dart';

part 'cuti_api.g.dart';

@RestApi()
abstract class CutiApi {
  factory CutiApi(Dio dio, {String? baseUrl}) = _CutiApi;

  /// Pengajuan cuti milik sendiri dan jenis yang bisa dipilih
  @GET('/leaves')
  Future<GetLeavesResponse> listLeaves();

  /// Ajukan cuti (menunggu persetujuan atasan di web).
  ///
  /// Penolakan aturan (422, `message` saja):.
  /// - `Rentang cuti maksimal 62 hari.`.
  /// - `Pegawai sudah punya pengajuan yang menunggu atau disetujui pada tanggal tersebut.`.
  @POST('/leaves')
  Future<PostLeavesResponse> createLeave({@Body() required LeaveRequest body});
}
