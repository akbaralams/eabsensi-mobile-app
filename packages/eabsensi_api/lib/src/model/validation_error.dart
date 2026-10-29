// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ValidationError extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ValidationError({required this.message, required this.errors});

  factory ValidationError.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for ValidationError: contains complex types',
    );
  }

  factory ValidationError.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ValidationError');
    return ValidationError(
      message: _$map[r'message'].decodeJsonString(
        context: r'ValidationError.message',
      ),
      errors: _$map[r'errors'].decodeJsonMap(
        (v) => v.decodeJsonList<_i3.String>(context: r'ValidationError.errors'),
        context: r'ValidationError.errors',
      ),
    );
  }

  factory ValidationError.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for ValidationError: contains complex types',
    );
  }

  final _i3.String message;

  /// Nama field ke daftar pesan. Nama field dijamin; teks pesan informatif.
  final _i3.Map<_i3.String, _i3.List<_i3.String>> errors;

  @_i3.override
  _i3.Object? toJson() => {r'message': this.message, r'errors': this.errors};

  ValidationError Function({
    _i3.String? message,
    _i3.Map<_i3.String, _i3.List<_i3.String>>? errors,
  })
  get copyWith {
    return ({
      _i3.String? message,
      _i3.Map<_i3.String, _i3.List<_i3.String>>? errors,
    }) => ValidationError(
      message: message ?? this.message,
      errors: errors ?? this.errors,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i4.DeepCollectionEquality();
    return other is ValidationError &&
        other.message == this.message &&
        _$deepEquals.equals(other.errors, this.errors);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i4.DeepCollectionEquality();
    return _i3.Object.hashAll([this.message, deepEquals.hash(this.errors)]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for ValidationError: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ValidationError: complex types cannot be URI-encoded',
    );
  }
}
