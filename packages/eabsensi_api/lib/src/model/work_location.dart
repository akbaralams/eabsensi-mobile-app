// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class WorkLocation extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const WorkLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  factory WorkLocation.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'name', r'latitude', r'longitude', r'radius_meters'},
      listKeys: {},
      context: r'WorkLocation',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return WorkLocation(
      name: _$values[r'name'].decodeSimpleString(context: r'WorkLocation.name'),
      latitude: _$values[r'latitude'].decodeSimpleDouble(
        context: r'WorkLocation.latitude',
      ),
      longitude: _$values[r'longitude'].decodeSimpleDouble(
        context: r'WorkLocation.longitude',
      ),
      radiusMeters: _$values[r'radius_meters'].decodeSimpleInt(
        context: r'WorkLocation.radius_meters',
      ),
    );
  }

  factory WorkLocation.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'WorkLocation');
    return WorkLocation(
      name: _$map[r'name'].decodeJsonString(context: r'WorkLocation.name'),
      latitude: _$map[r'latitude'].decodeJsonNum(
        context: r'WorkLocation.latitude',
      ),
      longitude: _$map[r'longitude'].decodeJsonNum(
        context: r'WorkLocation.longitude',
      ),
      radiusMeters: _$map[r'radius_meters'].decodeJsonInt(
        context: r'WorkLocation.radius_meters',
      ),
    );
  }

  factory WorkLocation.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'name', r'latitude', r'longitude', r'radius_meters'},
      listKeys: {},
      context: r'WorkLocation',
    );
    return WorkLocation(
      name: _$values[r'name'].decodeFormString(context: r'WorkLocation.name'),
      latitude: _$values[r'latitude'].decodeFormDouble(
        context: r'WorkLocation.latitude',
      ),
      longitude: _$values[r'longitude'].decodeFormDouble(
        context: r'WorkLocation.longitude',
      ),
      radiusMeters: _$values[r'radius_meters'].decodeFormInt(
        context: r'WorkLocation.radius_meters',
      ),
    );
  }

  /// **Example**:
  /// ```
  /// Kantor Pusat
  /// ```
  final _i3.String name;

  final _i3.num latitude;

  final _i3.num longitude;

  final _i3.int radiusMeters;

  @_i3.override
  _i3.Object? toJson() => {
    r'name': this.name,
    r'latitude': this.latitude,
    r'longitude': this.longitude,
    r'radius_meters': this.radiusMeters,
  };

  WorkLocation Function({
    _i3.String? name,
    _i3.num? latitude,
    _i3.num? longitude,
    _i3.int? radiusMeters,
  })
  get copyWith {
    return ({
      _i3.String? name,
      _i3.num? latitude,
      _i3.num? longitude,
      _i3.int? radiusMeters,
    }) => WorkLocation(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is WorkLocation &&
        other.name == this.name &&
        other.latitude == this.latitude &&
        other.longitude == this.longitude &&
        other.radiusMeters == this.radiusMeters;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.name,
      this.latitude,
      this.longitude,
      this.radiusMeters,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    _$result[r'latitude'] = _i1.PropertyValue.scalar(this.latitude.toString());
    _$result[r'longitude'] = _i1.PropertyValue.scalar(
      this.longitude.toString(),
    );
    _$result[r'radius_meters'] = _i1.PropertyValue.scalar(
      this.radiusMeters.toString(),
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
      r'Cannot uriEncode WorkLocation: complex types cannot be URI-encoded',
    );
  }
}
