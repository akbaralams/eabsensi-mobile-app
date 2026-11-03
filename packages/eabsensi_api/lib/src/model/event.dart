// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

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
  });

  factory Event.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'name',
        r'event_date',
        r'starts_at',
        r'ends_at',
        r'checked_in',
      },
      listKeys: {},
      context: r'Event',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Event(
      id: _$values[r'id'].decodeSimpleInt(context: r'Event.id'),
      name: _$values[r'name'].decodeSimpleString(context: r'Event.name'),
      eventDate: _$values[r'event_date'].decodeSimpleDate(
        context: r'Event.event_date',
      ),
      startsAt: _$values[r'starts_at'].decodeSimpleString(
        context: r'Event.starts_at',
      ),
      endsAt: _$values[r'ends_at'].decodeSimpleString(
        context: r'Event.ends_at',
      ),
      checkedIn: _$values[r'checked_in'].decodeSimpleBool(
        context: r'Event.checked_in',
      ),
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
    );
  }

  factory Event.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'name',
        r'event_date',
        r'starts_at',
        r'ends_at',
        r'checked_in',
      },
      listKeys: {},
      context: r'Event',
    );
    return Event(
      id: _$values[r'id'].decodeFormInt(context: r'Event.id'),
      name: _$values[r'name'].decodeFormString(context: r'Event.name'),
      eventDate: _$values[r'event_date'].decodeFormDate(
        context: r'Event.event_date',
      ),
      startsAt: _$values[r'starts_at'].decodeFormString(
        context: r'Event.starts_at',
      ),
      endsAt: _$values[r'ends_at'].decodeFormString(context: r'Event.ends_at'),
      checkedIn: _$values[r'checked_in'].decodeFormBool(
        context: r'Event.checked_in',
      ),
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

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'name': this.name,
    r'event_date': this.eventDate.toJson(),
    r'starts_at': this.startsAt,
    r'ends_at': this.endsAt,
    r'checked_in': this.checkedIn,
  };

  Event Function({
    _i3.int? id,
    _i3.String? name,
    _i1.Date? eventDate,
    _i3.String? startsAt,
    _i3.String? endsAt,
    _i3.bool? checkedIn,
  })
  get copyWith {
    return ({
      _i3.int? id,
      _i3.String? name,
      _i1.Date? eventDate,
      _i3.String? startsAt,
      _i3.String? endsAt,
      _i3.bool? checkedIn,
    }) => Event(
      id: id ?? this.id,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      checkedIn: checkedIn ?? this.checkedIn,
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
        other.checkedIn == this.checkedIn;
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
      r'Cannot uriEncode Event: complex types cannot be URI-encoded',
    );
  }
}
