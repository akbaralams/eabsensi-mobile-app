// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class LoginRequest extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const LoginRequest({
    required this.login,
    required this.password,
    required this.deviceName,
  });

  factory LoginRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'login', r'password', r'device_name'},
      listKeys: {},
      context: r'LoginRequest',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return LoginRequest(
      login: _$values[r'login'].decodeSimpleString(
        context: r'LoginRequest.login',
      ),
      password: _$values[r'password'].decodeSimpleString(
        context: r'LoginRequest.password',
      ),
      deviceName: _$values[r'device_name'].decodeSimpleString(
        context: r'LoginRequest.device_name',
      ),
    );
  }

  factory LoginRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'LoginRequest');
    return LoginRequest(
      login: _$map[r'login'].decodeJsonString(context: r'LoginRequest.login'),
      password: _$map[r'password'].decodeJsonString(
        context: r'LoginRequest.password',
      ),
      deviceName: _$map[r'device_name'].decodeJsonString(
        context: r'LoginRequest.device_name',
      ),
    );
  }

  factory LoginRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'login', r'password', r'device_name'},
      listKeys: {},
      context: r'LoginRequest',
    );
    return LoginRequest(
      login: _$values[r'login'].decodeFormString(
        context: r'LoginRequest.login',
      ),
      password: _$values[r'password'].decodeFormString(
        context: r'LoginRequest.password',
      ),
      deviceName: _$values[r'device_name'].decodeFormString(
        context: r'LoginRequest.device_name',
      ),
    );
  }

  /// Username atau email
  final _i3.String login;

  final _i3.String password;

  /// Nama perangkat; satu token per nama
  final _i3.String deviceName;

  @_i3.override
  _i3.Object? toJson() => {
    r'login': this.login,
    r'password': this.password,
    r'device_name': this.deviceName,
  };

  LoginRequest Function({
    _i3.String? login,
    _i3.String? password,
    _i3.String? deviceName,
  })
  get copyWith {
    return ({
      _i3.String? login,
      _i3.String? password,
      _i3.String? deviceName,
    }) => LoginRequest(
      login: login ?? this.login,
      password: password ?? this.password,
      deviceName: deviceName ?? this.deviceName,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginRequest &&
        other.login == this.login &&
        other.password == this.password &&
        other.deviceName == this.deviceName;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.login, this.password, this.deviceName]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'login'] = _i1.PropertyValue.scalar(this.login);
    _$result[r'password'] = _i1.PropertyValue.scalar(this.password);
    _$result[r'device_name'] = _i1.PropertyValue.scalar(this.deviceName);
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
      r'Cannot uriEncode LoginRequest: complex types cannot be URI-encoded',
    );
  }
}
