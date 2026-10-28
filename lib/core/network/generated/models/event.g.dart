// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  eventDate: json['event_date'] as String,
  startsAt: json['starts_at'] as String,
  endsAt: json['ends_at'] as String,
  checkedIn: json['checked_in'] as bool,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'event_date': instance.eventDate,
  'starts_at': instance.startsAt,
  'ends_at': instance.endsAt,
  'checked_in': instance.checkedIn,
};
