// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'me.dart';

part 'get_me_response.g.dart';

@JsonSerializable()
class GetMeResponse {
  const GetMeResponse({required this.data});

  factory GetMeResponse.fromJson(Map<String, Object?> json) =>
      _$GetMeResponseFromJson(json);

  final Me data;

  Map<String, Object?> toJson() => _$GetMeResponseToJson(this);
}
