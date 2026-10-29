// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/punch_source_model.dart' as _i4;
import 'package:eabsensi_api/src/model/punch_status_model.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Punch extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Punch({
    required this.id,
    required this.punchedAt,
    required this.source,
    required this.status,
    required this.statusLabel,
    required this.hasPhoto,
  });

  factory Punch.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'punched_at',
        r'source',
        r'status',
        r'status_label',
        r'has_photo',
      },
      listKeys: {},
      context: r'Punch',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Punch(
      id: _$values[r'id'].decodeSimpleInt(context: r'Punch.id'),
      punchedAt: _$values[r'punched_at'].decodeSimpleDateTime(
        context: r'Punch.punched_at',
      ),
      source: _i4.PunchSourceModel.fromSimple(
        _$values[r'source'],
        explode: explode,
      ),
      status: _i5.PunchStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
      statusLabel: _$values[r'status_label'].decodeSimpleString(
        context: r'Punch.status_label',
      ),
      hasPhoto: _$values[r'has_photo'].decodeSimpleBool(
        context: r'Punch.has_photo',
      ),
    );
  }

  factory Punch.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Punch');
    return Punch(
      id: _$map[r'id'].decodeJsonInt(context: r'Punch.id'),
      punchedAt: _$map[r'punched_at'].decodeJsonDateTime(
        context: r'Punch.punched_at',
      ),
      source: _i4.PunchSourceModel.fromJson(_$map[r'source']),
      status: _i5.PunchStatusModel.fromJson(_$map[r'status']),
      statusLabel: _$map[r'status_label'].decodeJsonString(
        context: r'Punch.status_label',
      ),
      hasPhoto: _$map[r'has_photo'].decodeJsonBool(context: r'Punch.has_photo'),
    );
  }

  factory Punch.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'punched_at',
        r'source',
        r'status',
        r'status_label',
        r'has_photo',
      },
      listKeys: {},
      context: r'Punch',
    );
    return Punch(
      id: _$values[r'id'].decodeFormInt(context: r'Punch.id'),
      punchedAt: _$values[r'punched_at'].decodeFormDateTime(
        context: r'Punch.punched_at',
      ),
      source: _i4.PunchSourceModel.fromForm(
        _$values[r'source'],
        explode: explode,
      ),
      status: _i5.PunchStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
      statusLabel: _$values[r'status_label'].decodeFormString(
        context: r'Punch.status_label',
      ),
      hasPhoto: _$values[r'has_photo'].decodeFormBool(
        context: r'Punch.has_photo',
      ),
    );
  }

  final _i3.int id;

  /// **Example**:
  /// ```
  /// 2026-10-25T07:58:12+07:00
  /// ```
  final _i3.DateTime punchedAt;

  /// `device` = dari mesin absensi (ADMS), langsung approved tanpa foto
  final _i4.PunchSourceModel source;

  final _i5.PunchStatusModel status;

  /// **Example**:
  /// ```
  /// Menunggu persetujuan
  /// ```
  final _i3.String statusLabel;

  final _i3.bool hasPhoto;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'punched_at': this.punchedAt.toTimeZonedIso8601String(),
    r'source': this.source.toJson(),
    r'status': this.status.toJson(),
    r'status_label': this.statusLabel,
    r'has_photo': this.hasPhoto,
  };

  Punch Function({
    _i3.int? id,
    _i3.DateTime? punchedAt,
    _i4.PunchSourceModel? source,
    _i5.PunchStatusModel? status,
    _i3.String? statusLabel,
    _i3.bool? hasPhoto,
  })
  get copyWith {
    return ({
      _i3.int? id,
      _i3.DateTime? punchedAt,
      _i4.PunchSourceModel? source,
      _i5.PunchStatusModel? status,
      _i3.String? statusLabel,
      _i3.bool? hasPhoto,
    }) => Punch(
      id: id ?? this.id,
      punchedAt: punchedAt ?? this.punchedAt,
      source: source ?? this.source,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      hasPhoto: hasPhoto ?? this.hasPhoto,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Punch &&
        other.id == this.id &&
        other.punchedAt == this.punchedAt &&
        other.source == this.source &&
        other.status == this.status &&
        other.statusLabel == this.statusLabel &&
        other.hasPhoto == this.hasPhoto;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.punchedAt,
      this.source,
      this.status,
      this.statusLabel,
      this.hasPhoto,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id.toString());
    _$result[r'punched_at'] = _i1.PropertyValue.scalar(
      this.punchedAt.toTimeZonedIso8601String(),
    );
    _$result[r'source'] = _i1.PropertyValue.scalar(this.source.toJson());
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status.toJson());
    _$result[r'status_label'] = _i1.PropertyValue.scalar(this.statusLabel);
    _$result[r'has_photo'] = _i1.PropertyValue.scalar(this.hasPhoto.toString());
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
      r'Cannot uriEncode Punch: complex types cannot be URI-encoded',
    );
  }
}
