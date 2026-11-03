import 'dart:io';

import 'package:eabsensi_api/eabsensi_api.dart' as api;
import 'package:flutter/foundation.dart';
import 'package:tonik_util/tonik_util.dart' show TonikFilePath;

import '../../../core/api/api_client.dart';
import '../../../core/api/mappers.dart';
import '../domain/punch.dart';

/// `POST /punches` (multipart, tanpa field waktu) dan `GET /punches?date=`.
class ApiPunchRepository implements PunchRepository {
  ApiPunchRepository(this._api);

  final ApiClient _api;

  /// [date] adalah tanggal zona bisnis (dari jam bisnis, bukan perangkat).
  @override
  Future<List<Punch>> list(DateTime date) => _api.send(
    () => _api.punches.listPunches(date: dateToApi(date)),
    (r) => r is api.ListPunchesResponse200
        ? List<Punch>.unmodifiable(r.body.data.map(punchFromApi))
        : null,
  );

  @override
  Future<Punch> create(EvidenceSubmission evidence) {
    if (isEmptyEvidence(evidence)) {
      return _api.postEmptyMultipart(
        '/punches',
        successStatus: 201,
        decode: (json) =>
            punchFromApi(api.PunchesPost201BodyModel.fromJson(json).data),
      );
    }
    return _api.send(
      () async => _api.punches.createPunch(body: evidenceForm(evidence)),
      (r) => r is api.CreatePunchResponse201 ? punchFromApi(r.body.data) : null,
    );
  }
}

/// Tanpa foto dan tanpa lokasi berpasangan: tidak ada bagian multipart.
bool isEmptyEvidence(EvidenceSubmission e) =>
    e.photoPath == null && (e.latitude == null || e.longitude == null);

/// Bukti punch/check-in sebagai form multipart kontrak (`EvidenceForm`):
/// `photo` berkas JPEG, `latitude`/`longitude` berpasangan, `accuracy` meter.
api.EvidenceForm evidenceForm(EvidenceSubmission e) {
  final paired = e.latitude != null && e.longitude != null;
  final path = e.photoPath;
  if (path != null && kDebugMode) {
    try {
      final kb = File(path).lengthSync() / 1024;
      debugPrint('Foto bukti terkirim: ${kb.toStringAsFixed(1)} KB ($path)');
    } on Object {
      // Ukuran hanya untuk log.
    }
  }
  return api.EvidenceForm(
    photo: path == null ? null : TonikFilePath(path, fileName: 'bukti.jpg'),
    latitude: paired ? e.latitude : null,
    longitude: paired ? e.longitude : null,
    accuracy: paired ? e.accuracy : null,
  );
}
