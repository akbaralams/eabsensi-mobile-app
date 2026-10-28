// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'leave.dart';

part 'post_leaves_response.g.dart';

@JsonSerializable()
class PostLeavesResponse {
  const PostLeavesResponse({required this.data});

  factory PostLeavesResponse.fromJson(Map<String, Object?> json) =>
      _$PostLeavesResponseFromJson(json);

  final Leave data;

  Map<String, Object?> toJson() => _$PostLeavesResponseToJson(this);
}
