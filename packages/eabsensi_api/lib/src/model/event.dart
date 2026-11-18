// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/event_work_location_one_of_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Event extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Event({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.startsAt,
    required this.endsAt,
    required this.checkedIn,
    this.workLocation,
  });

  factory Event.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Event: contains complex types',
    );
  }

  factory Event.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Event');
    return Event(
      id: _$map[r'id'].decodeJsonInt(context: r'Event.id'),
      name: _$map[r'name'].decodeJsonString(context: r'Event.name'),
      eventDate: _$map[r'event_date'].decodeJsonDate(
        context: r'Event.event_date',
      ),
      startsAt: _$map[r'starts_at'].decodeJsonString(
        context: r'Event.starts_at',
      ),
      endsAt: _$map[r'ends_at'].decodeJsonString(context: r'Event.ends_at'),
      checkedIn: _$map[r'checked_in'].decodeJsonBool(
        context: r'Event.checked_in',
      ),
      workLocation: _$map[r'work_location'] == null
          ? null
          : _i4.EventWorkLocationOneOfModel.fromJson(_$map[r'work_location']),
    );
  }

  factory Event.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Event: contains complex types',
    );
  }

  final _i3.int id;

  final _i3.String name;

  final _i1.Date eventDate;

  /// **Example**:
  /// ```
  /// 07:00
  /// ```
  final _i3.String startsAt;

  /// **Example**:
  /// ```
  /// 09:00
  /// ```
  final _i3.String endsAt;

  final _i3.bool checkedIn;

  /// Lokasi yang berlaku untuk check-in; `null` bila tidak dibatasi radius.
  final _i4.EventWorkLocationOneOfModel? workLocation;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'name': this.name,
    r'event_date': this.eventDate.toJson(),
    r'starts_at': this.startsAt,
    r'ends_at': this.endsAt,
    r'checked_in': this.checkedIn,
    if (this.workLocation != null)
      r'work_location': this.workLocation?.toJson(),
  };

  Event Function({
    _i3.int? id,
    _i3.String? name,
    _i1.Date? eventDate,
    _i3.String? startsAt,
    _i3.String? endsAt,
    _i3.bool? checkedIn,
    _i4.EventWorkLocationOneOfModel? workLocation,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.int? id,
      _i3.String? name,
      _i1.Date? eventDate,
      _i3.String? startsAt,
      _i3.String? endsAt,
      _i3.bool? checkedIn,
      _i3.Object? workLocation = _sentinel,
    }) => Event(
      id: id ?? this.id,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      checkedIn: checkedIn ?? this.checkedIn,
      workLocation: _i3.identical(workLocation, _sentinel)
          ? this.workLocation
          : (workLocation as _i4.EventWorkLocationOneOfModel?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Event &&
        other.id == this.id &&
        other.name == this.name &&
        other.eventDate == this.eventDate &&
        other.startsAt == this.startsAt &&
        other.endsAt == this.endsAt &&
        other.checkedIn == this.checkedIn &&
        other.workLocation == this.workLocation;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.name,
      this.eventDate,
      this.startsAt,
      this.endsAt,
      this.checkedIn,
      this.workLocation,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id.toString());
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    _$result[r'event_date'] = _i1.PropertyValue.scalar(
      this.eventDate.toString(),
    );
    _$result[r'starts_at'] = _i1.PropertyValue.scalar(this.startsAt);
    _$result[r'ends_at'] = _i1.PropertyValue.scalar(this.endsAt);
    _$result[r'checked_in'] = _i1.PropertyValue.scalar(
      this.checkedIn.toString(),
    );
    if (this.workLocation != null) {
      _$result[r'work_location'] = _i1.encodeAnyValueToPropertyValue(
        this.workLocation!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
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
      r'Cannot uriEncode Event: complex types cannot be URI-encoded',
    );
  }
}
