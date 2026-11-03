// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class LeaveRequest extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const LeaveRequest({
    required this.attendanceStatusId,
    required this.startDate,
    required this.endDate,
    this.reason,
  });

  factory LeaveRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'attendance_status_id',
        r'start_date',
        r'end_date',
        r'reason',
      },
      listKeys: {},
      context: r'LeaveRequest',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return LeaveRequest(
      attendanceStatusId: _$values[r'attendance_status_id'].decodeSimpleInt(
        context: r'LeaveRequest.attendance_status_id',
      ),
      startDate: _$values[r'start_date'].decodeSimpleDate(
        context: r'LeaveRequest.start_date',
      ),
      endDate: _$values[r'end_date'].decodeSimpleDate(
        context: r'LeaveRequest.end_date',
      ),
      reason: _$values[r'reason'].decodeSimpleNullableString(
        context: r'LeaveRequest.reason',
      ),
    );
  }

  factory LeaveRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'LeaveRequest');
    return LeaveRequest(
      attendanceStatusId: _$map[r'attendance_status_id'].decodeJsonInt(
        context: r'LeaveRequest.attendance_status_id',
      ),
      startDate: _$map[r'start_date'].decodeJsonDate(
        context: r'LeaveRequest.start_date',
      ),
      endDate: _$map[r'end_date'].decodeJsonDate(
        context: r'LeaveRequest.end_date',
      ),
      reason: _$map[r'reason'].decodeJsonNullableString(
        context: r'LeaveRequest.reason',
      ),
    );
  }

  factory LeaveRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'attendance_status_id',
        r'start_date',
        r'end_date',
        r'reason',
      },
      listKeys: {},
      context: r'LeaveRequest',
    );
    return LeaveRequest(
      attendanceStatusId: _$values[r'attendance_status_id'].decodeFormInt(
        context: r'LeaveRequest.attendance_status_id',
      ),
      startDate: _$values[r'start_date'].decodeFormDate(
        context: r'LeaveRequest.start_date',
      ),
      endDate: _$values[r'end_date'].decodeFormDate(
        context: r'LeaveRequest.end_date',
      ),
      reason: _$values[r'reason'].decodeFormNullableString(
        context: r'LeaveRequest.reason',
      ),
    );
  }

  /// Salah satu `types[].id` dari GET /leaves
  final _i3.int attendanceStatusId;

  final _i1.Date startDate;

  /// Sama dengan atau setelah start_date
  final _i1.Date endDate;

  final _i3.String? reason;

  @_i3.override
  _i3.Object? toJson() => {
    r'attendance_status_id': this.attendanceStatusId,
    r'start_date': this.startDate.toJson(),
    r'end_date': this.endDate.toJson(),
    r'reason': this.reason,
  };

  LeaveRequest Function({
    _i3.int? attendanceStatusId,
    _i1.Date? startDate,
    _i1.Date? endDate,
    _i3.String? reason,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.int? attendanceStatusId,
      _i1.Date? startDate,
      _i1.Date? endDate,
      _i3.Object? reason = _sentinel,
    }) => LeaveRequest(
      attendanceStatusId: attendanceStatusId ?? this.attendanceStatusId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: _i3.identical(reason, _sentinel)
          ? this.reason
          : (reason as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LeaveRequest &&
        other.attendanceStatusId == this.attendanceStatusId &&
        other.startDate == this.startDate &&
        other.endDate == this.endDate &&
        other.reason == this.reason;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.attendanceStatusId,
      this.startDate,
      this.endDate,
      this.reason,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
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
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i4.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode LeaveRequest: complex types cannot be URI-encoded',
    );
  }
}
