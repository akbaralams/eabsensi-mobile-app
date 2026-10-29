// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/leave_status_model.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Leave extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Leave({
    required this.id,
    required this.$type,
    required this.attendanceStatusId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.statusLabel,
  });

  factory Leave.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'type',
        r'attendance_status_id',
        r'start_date',
        r'end_date',
        r'reason',
        r'status',
        r'status_label',
      },
      listKeys: {},
      context: r'Leave',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Leave(
      id: _$values[r'id'].decodeSimpleInt(context: r'Leave.id'),
      $type: _$values[r'type'].decodeSimpleString(context: r'Leave.type'),
      attendanceStatusId: _$values[r'attendance_status_id'].decodeSimpleInt(
        context: r'Leave.attendance_status_id',
      ),
      startDate: _$values[r'start_date'].decodeSimpleDate(
        context: r'Leave.start_date',
      ),
      endDate: _$values[r'end_date'].decodeSimpleDate(
        context: r'Leave.end_date',
      ),
      reason: _$values[r'reason'].decodeSimpleNullableString(
        context: r'Leave.reason',
      ),
      status: _i4.LeaveStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
      statusLabel: _$values[r'status_label'].decodeSimpleString(
        context: r'Leave.status_label',
      ),
    );
  }

  factory Leave.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Leave');
    return Leave(
      id: _$map[r'id'].decodeJsonInt(context: r'Leave.id'),
      $type: _$map[r'type'].decodeJsonString(context: r'Leave.type'),
      attendanceStatusId: _$map[r'attendance_status_id'].decodeJsonInt(
        context: r'Leave.attendance_status_id',
      ),
      startDate: _$map[r'start_date'].decodeJsonDate(
        context: r'Leave.start_date',
      ),
      endDate: _$map[r'end_date'].decodeJsonDate(context: r'Leave.end_date'),
      reason: _$map[r'reason'].decodeJsonNullableString(
        context: r'Leave.reason',
      ),
      status: _i4.LeaveStatusModel.fromJson(_$map[r'status']),
      statusLabel: _$map[r'status_label'].decodeJsonString(
        context: r'Leave.status_label',
      ),
    );
  }

  factory Leave.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'type',
        r'attendance_status_id',
        r'start_date',
        r'end_date',
        r'reason',
        r'status',
        r'status_label',
      },
      listKeys: {},
      context: r'Leave',
    );
    return Leave(
      id: _$values[r'id'].decodeFormInt(context: r'Leave.id'),
      $type: _$values[r'type'].decodeFormString(context: r'Leave.type'),
      attendanceStatusId: _$values[r'attendance_status_id'].decodeFormInt(
        context: r'Leave.attendance_status_id',
      ),
      startDate: _$values[r'start_date'].decodeFormDate(
        context: r'Leave.start_date',
      ),
      endDate: _$values[r'end_date'].decodeFormDate(context: r'Leave.end_date'),
      reason: _$values[r'reason'].decodeFormNullableString(
        context: r'Leave.reason',
      ),
      status: _i4.LeaveStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
      statusLabel: _$values[r'status_label'].decodeFormString(
        context: r'Leave.status_label',
      ),
    );
  }

  final _i3.int id;

  /// Nama jenis cuti
  final _i3.String $type;

  final _i3.int attendanceStatusId;

  final _i1.Date startDate;

  final _i1.Date endDate;

  final _i3.String? reason;

  final _i4.LeaveStatusModel status;

  /// **Example**:
  /// ```
  /// Menunggu
  /// ```
  final _i3.String statusLabel;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'type': this.$type,
    r'attendance_status_id': this.attendanceStatusId,
    r'start_date': this.startDate.toJson(),
    r'end_date': this.endDate.toJson(),
    r'reason': this.reason,
    r'status': this.status.toJson(),
    r'status_label': this.statusLabel,
  };

  Leave Function({
    _i3.int? id,
    _i3.String? $type,
    _i3.int? attendanceStatusId,
    _i1.Date? startDate,
    _i1.Date? endDate,
    _i3.String? reason,
    _i4.LeaveStatusModel? status,
    _i3.String? statusLabel,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.int? id,
      _i3.String? $type,
      _i3.int? attendanceStatusId,
      _i1.Date? startDate,
      _i1.Date? endDate,
      _i3.Object? reason = _sentinel,
      _i4.LeaveStatusModel? status,
      _i3.String? statusLabel,
    }) => Leave(
      id: id ?? this.id,
      $type: $type ?? this.$type,
      attendanceStatusId: attendanceStatusId ?? this.attendanceStatusId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: _i3.identical(reason, _sentinel)
          ? this.reason
          : (reason as _i3.String?),
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Leave &&
        other.id == this.id &&
        other.$type == this.$type &&
        other.attendanceStatusId == this.attendanceStatusId &&
        other.startDate == this.startDate &&
        other.endDate == this.endDate &&
        other.reason == this.reason &&
        other.status == this.status &&
        other.statusLabel == this.statusLabel;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.$type,
      this.attendanceStatusId,
      this.startDate,
      this.endDate,
      this.reason,
      this.status,
      this.statusLabel,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id.toString());
    _$result[r'type'] = _i1.PropertyValue.scalar(this.$type);
    _$result[r'attendance_status_id'] = _i1.PropertyValue.scalar(
      this.attendanceStatusId.toString(),
    );
    _$result[r'start_date'] = _i1.PropertyValue.scalar(
      this.startDate.toString(),
    );
    _$result[r'end_date'] = _i1.PropertyValue.scalar(this.endDate.toString());
    if (this.reason != null) {
      _$result[r'reason'] = _i1.PropertyValue.scalar(this.reason!);
    }
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status.toJson());
    _$result[r'status_label'] = _i1.PropertyValue.scalar(this.statusLabel);
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Leave: complex types cannot be URI-encoded',
    );
  }
}
