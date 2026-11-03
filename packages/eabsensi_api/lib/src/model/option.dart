// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Option extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Option({required this.id, required this.code, required this.name});

  factory Option.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'code', r'name'},
      listKeys: {},
      context: r'Option',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Option(
      id: _$values[r'id'].decodeSimpleInt(context: r'Option.id'),
      code: _$values[r'code'].decodeSimpleString(context: r'Option.code'),
      name: _$values[r'name'].decodeSimpleString(context: r'Option.name'),
    );
  }

  factory Option.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Option');
    return Option(
      id: _$map[r'id'].decodeJsonInt(context: r'Option.id'),
      code: _$map[r'code'].decodeJsonString(context: r'Option.code'),
      name: _$map[r'name'].decodeJsonString(context: r'Option.name'),
    );
  }

  factory Option.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'code', r'name'},
      listKeys: {},
      context: r'Option',
    );
    return Option(
      id: _$values[r'id'].decodeFormInt(context: r'Option.id'),
      code: _$values[r'code'].decodeFormString(context: r'Option.code'),
      name: _$values[r'name'].decodeFormString(context: r'Option.name'),
    );
  }

  final _i3.int id;

  final _i3.String code;

  final _i3.String name;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'code': this.code,
    r'name': this.name,
  };

  Option Function({_i3.int? id, _i3.String? code, _i3.String? name})
  get copyWith {
    return ({_i3.int? id, _i3.String? code, _i3.String? name}) => Option(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Option &&
        other.id == this.id &&
        other.code == this.code &&
        other.name == this.name;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.code, this.name]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id.toString());
    _$result[r'code'] = _i1.PropertyValue.scalar(this.code);
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
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
      r'Cannot uriEncode Option: complex types cannot be URI-encoded',
    );
  }
}
