// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeSummary _$EmployeeSummaryFromJson(Map<String, dynamic> json) =>
    EmployeeSummary(
      id: (json['id'] as num).toInt(),
      employeeNumber: json['employee_number'] as String,
      name: json['name'] as String,
      department: json['department'] as String?,
    );

Map<String, dynamic> _$EmployeeSummaryToJson(EmployeeSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_number': instance.employeeNumber,
      'name': instance.name,
      'department': instance.department,
    };
