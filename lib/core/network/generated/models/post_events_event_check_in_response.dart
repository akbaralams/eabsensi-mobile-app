// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'event_check_in.dart';

part 'post_events_event_check_in_response.g.dart';

@JsonSerializable()
class PostEventsEventCheckInResponse {
  const PostEventsEventCheckInResponse({required this.data});

  factory PostEventsEventCheckInResponse.fromJson(Map<String, Object?> json) =>
      _$PostEventsEventCheckInResponseFromJson(json);

  final EventCheckIn data;

  Map<String, Object?> toJson() => _$PostEventsEventCheckInResponseToJson(this);
}
