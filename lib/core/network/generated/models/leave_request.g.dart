// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) => LeaveRequest(
  attendanceStatusId: (json['attendance_status_id'] as num).toInt(),
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$LeaveRequestToJson(LeaveRequest instance) =>
    <String, dynamic>{
      'attendance_status_id': instance.attendanceStatusId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'reason': instance.reason,
    };
