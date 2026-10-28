// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Me _$MeFromJson(Map<String, dynamic> json) => Me(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  username: json['username'] as String,
  employee: json['employee'] == null
      ? null
      : EmployeeSummary.fromJson(json['employee'] as Map<String, dynamic>),
  timezone: json['timezone'] as String,
  requiresPhoto: json['requires_photo'] as bool,
  requiresApproval: json['requires_approval'] as bool,
);

Map<String, dynamic> _$MeToJson(Me instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'employee': instance.employee,
  'timezone': instance.timezone,
  'requires_photo': instance.requiresPhoto,
  'requires_approval': instance.requiresApproval,
};
