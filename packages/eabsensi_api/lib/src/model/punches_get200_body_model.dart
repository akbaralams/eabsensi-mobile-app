// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:eabsensi_api/src/model/punch.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PunchesGet200BodyModel extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PunchesGet200BodyModel({required this.data});

  factory PunchesGet200BodyModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PunchesGet200BodyModel: contains complex types',
    );
  }

  factory PunchesGet200BodyModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PunchesGet200BodyModel');
    return PunchesGet200BodyModel(
      data: _$map[r'data']
          .decodeJsonList<_i3.Object?>(context: r'PunchesGet200BodyModel.data')
          .map(_i4.Punch.fromJson)
          .toList(),
    );
  }

  factory PunchesGet200BodyModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PunchesGet200BodyModel: contains complex types',
    );
  }

  final _i3.List<_i4.Punch> data;

  @_i3.override
  _i3.Object? toJson() => {r'data': this.data.map((e) => e.toJson()).toList()};

  PunchesGet200BodyModel Function({_i3.List<_i4.Punch>? data}) get copyWith {
    return ({_i3.List<_i4.Punch>? data}) =>
        PunchesGet200BodyModel(data: data ?? this.data);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is PunchesGet200BodyModel &&
        _$deepEquals.equals(other.data, this.data);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return deepEquals.hash(this.data);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PunchesGet200BodyModel: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode PunchesGet200BodyModel: complex types cannot be URI-encoded',
    );
  }
}
