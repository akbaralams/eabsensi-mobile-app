import 'package:eabsensi_api/eabsensi_api.dart' as api;

import '../../../core/api/api_client.dart';
import '../../../core/api/mappers.dart';
import '../../punch/data/api_punch_repository.dart';
import '../../punch/domain/punch.dart';
import '../domain/event_item.dart';

/// `GET /events` (event hari ini) dan `POST /events/{id}/check-in` dengan
/// bukti yang sama dengan punch (foto hasil kompresi kamera yang sama).
class ApiEventRepository implements EventRepository {
  ApiEventRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<EventItem>> listToday() => _api.send(
    () => _api.events.listEvents(),
    (r) => r is api.ListEventsResponse200
        ? List<EventItem>.unmodifiable(r.body.data.map(eventFromApi))
        : null,
  );

  /// 404 (event dihapus) -> `NotFoundFailure`: pemanggil memuat ulang daftar.
  @override
  Future<EventCheckIn> checkIn(int eventId, EvidenceSubmission evidence) {
    if (isEmptyEvidence(evidence)) {
      return _api.postEmptyMultipart(
        '/events/$eventId/check-in',
        successStatus: 201,
        decode: (json) => checkInFromApi(
          api.EventsEventCheckInPost201BodyModel.fromJson(json).data,
        ),
      );
    }
    return _api.send(
      () async => _api.events.checkInEvent(
        event: eventId,
        body: evidenceForm(evidence),
      ),
      (r) =>
          r is api.CheckInEventResponse201 ? checkInFromApi(r.body.data) : null,
    );
  }
}
