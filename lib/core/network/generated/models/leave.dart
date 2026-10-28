// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'leave_status.dart';

part 'leave.g.dart';

@JsonSerializable()
class Leave {
  const Leave({
    required this.id,
    required this.type,
    required this.attendanceStatusId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.statusLabel,
  });

  factory Leave.fromJson(Map<String, Object?> json) => _$LeaveFromJson(json);

  final int id;

  /// Nama jenis cuti
  final String type;
  @JsonKey(name: 'attendance_status_id')
  final int attendanceStatusId;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  final String? reason;
  final LeaveStatus status;
  @JsonKey(name: 'status_label')
  final String statusLabel;

  Map<String, Object?> toJson() => _$LeaveToJson(this);
}
