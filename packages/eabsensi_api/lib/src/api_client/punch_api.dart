// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i4;

import 'package:dio/dio.dart' as _i7;
import 'package:eabsensi_api/src/model/evidence_form.dart' as _i9;
import 'package:eabsensi_api/src/operation/create_punch.dart' as _i3;
import 'package:eabsensi_api/src/operation/list_punches.dart' as _i2;
import 'package:eabsensi_api/src/response_wrapper/create_punch_response.dart'
    as _i8;
import 'package:eabsensi_api/src/response_wrapper/list_punches_response.dart'
    as _i6;
import 'package:eabsensi_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i5;

/// Absen masuk/pulang dari aplikasi, dengan foto dan lokasi.
class PunchApi {
  PunchApi(_i1.Server server)
    : _listPunches = _i2.ListPunches(server.baseUrl, () => server.dio),
      _createPunch = _i3.CreatePunch(server.baseUrl, () => server.dio);

  final _i2.ListPunches _listPunches;

  final _i3.CreatePunch _createPunch;

  /// Punch milik sendiri pada satu hari (semua status)
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
    _i5.TonikResult<_i6.ListPunchesResponse, _i7.Response<_i4.Object?>>
  >
  listPunches({_i5.Date? date, _i5.TonikCancellation? cancellation}) async =>
      this._listPunches(date: date, cancellation: cancellation);

  /// Catat punch (waktu dari server)
  /// Field waktu dari klien diabaikan. Status `pending` bila profil `requires_approval` (belum dihitung sebagai
  /// kehadiran sampai disetujui atasan), selain itu `approved`.
  ///
  /// Penolakan aturan (422, `message` saja):
  /// - `Akun ini belum terhubung ke data pegawai.`
  /// - `Pegawai tidak aktif.`
  /// - `Tunggu {n} detik sebelum melakukan punch lagi.` (n = `ATTENDANCE_MOBILE_MIN_INTERVAL`, default 60)
  /// - `Periode bulan ini sudah ditutup.`
  ///
  ///
  /// Response 401 (application/json):
  /// **Example**:
  /// ```json
  /// {
  ///   "message": "Unauthenticated."
  /// }
  /// ```
  _i4.Future<
    _i5.TonikResult<_i8.CreatePunchResponse, _i7.Response<_i4.Object?>>
  >
  createPunch({
    required _i9.EvidenceForm body,
    _i5.TonikCancellation? cancellation,
  }) async => this._createPunch(body: body, cancellation: cancellation);
}
