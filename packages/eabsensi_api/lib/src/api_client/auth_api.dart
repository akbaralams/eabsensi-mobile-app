// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i8;

import 'package:dio/dio.dart' as _i11;
import 'package:eabsensi_api/src/model/login_request.dart' as _i12;
import 'package:eabsensi_api/src/model/refresh_request.dart' as _i16;
import 'package:eabsensi_api/src/operation/login.dart' as _i2;
import 'package:eabsensi_api/src/operation/login_v2.dart' as _i4;
import 'package:eabsensi_api/src/operation/logout.dart' as _i3;
import 'package:eabsensi_api/src/operation/logout_v2.dart' as _i6;
import 'package:eabsensi_api/src/operation/me_operation.dart' as _i7;
import 'package:eabsensi_api/src/operation/refresh_token.dart' as _i5;
import 'package:eabsensi_api/src/response_wrapper/login_response_wrapper.dart'
    as _i10;
import 'package:eabsensi_api/src/response_wrapper/login_v2_response_wrapper.dart'
    as _i14;
import 'package:eabsensi_api/src/response_wrapper/logout_response.dart' as _i13;
import 'package:eabsensi_api/src/response_wrapper/logout_v2_response.dart'
    as _i17;
import 'package:eabsensi_api/src/response_wrapper/me_operation_response.dart'
    as _i18;
import 'package:eabsensi_api/src/response_wrapper/refresh_token_response.dart'
    as _i15;
import 'package:eabsensi_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i9;

/// Login per perangkat, profil, dan logout.
class AuthApi {
  AuthApi(_i1.Server server)
    : _login = _i2.Login(server.baseUrl, () => server.dio),
      _logout = _i3.Logout(server.baseUrl, () => server.dio),
      _loginV2 = _i4.LoginV2(server.baseUrl, () => server.dio),
      _refreshToken = _i5.RefreshToken(server.baseUrl, () => server.dio),
      _logoutV2 = _i6.LogoutV2(server.baseUrl, () => server.dio),
      _meOperation = _i7.MeOperation(server.baseUrl, () => server.dio);

  final _i2.Login _login;

  final _i3.Logout _logout;

  final _i4.LoginV2 _loginV2;

  final _i5.RefreshToken _refreshToken;

  final _i6.LogoutV2 _logoutV2;

  final _i7.MeOperation _meOperation;

  /// Masuk dan dapatkan token perangkat
  /// Satu perangkat satu token: login ulang dengan `device_name` yang sama mencabut token lama.
  /// Token berlaku 30 hari (`SANCTUM_TOKEN_EXPIRATION`). Pesan galat sama untuk user tidak ada,
  /// sandi salah, dan akun nonaktif.
  ///
  ///
  /// Response 403 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Akun ini belum terhubung ke data pegawai."
  /// }
  /// ```
  ///
  /// Response 422 (application/json):
  /// **Example** "kredensial":
  /// ```json
  /// {
  ///   "message": "Username atau kata sandi salah."
  /// }
  /// ```
  _i8.Future<
    _i9.TonikResult<_i10.LoginResponseWrapper, _i11.Response<_i8.Object?>>
  >
  login({
    required _i12.LoginRequest body,
    _i9.TonikCancellation? cancellation,
  }) async => this._login(body: body, cancellation: cancellation);

  /// Cabut token yang sedang dipakai
  ///
  /// Response 200 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Berhasil keluar."
  /// }
  /// ```
  ///
  /// Response 401 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Unauthenticated."
  /// }
  /// ```
  _i8.Future<_i9.TonikResult<_i13.LogoutResponse, _i11.Response<_i8.Object?>>>
  logout({_i9.TonikCancellation? cancellation}) async =>
      this._logout(cancellation: cancellation);

  /// Masuk dan dapatkan token akses + refresh token (v2)
  /// Aturan, pesan galat, dan batas laju sama dengan `POST /auth/login`. Token akses berlaku
  /// `MOBILE_ACCESS_TOKEN_TTL_MINUTES` (default 7 hari) dan dipakai ke semua endpoint `/api/*` seperti token v1.
  /// Refresh token (default 90 hari) hanya untuk `POST /v2/auth/refresh`; sebagai Bearer ditolak 403.
  /// Satu perangkat satu pasangan token: login ulang dengan `device_name` yang sama mencabut pasangan lama.
  ///
  _i8.Future<
    _i9.TonikResult<_i14.LoginV2ResponseWrapper, _i11.Response<_i8.Object?>>
  >
  loginV2({
    required _i12.LoginRequest body,
    _i9.TonikCancellation? cancellation,
  }) async => this._loginV2(body: body, cancellation: cancellation);

  /// Tukar refresh token dengan pasangan token baru (rotasi)
  /// Refresh token lama langsung tidak berlaku. Tidak memakai sandi, jadi murah. Panggil sebelum
  /// `token_expires_at` lewat (mis. saat aplikasi dibuka dan sisa masa berlaku < 1 hari) atau setelah 401.
  /// 401 berarti refresh token tidak sah, kedaluwarsa, sudah dipakai, atau akun dinonaktifkan: kembali ke login.
  ///
  ///
  /// Response 401 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Unauthenticated."
  /// }
  /// ```
  ///
  /// Response 403 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Akun ini belum terhubung ke data pegawai."
  /// }
  /// ```
  _i8.Future<
    _i9.TonikResult<_i15.RefreshTokenResponse, _i11.Response<_i8.Object?>>
  >
  refreshToken({
    required _i16.RefreshRequest body,
    _i9.TonikCancellation? cancellation,
  }) async => this._refreshToken(body: body, cancellation: cancellation);

  /// Cabut token akses dan refresh token perangkat ini
  ///
  /// Response 200 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Berhasil keluar."
  /// }
  /// ```
  ///
  /// Response 401 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Unauthenticated."
  /// }
  /// ```
  _i8.Future<_i9.TonikResult<_i17.LogoutV2Response, _i11.Response<_i8.Object?>>>
  logoutV2({_i9.TonikCancellation? cancellation}) async =>
      this._logoutV2(cancellation: cancellation);

  /// Profil pengguna dan pengaturan aplikasi
  ///
  /// Response 401 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Unauthenticated."
  /// }
  /// ```
  _i8.Future<
    _i9.TonikResult<_i18.MeOperationResponse, _i11.Response<_i8.Object?>>
  >
  meOperation({_i9.TonikCancellation? cancellation}) async =>
      this._meOperation(cancellation: cancellation);
}
