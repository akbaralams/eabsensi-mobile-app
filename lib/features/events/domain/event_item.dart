import 'package:flutter/foundation.dart';

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
  });

  final int id;
  final String name;
  final DateTime eventDate;

  /// "HH:mm" di zona waktu bisnis.
  final String startsAt;
  final String endsAt;
  final bool checkedIn;

  EventItem copyWith({bool? checkedIn}) => EventItem(
    id: id,
    name: name,
    eventDate: eventDate,
    startsAt: startsAt,
    endsAt: endsAt,
    checkedIn: checkedIn ?? this.checkedIn,
  );
}

@immutable
class EventCheckIn {
  const EventCheckIn({required this.eventId, required this.checkedInAt});

  final int eventId;
  final DateTime checkedInAt;
}

abstract class EventRepository {
  Future<List<EventItem>> listToday();

  Future<EventCheckIn> checkIn(int eventId, EvidenceSubmission evidence);
}
