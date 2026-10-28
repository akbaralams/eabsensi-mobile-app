// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'punch.dart';

part 'post_punches_response.g.dart';

@JsonSerializable()
class PostPunchesResponse {
  const PostPunchesResponse({required this.data});

  factory PostPunchesResponse.fromJson(Map<String, Object?> json) =>
      _$PostPunchesResponseFromJson(json);

  final Punch data;

  Map<String, Object?> toJson() => _$PostPunchesResponseToJson(this);
}
