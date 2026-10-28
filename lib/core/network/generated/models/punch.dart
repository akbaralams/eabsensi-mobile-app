// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'punch_source.dart';
import 'punch_status.dart';

part 'punch.g.dart';

@JsonSerializable()
class Punch {
  const Punch({
    required this.id,
    required this.punchedAt,
    required this.source,
    required this.status,
    required this.statusLabel,
    required this.hasPhoto,
  });

  factory Punch.fromJson(Map<String, Object?> json) => _$PunchFromJson(json);

  final int id;
  @JsonKey(name: 'punched_at')
  final String punchedAt;

  /// `device` = dari mesin absensi (ADMS), langsung approved tanpa foto
  final PunchSource source;
  final PunchStatus status;
  @JsonKey(name: 'status_label')
  final String statusLabel;
  @JsonKey(name: 'has_photo')
  final bool hasPhoto;

  Map<String, Object?> toJson() => _$PunchToJson(this);
}
