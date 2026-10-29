// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:eabsensi_api/src/model/leave.dart' as _i4;
import 'package:eabsensi_api/src/model/option.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class LeavesGet200BodyModel extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const LeavesGet200BodyModel({required this.data, required this.types});

  factory LeavesGet200BodyModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for LeavesGet200BodyModel: contains complex types',
    );
  }

  factory LeavesGet200BodyModel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'LeavesGet200BodyModel');
    return LeavesGet200BodyModel(
      data: _$map[r'data']
          .decodeJsonList<_i3.Object?>(context: r'LeavesGet200BodyModel.data')
          .map(_i4.Leave.fromJson)
          .toList(),
      types: _$map[r'types']
          .decodeJsonList<_i3.Object?>(context: r'LeavesGet200BodyModel.types')
          .map(_i5.Option.fromJson)
          .toList(),
    );
  }

  factory LeavesGet200BodyModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for LeavesGet200BodyModel: contains complex types',
    );
  }

  final _i3.List<_i4.Leave> data;

  /// Status kehadiran aktif, urut nama.
  final _i3.List<_i5.Option> types;

  @_i3.override
  _i3.Object? toJson() => {
    r'data': this.data.map((e) => e.toJson()).toList(),
    r'types': this.types.map((e) => e.toJson()).toList(),
  };

  LeavesGet200BodyModel Function({
    _i3.List<_i4.Leave>? data,
    _i3.List<_i5.Option>? types,
  })
  get copyWith {
    return ({_i3.List<_i4.Leave>? data, _i3.List<_i5.Option>? types}) =>
        LeavesGet200BodyModel(
          data: data ?? this.data,
          types: types ?? this.types,
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is LeavesGet200BodyModel &&
        _$deepEquals.equals(other.data, this.data) &&
        _$deepEquals.equals(other.types, this.types);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return _i3.Object.hashAll([
      deepEquals.hash(this.data),
      deepEquals.hash(this.types),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for LeavesGet200BodyModel: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode LeavesGet200BodyModel: complex types cannot be URI-encoded',
    );
  }
}
