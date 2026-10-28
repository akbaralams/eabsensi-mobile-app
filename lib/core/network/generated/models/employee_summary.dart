// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'employee_summary.g.dart';

@JsonSerializable()
class EmployeeSummary {
  const EmployeeSummary({
    required this.id,
    required this.employeeNumber,
    required this.name,
    required this.department,
  });

  factory EmployeeSummary.fromJson(Map<String, Object?> json) =>
      _$EmployeeSummaryFromJson(json);

  final int id;
  @JsonKey(name: 'employee_number')
  final String employeeNumber;
  final String name;

  /// Nama department
  final String? department;

  Map<String, Object?> toJson() => _$EmployeeSummaryToJson(this);
}
