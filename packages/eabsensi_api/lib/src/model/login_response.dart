// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/me.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class LoginResponse extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for LoginResponse: contains complex types',
    );
  }

  factory LoginResponse.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'LoginResponse');
    return LoginResponse(
      token: _$map[r'token'].decodeJsonString(context: r'LoginResponse.token'),
      user: _i4.Me.fromJson(_$map[r'user']),
    );
  }

  factory LoginResponse.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for LoginResponse: contains complex types',
    );
  }

  /// **Example**:
  /// ```
  /// 12|Q3m4x...
  /// ```
  final _i3.String token;

  final _i4.Me user;

  @_i3.override
  _i3.Object? toJson() => {r'token': this.token, r'user': this.user.toJson()};

  LoginResponse Function({_i3.String? token, _i4.Me? user}) get copyWith {
    return ({_i3.String? token, _i4.Me? user}) =>
        LoginResponse(token: token ?? this.token, user: user ?? this.user);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponse &&
        other.token == this.token &&
        other.user == this.user;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.token, this.user]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for LoginResponse: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode LoginResponse: complex types cannot be URI-encoded',
    );
  }
}
