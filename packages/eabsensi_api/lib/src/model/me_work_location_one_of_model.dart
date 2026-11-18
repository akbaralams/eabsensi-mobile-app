// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/work_location.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// Lokasi yang berlaku untuk punch; `null` bila absen tidak dibatasi radius.
@_i2.immutable
sealed class $RawMeWorkLocationOneOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawMeWorkLocationOneOfModel();

  factory $RawMeWorkLocationOneOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    try {
      return $RawMeWorkLocationOneOfModelWorkLocation(
        _i4.WorkLocation.fromSimple(
          value,
          explode: explode,
          isHeader: isHeader,
        ),
      );
    } on _i1.DecodingException catch (_) {
    } on _i3.FormatException catch (_) {}
    throw _i1.SimpleDecodingException(
      r'Invalid simple value for $RawMeWorkLocationOneOfModel',
    );
  }

  factory $RawMeWorkLocationOneOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    try {
      return $RawMeWorkLocationOneOfModelWorkLocation(
        _i4.WorkLocation.fromForm(value, explode: explode),
      );
    } on _i1.DecodingException catch (_) {
    } on _i3.FormatException catch (_) {}
    throw _i1.SimpleDecodingException(
      r'Invalid form value for $RawMeWorkLocationOneOfModel',
    );
  }

  factory $RawMeWorkLocationOneOfModel.fromJson(_i3.Object? json) {
    try {
      return $RawMeWorkLocationOneOfModelWorkLocation(
        _i4.WorkLocation.fromJson(json),
      );
    } on _i3.Object catch (_) {}
    throw _i1.JsonDecodingException(
      r'Invalid JSON for $RawMeWorkLocationOneOfModel',
    );
  }

  _i1.EncodingShape get currentEncodingShape {
    return switch (this) {
      $RawMeWorkLocationOneOfModelWorkLocation(:final value) =>
        value.currentEncodingShape,
    };
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    return switch (this) {
      $RawMeWorkLocationOneOfModelWorkLocation(:final value) =>
        value.parameterProperties(allowEmpty: allowEmpty),
    };
  }

  @_i3.override
  _i3.String toSimple({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool literal = false,
  }) {
    return switch (this) {
      $RawMeWorkLocationOneOfModelWorkLocation(:final value) => value.toSimple(
        explode: explode,
        allowEmpty: allowEmpty,
        literal: literal,
      ),
    };
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toForm(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
    _i3.Map<_i3.String, _i1.FormFieldEncoding> fieldEncodings = const {},
  }) {
    return switch (this) {
      $RawMeWorkLocationOneOfModelWorkLocation(:final value) => value.toForm(
        paramName,
        explode: explode,
        allowEmpty: allowEmpty,
        useQueryComponent: useQueryComponent,
        allowReserved: allowReserved,
        fieldEncodings: fieldEncodings,
        textEncoding: textEncoding,
      ),
    };
  }

  @_i3.override
  _i3.String toLabel({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    return switch (this) {
      $RawMeWorkLocationOneOfModelWorkLocation(:final value) => value.toLabel(
        explode: explode,
        allowEmpty: allowEmpty,
      ),
    };
  }

  @_i3.override
  _i3.String toMatrix(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    return switch (this) {
      $RawMeWorkLocationOneOfModelWorkLocation(:final value) => value.toMatrix(
        paramName,
        explode: explode,
        allowEmpty: allowEmpty,
      ),
    };
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
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    return switch (this) {
      $RawMeWorkLocationOneOfModelWorkLocation() => throw _i1.EncodingException(
        r'Cannot uriEncode $RawMeWorkLocationOneOfModel: variant contains complex type',
      ),
    };
  }

  @_i3.override
  _i3.Object? toJson() {
    final (_i3.dynamic _$json, _i3.String? _$discriminator) = switch (this) {
      $RawMeWorkLocationOneOfModelWorkLocation(:final value) => (
        value.toJson(),
        null,
      ),
    };
    return _$json;
  }
}

@_i2.immutable
class $RawMeWorkLocationOneOfModelWorkLocation
    extends $RawMeWorkLocationOneOfModel {
  const $RawMeWorkLocationOneOfModelWorkLocation(this.value);

  final _i4.WorkLocation value;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawMeWorkLocationOneOfModelWorkLocation &&
        other.value == this.value;
  }

  @_i3.override
  _i3.int get hashCode => this.value.hashCode;
}

typedef MeWorkLocationOneOfModel = $RawMeWorkLocationOneOfModel?;
