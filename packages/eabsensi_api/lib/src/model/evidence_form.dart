// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class EvidenceForm extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const EvidenceForm({
    this.photo,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.isMocked,
    this.locationAgeSeconds,
    this.deviceRooted,
  });

  factory EvidenceForm.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'photo',
        r'latitude',
        r'longitude',
        r'accuracy',
        r'is_mocked',
        r'location_age_seconds',
        r'device_rooted',
      },
      listKeys: {},
      context: r'EvidenceForm',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return EvidenceForm(
      photo: _$values[r'photo'] == null
          ? null
          : _i1.TonikFileBytes(
              _$values[r'photo'].decodeSimpleBinary(
                context: r'EvidenceForm.photo',
              ),
            ),
      latitude: _$values[r'latitude'].decodeSimpleNullableDouble(
        context: r'EvidenceForm.latitude',
      ),
      longitude: _$values[r'longitude'].decodeSimpleNullableDouble(
        context: r'EvidenceForm.longitude',
      ),
      accuracy: _$values[r'accuracy'].decodeSimpleNullableInt(
        context: r'EvidenceForm.accuracy',
      ),
      isMocked: _$values[r'is_mocked'].decodeSimpleNullableInt(
        context: r'EvidenceForm.is_mocked',
      ),
      locationAgeSeconds: _$values[r'location_age_seconds']
          .decodeSimpleNullableInt(
            context: r'EvidenceForm.location_age_seconds',
          ),
      deviceRooted: _$values[r'device_rooted'].decodeSimpleNullableInt(
        context: r'EvidenceForm.device_rooted',
      ),
    );
  }

  factory EvidenceForm.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'EvidenceForm');
    return EvidenceForm(
      photo: _$map[r'photo'] == null
          ? null
          : _i1.TonikFileBytes(
              _$map[r'photo'].decodeJsonBinary(context: r'EvidenceForm.photo'),
            ),
      latitude: _$map[r'latitude'].decodeJsonNullableNum(
        context: r'EvidenceForm.latitude',
      ),
      longitude: _$map[r'longitude'].decodeJsonNullableNum(
        context: r'EvidenceForm.longitude',
      ),
      accuracy: _$map[r'accuracy'].decodeJsonNullableInt(
        context: r'EvidenceForm.accuracy',
      ),
      isMocked: _$map[r'is_mocked'].decodeJsonNullableInt(
        context: r'EvidenceForm.is_mocked',
      ),
      locationAgeSeconds: _$map[r'location_age_seconds'].decodeJsonNullableInt(
        context: r'EvidenceForm.location_age_seconds',
      ),
      deviceRooted: _$map[r'device_rooted'].decodeJsonNullableInt(
        context: r'EvidenceForm.device_rooted',
      ),
    );
  }

  factory EvidenceForm.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'photo',
        r'latitude',
        r'longitude',
        r'accuracy',
        r'is_mocked',
        r'location_age_seconds',
        r'device_rooted',
      },
      listKeys: {},
      context: r'EvidenceForm',
    );
    return EvidenceForm(
      photo: _$values[r'photo'] == null
          ? null
          : _i1.TonikFileBytes(
              _$values[r'photo'].decodeFormBinary(
                context: r'EvidenceForm.photo',
              ),
            ),
      latitude: _$values[r'latitude'].decodeFormNullableDouble(
        context: r'EvidenceForm.latitude',
      ),
      longitude: _$values[r'longitude'].decodeFormNullableDouble(
        context: r'EvidenceForm.longitude',
      ),
      accuracy: _$values[r'accuracy'].decodeFormNullableInt(
        context: r'EvidenceForm.accuracy',
      ),
      isMocked: _$values[r'is_mocked'].decodeFormNullableInt(
        context: r'EvidenceForm.is_mocked',
      ),
      locationAgeSeconds: _$values[r'location_age_seconds']
          .decodeFormNullableInt(context: r'EvidenceForm.location_age_seconds'),
      deviceRooted: _$values[r'device_rooted'].decodeFormNullableInt(
        context: r'EvidenceForm.device_rooted',
      ),
    );
  }

  /// JPG/PNG maks 4 MB; wajib bila `requires_photo`.
  final _i1.TonikFile? photo;

  /// Wajib bersama longitude
  final _i3.num? latitude;

  /// Wajib bersama latitude
  final _i3.num? longitude;

  /// Akurasi lokasi dalam meter
  final _i3.int? accuracy;

  /// 1 bila sistem operasi melaporkan lokasi palsu
  final _i3.int? isMocked;

  /// Umur data GPS saat dikirim
  final _i3.int? locationAgeSeconds;

  /// 1 bila perangkat terdeteksi root
  final _i3.int? deviceRooted;

  @_i3.override
  _i3.Object? toJson() => {
    if (this.photo != null) r'photo': this.photo?.toBytes().decodeToString(),
    if (this.latitude != null) r'latitude': this.latitude,
    if (this.longitude != null) r'longitude': this.longitude,
    if (this.accuracy != null) r'accuracy': this.accuracy,
    if (this.isMocked != null) r'is_mocked': this.isMocked,
    if (this.locationAgeSeconds != null)
      r'location_age_seconds': this.locationAgeSeconds,
    if (this.deviceRooted != null) r'device_rooted': this.deviceRooted,
  };

  EvidenceForm Function({
    _i1.TonikFile? photo,
    _i3.num? latitude,
    _i3.num? longitude,
    _i3.int? accuracy,
    _i3.int? isMocked,
    _i3.int? locationAgeSeconds,
    _i3.int? deviceRooted,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? photo = _sentinel,
      _i3.Object? latitude = _sentinel,
      _i3.Object? longitude = _sentinel,
      _i3.Object? accuracy = _sentinel,
      _i3.Object? isMocked = _sentinel,
      _i3.Object? locationAgeSeconds = _sentinel,
      _i3.Object? deviceRooted = _sentinel,
    }) => EvidenceForm(
      photo: _i3.identical(photo, _sentinel)
          ? this.photo
          : (photo as _i1.TonikFile?),
      latitude: _i3.identical(latitude, _sentinel)
          ? this.latitude
          : (latitude as _i3.num?),
      longitude: _i3.identical(longitude, _sentinel)
          ? this.longitude
          : (longitude as _i3.num?),
      accuracy: _i3.identical(accuracy, _sentinel)
          ? this.accuracy
          : (accuracy as _i3.int?),
      isMocked: _i3.identical(isMocked, _sentinel)
          ? this.isMocked
          : (isMocked as _i3.int?),
      locationAgeSeconds: _i3.identical(locationAgeSeconds, _sentinel)
          ? this.locationAgeSeconds
          : (locationAgeSeconds as _i3.int?),
      deviceRooted: _i3.identical(deviceRooted, _sentinel)
          ? this.deviceRooted
          : (deviceRooted as _i3.int?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is EvidenceForm &&
        other.photo == this.photo &&
        other.latitude == this.latitude &&
        other.longitude == this.longitude &&
        other.accuracy == this.accuracy &&
        other.isMocked == this.isMocked &&
        other.locationAgeSeconds == this.locationAgeSeconds &&
        other.deviceRooted == this.deviceRooted;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.photo,
      this.latitude,
      this.longitude,
      this.accuracy,
      this.isMocked,
      this.locationAgeSeconds,
      this.deviceRooted,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (this.photo != null) {
      _$result[r'photo'] = _i1.PropertyValue.scalar(
        this.photo!.toBytes().decodeToString(),
      );
    }
    if (this.latitude != null) {
      _$result[r'latitude'] = _i1.PropertyValue.scalar(
        this.latitude!.toString(),
      );
    }
    if (this.longitude != null) {
      _$result[r'longitude'] = _i1.PropertyValue.scalar(
        this.longitude!.toString(),
      );
    }
    if (this.accuracy != null) {
      _$result[r'accuracy'] = _i1.PropertyValue.scalar(
        this.accuracy!.toString(),
      );
    }
    if (this.isMocked != null) {
      _$result[r'is_mocked'] = _i1.PropertyValue.scalar(
        this.isMocked!.toString(),
      );
    }
    if (this.locationAgeSeconds != null) {
      _$result[r'location_age_seconds'] = _i1.PropertyValue.scalar(
        this.locationAgeSeconds!.toString(),
      );
    }
    if (this.deviceRooted != null) {
      _$result[r'device_rooted'] = _i1.PropertyValue.scalar(
        this.deviceRooted!.toString(),
      );
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
      r'Cannot uriEncode EvidenceForm: complex types cannot be URI-encoded',
    );
  }
}
