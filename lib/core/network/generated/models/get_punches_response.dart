// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'punch.dart';

part 'get_punches_response.g.dart';

@JsonSerializable()
class GetPunchesResponse {
  const GetPunchesResponse({required this.data});

  factory GetPunchesResponse.fromJson(Map<String, Object?> json) =>
      _$GetPunchesResponseFromJson(json);

  final List<Punch> data;

  Map<String, Object?> toJson() => _$GetPunchesResponseToJson(this);
}
