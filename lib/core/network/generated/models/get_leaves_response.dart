// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'leave.dart';
import 'option.dart';

part 'get_leaves_response.g.dart';

@JsonSerializable()
class GetLeavesResponse {
  const GetLeavesResponse({required this.data, required this.types});

  factory GetLeavesResponse.fromJson(Map<String, Object?> json) =>
      _$GetLeavesResponseFromJson(json);

  final List<Leave> data;

  /// Status kehadiran aktif, urut nama.
  final List<Option> types;

  Map<String, Object?> toJson() => _$GetLeavesResponseToJson(this);
}
