import '../../../core/network/api_error_mapper.dart';
import '../../../core/network/api_time.dart';
import '../../../core/network/generated/export.dart' as api;
import '../../punch/data/evidence_upload.dart';
import '../../punch/domain/punch.dart';
import '../domain/event_item.dart';

/// Client nyata: `GET /events` dan `POST /events/{id}/check-in` (multipart).
class RemoteEventRepository implements EventRepository {
  RemoteEventRepository(this._api);

  final api.EventApi _api;

  @override
  Future<List<EventItem>> listToday() => apiCall(() async {
    final res = await _api.listEvents();
    return res.data
        .map(
          (e) => EventItem(
            id: e.id,
            name: e.name,
            eventDate: parseApiDate(e.eventDate),
            startsAt: e.startsAt,
            endsAt: e.endsAt,
            checkedIn: e.checkedIn,
          ),
        )
        .toList(growable: false);
  });

  @override
  Future<EventCheckIn> checkIn(int eventId, EvidenceSubmission evidence) =>
      apiCall(() async {
        final parts = await EvidenceParts.from(evidence);
        final res = await _api.checkInEvent(
          event: eventId,
          photo: parts.photo,
          latitude: parts.latitude,
          longitude: parts.longitude,
          accuracy: parts.accuracy,
        );
        return EventCheckIn(
          eventId: res.data.eventId,
          checkedInAt: parseBusinessDateTime(res.data.checkedInAt),
        );
      });
}
