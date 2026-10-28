// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_events_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetEventsResponse _$GetEventsResponseFromJson(Map<String, dynamic> json) =>
    GetEventsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetEventsResponseToJson(GetEventsResponse instance) =>
    <String, dynamic>{'data': instance.data};
