// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i4;

import 'package:dio/dio.dart' as _i7;
import 'package:eabsensi_api/src/model/leave_request.dart' as _i9;
import 'package:eabsensi_api/src/operation/create_leave.dart' as _i3;
import 'package:eabsensi_api/src/operation/list_leaves.dart' as _i2;
import 'package:eabsensi_api/src/response_wrapper/create_leave_response.dart'
    as _i8;
import 'package:eabsensi_api/src/response_wrapper/list_leaves_response.dart'
    as _i6;
import 'package:eabsensi_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i5;

/// Pengajuan cuti, izin, atau dinas; persetujuan di web operator.
class CutiApi {
  CutiApi(_i1.Server server)
    : _listLeaves = _i2.ListLeaves(server.baseUrl, () => server.dio),
      _createLeave = _i3.CreateLeave(server.baseUrl, () => server.dio);

  final _i2.ListLeaves _listLeaves;

  final _i3.CreateLeave _createLeave;

  /// Pengajuan cuti milik sendiri dan jenis yang bisa dipilih
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
  _i4.Future<_i5.TonikResult<_i6.ListLeavesResponse, _i7.Response<_i4.Object?>>>
  listLeaves({_i5.TonikCancellation? cancellation}) async =>
      this._listLeaves(cancellation: cancellation);

  /// Ajukan cuti (menunggu persetujuan atasan di web)
  /// Penolakan aturan (422, `message` saja):
  /// - `Rentang cuti maksimal 62 hari.`
  /// - `Pegawai sudah punya pengajuan yang menunggu atau disetujui pada tanggal tersebut.`
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
  _i4.Future<
    _i5.TonikResult<_i8.CreateLeaveResponse, _i7.Response<_i4.Object?>>
  >
  createLeave({
    required _i9.LeaveRequest body,
    _i5.TonikCancellation? cancellation,
  }) async => this._createLeave(body: body, cancellation: cancellation);
}
