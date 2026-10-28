import '../../../core/format/id_format.dart';
import '../../../core/network/api_error_mapper.dart';
import '../../../core/network/api_time.dart';
import '../../../core/network/generated/export.dart' as api;
import '../domain/punch.dart';
import 'evidence_upload.dart';

/// Client nyata: `GET /punches?date=` dan `POST /punches` (multipart). Waktu
/// punch selalu dari server.
class RemotePunchRepository implements PunchRepository {
  RemotePunchRepository(this._api);

  final api.PunchApi _api;

  @override
  Future<List<Punch>> list(DateTime date) => apiCall(() async {
    final res = await _api.listPunches(date: IdFormat.apiDate(date));
    return res.data.map(punchFromApi).toList(growable: false);
  });

  @override
  Future<Punch> create(EvidenceSubmission evidence) => apiCall(() async {
    final parts = await EvidenceParts.from(evidence);
    final res = await _api.createPunch(
      photo: parts.photo,
      latitude: parts.latitude,
      longitude: parts.longitude,
      accuracy: parts.accuracy,
    );
    return punchFromApi(res.data);
  });
}

Punch punchFromApi(api.Punch p) => Punch(
  id: p.id,
  punchedAt: parseBusinessDateTime(p.punchedAt),
  source: p.source.json ?? 'unknown',
  // Status yang tidak dikenal tidak boleh terbaca sebagai disetujui.
  status: switch (p.status) {
    api.PunchStatus.approved => PunchStatus.approved,
    api.PunchStatus.rejected => PunchStatus.rejected,
    _ => PunchStatus.pending,
  },
  statusLabel: p.statusLabel,
  hasPhoto: p.hasPhoto,
);
