// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'event.dart';

part 'get_events_response.g.dart';

@JsonSerializable()
class GetEventsResponse {
  const GetEventsResponse({required this.data});

  factory GetEventsResponse.fromJson(Map<String, Object?> json) =>
      _$GetEventsResponseFromJson(json);

  final List<Event> data;

  Map<String, Object?> toJson() => _$GetEventsResponseToJson(this);
}
