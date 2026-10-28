// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'option.g.dart';

@JsonSerializable()
class Option {
  const Option({required this.id, required this.code, required this.name});

  factory Option.fromJson(Map<String, Object?> json) => _$OptionFromJson(json);

  final int id;
  final String code;
  final String name;

  Map<String, Object?> toJson() => _$OptionToJson(this);
}
