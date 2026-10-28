// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'leave_request.g.dart';

@JsonSerializable()
class LeaveRequest {
  const LeaveRequest({
    required this.attendanceStatusId,
    required this.startDate,
    required this.endDate,
    this.reason,
  });

  factory LeaveRequest.fromJson(Map<String, Object?> json) =>
      _$LeaveRequestFromJson(json);

  /// Salah satu `types[].id` dari GET /leaves
  @JsonKey(name: 'attendance_status_id')
  final int attendanceStatusId;
  @JsonKey(name: 'start_date')
  final String startDate;

  /// Sama dengan atau setelah start_date
  @JsonKey(name: 'end_date')
  final String endDate;
  final String? reason;

  Map<String, Object?> toJson() => _$LeaveRequestToJson(this);
}
