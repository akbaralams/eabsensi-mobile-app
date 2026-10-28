// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'event_check_in.g.dart';

@JsonSerializable()
class EventCheckIn {
  const EventCheckIn({required this.eventId, required this.checkedInAt});

  factory EventCheckIn.fromJson(Map<String, Object?> json) =>
      _$EventCheckInFromJson(json);

  @JsonKey(name: 'event_id')
  final int eventId;
  @JsonKey(name: 'checked_in_at')
  final String checkedInAt;

  Map<String, Object?> toJson() => _$EventCheckInToJson(this);
}
