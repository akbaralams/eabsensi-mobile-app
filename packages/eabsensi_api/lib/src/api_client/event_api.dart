// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i4;

import 'package:dio/dio.dart' as _i7;
import 'package:eabsensi_api/src/model/evidence_form.dart' as _i9;
import 'package:eabsensi_api/src/operation/check_in_event.dart' as _i3;
import 'package:eabsensi_api/src/operation/list_events.dart' as _i2;
import 'package:eabsensi_api/src/response_wrapper/check_in_event_response.dart'
    as _i8;
import 'package:eabsensi_api/src/response_wrapper/list_events_response.dart'
    as _i6;
import 'package:eabsensi_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i5;

/// Event seperti upacara yang punya daftar hadir sendiri.
class EventApi {
  EventApi(_i1.Server server)
    : _listEvents = _i2.ListEvents(server.baseUrl, () => server.dio),
      _checkInEvent = _i3.CheckInEvent(server.baseUrl, () => server.dio);

  final _i2.ListEvents _listEvents;

  final _i3.CheckInEvent _checkInEvent;

  /// Event aktif hari ini yang boleh diikuti pegawai
  /// Event untuk semua pegawai, atau untuk department pegawai beserta induknya.
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
  _i4.Future<_i5.TonikResult<_i6.ListEventsResponse, _i7.Response<_i4.Object?>>>
  listEvents({_i5.TonikCancellation? cancellation}) async =>
      this._listEvents(cancellation: cancellation);

  /// Check-in ke event (sekali per pegawai)
  /// Penolakan aturan (422, `message` saja):
  /// - `Akun ini belum terhubung ke data pegawai.`
  /// - `Pegawai tidak aktif.`
  /// - `Event ini tidak aktif.`
  /// - `Anda tidak termasuk peserta event ini.`
  /// - `Check-in hanya bisa dilakukan pada tanggal event.`
  /// - `Check-in dibuka pukul {mulai} sampai {selesai}.`
  /// - `Anda sudah check-in di event ini.`
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
    _i5.TonikResult<_i8.CheckInEventResponse, _i7.Response<_i4.Object?>>
  >
  checkInEvent({
    required _i9.EvidenceForm body,
    required _i4.int event,
    _i5.TonikCancellation? cancellation,
  }) async =>
      this._checkInEvent(body: body, event: event, cancellation: cancellation);
}
