// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'employee_summary.dart';

part 'me.g.dart';

@JsonSerializable()
class Me {
  const Me({
    required this.id,
    required this.name,
    required this.username,
    required this.employee,
    required this.timezone,
    required this.requiresPhoto,
    required this.requiresApproval,
  });

  factory Me.fromJson(Map<String, Object?> json) => _$MeFromJson(json);

  final int id;
  final String name;
  final String username;
  final EmployeeSummary? employee;
  final String timezone;

  /// Foto wajib pada punch dan check-in
  @JsonKey(name: 'requires_photo')
  final bool requiresPhoto;

  /// Punch berstatus pending sampai disetujui
  @JsonKey(name: 'requires_approval')
  final bool requiresApproval;

  Map<String, Object?> toJson() => _$MeToJson(this);
}
