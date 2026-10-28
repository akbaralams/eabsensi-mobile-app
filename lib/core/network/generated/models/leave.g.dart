// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Leave _$LeaveFromJson(Map<String, dynamic> json) => Leave(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  attendanceStatusId: (json['attendance_status_id'] as num).toInt(),
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  reason: json['reason'] as String?,
  status: LeaveStatus.fromJson(json['status'] as String),
  statusLabel: json['status_label'] as String,
);

Map<String, dynamic> _$LeaveToJson(Leave instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'attendance_status_id': instance.attendanceStatusId,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'reason': instance.reason,
  'status': instance.status,
  'status_label': instance.statusLabel,
};
