// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:eabsensi_api/src/model/location_flags.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class EventCheckIn extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const EventCheckIn({
    required this.eventId,
    required this.checkedInAt,
    this.locationFlags,
  });

  factory EventCheckIn.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'event_id', r'checked_in_at', r'location_flags'},
      listKeys: {r'location_flags'},
      context: r'EventCheckIn',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return EventCheckIn(
      eventId: _$values[r'event_id'].decodeSimpleInt(
        context: r'EventCheckIn.event_id',
      ),
      checkedInAt: _$values[r'checked_in_at'].decodeSimpleDateTime(
        context: r'EventCheckIn.checked_in_at',
      ),
      locationFlags: _$values[r'location_flags'].decodeSimpleNullableStringList(
        context: r'EventCheckIn.location_flags',
        isHeader: isHeader,
      ),
    );
  }

  factory EventCheckIn.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'EventCheckIn');
    return EventCheckIn(
      eventId: _$map[r'event_id'].decodeJsonInt(
        context: r'EventCheckIn.event_id',
      ),
      checkedInAt: _$map[r'checked_in_at'].decodeJsonDateTime(
        context: r'EventCheckIn.checked_in_at',
      ),
      locationFlags: _$map[r'location_flags']
          .decodeJsonNullableList<_i3.String>(
            context: r'EventCheckIn.location_flags',
          ),
    );
  }

  factory EventCheckIn.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'event_id', r'checked_in_at', r'location_flags'},
      listKeys: {r'location_flags'},
      context: r'EventCheckIn',
    );
    return EventCheckIn(
      eventId: _$values[r'event_id'].decodeFormInt(
        context: r'EventCheckIn.event_id',
      ),
      checkedInAt: _$values[r'checked_in_at'].decodeFormDateTime(
        context: r'EventCheckIn.checked_in_at',
      ),
      locationFlags: _$values[r'location_flags'].decodeFormNullableStringList(
        context: r'EventCheckIn.location_flags',
      ),
    );
  }

  final _i3.int eventId;

  final _i3.DateTime checkedInAt;

  final _i4.LocationFlags? locationFlags;

  @_i3.override
  _i3.Object? toJson() => {
    r'event_id': this.eventId,
    r'checked_in_at': this.checkedInAt.toTimeZonedIso8601String(),
    if (this.locationFlags != null) r'location_flags': this.locationFlags,
  };

  EventCheckIn Function({
    _i3.int? eventId,
    _i3.DateTime? checkedInAt,
    _i4.LocationFlags? locationFlags,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.int? eventId,
      _i3.DateTime? checkedInAt,
      _i3.Object? locationFlags = _sentinel,
    }) => EventCheckIn(
      eventId: eventId ?? this.eventId,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      locationFlags: _i3.identical(locationFlags, _sentinel)
          ? this.locationFlags
          : (locationFlags as _i4.LocationFlags?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is EventCheckIn &&
        other.eventId == this.eventId &&
        other.checkedInAt == this.checkedInAt &&
        _$deepEquals.equals(other.locationFlags, this.locationFlags);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.eventId,
      this.checkedInAt,
      deepEquals.hash(this.locationFlags),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'event_id'] = _i1.PropertyValue.scalar(this.eventId.toString());
    _$result[r'checked_in_at'] = _i1.PropertyValue.scalar(
      this.checkedInAt.toTimeZonedIso8601String(),
    );
    if (this.locationFlags != null) {
      _$result[r'location_flags'] = _i1.PropertyValue.array(
        this.locationFlags!,
      );
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode EventCheckIn: complex types cannot be URI-encoded',
    );
  }
}
