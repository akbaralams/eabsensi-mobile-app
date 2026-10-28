// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_me_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/message.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  /// Masuk dan dapatkan token perangkat.
  ///
  /// Satu perangkat satu token: login ulang dengan `device_name` yang sama mencabut token lama.
  /// Token berlaku 30 hari (`SANCTUM_TOKEN_EXPIRATION`). Pesan galat sama untuk user tidak ada,.
  /// sandi salah, dan akun nonaktif.
  @POST('/auth/login')
  Future<LoginResponse> login({@Body() required LoginRequest body});

  /// Cabut token yang sedang dipakai
  @POST('/auth/logout')
  Future<Message> logout();

  /// Profil pengguna dan pengaturan aplikasi
  @GET('/me')
  Future<GetMeResponse> me();
}
