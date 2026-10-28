// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  const Event({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.startsAt,
    required this.endsAt,
    required this.checkedIn,
  });

  factory Event.fromJson(Map<String, Object?> json) => _$EventFromJson(json);

  final int id;
  final String name;
  @JsonKey(name: 'event_date')
  final String eventDate;
  @JsonKey(name: 'starts_at')
  final String startsAt;
  @JsonKey(name: 'ends_at')
  final String endsAt;
  @JsonKey(name: 'checked_in')
  final bool checkedIn;

  Map<String, Object?> toJson() => _$EventToJson(this);
}
