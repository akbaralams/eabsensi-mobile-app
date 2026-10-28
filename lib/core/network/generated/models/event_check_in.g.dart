// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCheckIn _$EventCheckInFromJson(Map<String, dynamic> json) => EventCheckIn(
  eventId: (json['event_id'] as num).toInt(),
  checkedInAt: json['checked_in_at'] as String,
);

Map<String, dynamic> _$EventCheckInToJson(EventCheckIn instance) =>
    <String, dynamic>{
      'event_id': instance.eventId,
      'checked_in_at': instance.checkedInAt,
    };
