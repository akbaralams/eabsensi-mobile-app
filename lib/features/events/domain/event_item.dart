import 'package:flutter/foundation.dart';

import '../../punch/domain/location.dart';
import '../../punch/domain/punch.dart';

@immutable
class EventItem {
  const EventItem({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.startsAt,
    required this.endsAt,
    required this.checkedIn,
    this.workLocation,
  });

  final int id;
  final String name;
  final DateTime eventDate;

  /// "HH:mm" di zona waktu bisnis.
  final String startsAt;
  final String endsAt;
  final bool checkedIn;

  /// Lokasi yang berlaku untuk check-in; `null` bila tidak dibatasi radius.
  final OfficeArea? workLocation;

  EventItem copyWith({bool? checkedIn}) => EventItem(
    id: id,
    name: name,
    eventDate: eventDate,
    startsAt: startsAt,
    endsAt: endsAt,
    checkedIn: checkedIn ?? this.checkedIn,
    workLocation: workLocation,
  );
}

@immutable
class EventCheckIn {
  const EventCheckIn({
    required this.eventId,
    required this.checkedInAt,
    this.locationFlags = const [],
  });

  final int eventId;
  final DateTime checkedInAt;

  /// Tanda lokasi dari server untuk ditinjau.
  final List<String> locationFlags;
}

abstract class EventRepository {
  Future<List<EventItem>> listToday();

  Future<EventCheckIn> checkIn(int eventId, EvidenceSubmission evidence);
}
