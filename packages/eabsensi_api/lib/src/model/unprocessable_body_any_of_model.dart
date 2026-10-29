// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:eabsensi_api/src/model/validation_error.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class UnprocessableBodyAnyOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const UnprocessableBodyAnyOfModel({this.validationError, this.message});

  factory UnprocessableBodyAnyOfModel.fromJson(_i3.Object? json) {
    _i4.Message? _$decodedmessage;

    try {
      _$decodedmessage = _i4.Message.fromJson(json);
    } on _i3.Object catch (_) {
      _$decodedmessage = null;
    }

    _i5.ValidationError? _$decodedvalidationError;

    try {
      _$decodedvalidationError = _i5.ValidationError.fromJson(json);
    } on _i3.Object catch (_) {
      _$decodedvalidationError = null;
    }

    if (_$decodedmessage == null && _$decodedvalidationError == null) {
      throw _i1.JsonDecodingException(
        r'Invalid JSON for UnprocessableBodyAnyOfModel: all variants failed to decode',
      );
    }
    return UnprocessableBodyAnyOfModel(
      message: _$decodedmessage,
      validationError: _$decodedvalidationError,
    );
  }

  factory UnprocessableBodyAnyOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    _i4.Message? _$decodedmessage;

    try {
      _$decodedmessage = _i4.Message.fromSimple(
        value,
        explode: explode,
        isHeader: isHeader,
      );
    } on _i3.Object catch (_) {
      _$decodedmessage = null;
    }

    _i5.ValidationError? _$decodedvalidationError;

    try {
      _$decodedvalidationError = _i5.ValidationError.fromSimple(
        value,
        explode: explode,
        isHeader: isHeader,
      );
    } on _i3.Object catch (_) {
      _$decodedvalidationError = null;
    }

    if (_$decodedmessage == null && _$decodedvalidationError == null) {
      throw _i1.SimpleDecodingException(
        r'Invalid simple value for UnprocessableBodyAnyOfModel: all variants failed to decode',
      );
    }
    return UnprocessableBodyAnyOfModel(
      message: _$decodedmessage,
      validationError: _$decodedvalidationError,
    );
  }

  factory UnprocessableBodyAnyOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    _i4.Message? _$decodedmessage;

    try {
      _$decodedmessage = _i4.Message.fromForm(value, explode: explode);
    } on _i3.Object catch (_) {
      _$decodedmessage = null;
    }

    _i5.ValidationError? _$decodedvalidationError;

    try {
      _$decodedvalidationError = _i5.ValidationError.fromForm(
        value,
        explode: explode,
      );
    } on _i3.Object catch (_) {
      _$decodedvalidationError = null;
    }

    if (_$decodedmessage == null && _$decodedvalidationError == null) {
      throw _i1.FormDecodingException(
        r'Invalid form value for UnprocessableBodyAnyOfModel: all variants failed to decode',
      );
    }
    return UnprocessableBodyAnyOfModel(
      message: _$decodedmessage,
      validationError: _$decodedvalidationError,
    );
  }

  final _i5.ValidationError? validationError;

  final _i4.Message? message;

  _i1.EncodingShape get currentEncodingShape {
    final _$shapes = <_i1.EncodingShape>{};
    if (this.message != null) {
      _$shapes.add(this.message!.currentEncodingShape);
    }
    if (this.validationError != null) {
      _$shapes.add(this.validationError!.currentEncodingShape);
    }
    if (_$shapes.isEmpty) {
      throw _i3.StateError('At least one field must be non-null in anyOf');
    }
    if (_$shapes.length > 1) return _i1.EncodingShape.mixed;
    return _$shapes.first;
  }

  @_i3.override
  _i3.Object? toJson() {
    final _$values = <_i3.Object?>{};
    final _$mapValues = <_i3.Map<_i3.String, _i3.Object?>>[];
    if (this.message != null) {
      final _i3.Object? _$messageJson = this.message!.toJson();
      if (_$messageJson is _i3.Map<_i3.String, _i3.Object?>) {
        _$mapValues.add(_$messageJson);
      } else {
        _$values.add(_$messageJson);
      }
    }
    if (this.validationError != null) {
      final _i3.Object? _$validationErrorJson = this.validationError!.toJson();
      if (_$validationErrorJson is _i3.Map<_i3.String, _i3.Object?>) {
        _$mapValues.add(_$validationErrorJson);
      } else {
        _$values.add(_$validationErrorJson);
      }
    }
    if (_$values.isEmpty && _$mapValues.isEmpty) return null;
    if (_$values.isNotEmpty && _$mapValues.isNotEmpty) {
      throw _i1.EncodingException(
        r'Mixed encoding not supported for UnprocessableBodyAnyOfModel: cannot encode both simple and complex values',
      );
    }
    if (_$values.isNotEmpty) {
      return _$values.first;
    }
    if (_$mapValues.isNotEmpty) {
      final _$map = <_i3.String, _i3.Object?>{};
      for (final _$m in _$mapValues) {
        _i1.mergeJsonObject(_$map, _$m);
      }
      return _$map;
    }
    return null;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.message != null) {
      _$mapValues.add(
        this.message!.parameterProperties(allowEmpty: allowEmpty),
      );
    }
    if (this.validationError != null) {
      _$mapValues.add(
        this.validationError!.parameterProperties(allowEmpty: allowEmpty),
      );
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map;
  }

  @_i3.override
  _i3.String toSimple({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool literal = false,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.message != null) {
      final _$messageSimple = this.message!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$messageSimple);
    }
    if (this.validationError != null) {
      final _$validationErrorSimple = this.validationError!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$validationErrorSimple);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toSimple(
      explode: explode,
      allowEmpty: allowEmpty,
      literal: literal,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toForm(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
    _i3.Map<_i3.String, _i1.FormFieldEncoding> fieldEncodings = const {},
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.message != null) {
      final _$messageForm = this.message!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$messageForm);
    }
    if (this.validationError != null) {
      final _$validationErrorForm = this.validationError!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$validationErrorForm);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toForm(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      useQueryComponent: useQueryComponent,
      allowReserved: allowReserved,
      fieldEncodings: fieldEncodings,
      textEncoding: textEncoding,
    );
  }

  @_i3.override
  _i3.String toLabel({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.message != null) {
      final _$messageLabel = this.message!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$messageLabel);
    }
    if (this.validationError != null) {
      final _$validationErrorLabel = this.validationError!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$validationErrorLabel);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toLabel(explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.String toMatrix(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.message != null) {
      final _$messageMatrix = this.message!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$messageMatrix);
    }
    if (this.validationError != null) {
      final _$validationErrorMatrix = this.validationError!.parameterProperties(
        allowEmpty: allowEmpty,
      );
      _$mapValues.add(_$validationErrorMatrix);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toMatrix(paramName, explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toDeepObject(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toDeepObject(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toPipeDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toPipeDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toSpaceDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toSpaceDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    if (this.message != null) {
      throw _i1.EncodingException(
        r'Cannot uriEncode UnprocessableBodyAnyOfModel: contains complex type',
      );
    }
    if (this.validationError != null) {
      throw _i1.EncodingException(
        r'Cannot uriEncode UnprocessableBodyAnyOfModel: contains complex type',
      );
    }
    throw _i1.EncodingException(
      r'Cannot uriEncode UnprocessableBodyAnyOfModel: no value set',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is UnprocessableBodyAnyOfModel &&
        other.validationError == this.validationError &&
        other.message == this.message;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.validationError, this.message]);
  }

  UnprocessableBodyAnyOfModel Function({
    _i5.ValidationError? validationError,
    _i4.Message? message,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? validationError = _sentinel,
      _i3.Object? message = _sentinel,
    }) => UnprocessableBodyAnyOfModel(
      validationError: _i3.identical(validationError, _sentinel)
          ? this.validationError
          : (validationError as _i5.ValidationError?),
      message: _i3.identical(message, _sentinel)
          ? this.message
          : (message as _i4.Message?),
    );
  }
}
