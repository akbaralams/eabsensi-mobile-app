// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/me.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class LoginV2Response extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const LoginV2Response({
    required this.token,
    required this.tokenExpiresAt,
    required this.refreshToken,
    required this.refreshExpiresAt,
    required this.user,
  });

  factory LoginV2Response.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for LoginV2Response: contains complex types',
    );
  }

  factory LoginV2Response.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'LoginV2Response');
    return LoginV2Response(
      token: _$map[r'token'].decodeJsonString(
        context: r'LoginV2Response.token',
      ),
      tokenExpiresAt: _$map[r'token_expires_at'].decodeJsonDateTime(
        context: r'LoginV2Response.token_expires_at',
      ),
      refreshToken: _$map[r'refresh_token'].decodeJsonString(
        context: r'LoginV2Response.refresh_token',
      ),
      refreshExpiresAt: _$map[r'refresh_expires_at'].decodeJsonDateTime(
        context: r'LoginV2Response.refresh_expires_at',
      ),
      user: _i4.Me.fromJson(_$map[r'user']),
    );
  }

  factory LoginV2Response.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for LoginV2Response: contains complex types',
    );
  }

  final _i3.String token;

  final _i3.DateTime tokenExpiresAt;

  final _i3.String refreshToken;

  final _i3.DateTime refreshExpiresAt;

  final _i4.Me user;

  @_i3.override
  _i3.Object? toJson() => {
    r'token': this.token,
    r'token_expires_at': this.tokenExpiresAt.toTimeZonedIso8601String(),
    r'refresh_token': this.refreshToken,
    r'refresh_expires_at': this.refreshExpiresAt.toTimeZonedIso8601String(),
    r'user': this.user.toJson(),
  };

  LoginV2Response Function({
    _i3.String? token,
    _i3.DateTime? tokenExpiresAt,
    _i3.String? refreshToken,
    _i3.DateTime? refreshExpiresAt,
    _i4.Me? user,
  })
  get copyWith {
    return ({
      _i3.String? token,
      _i3.DateTime? tokenExpiresAt,
      _i3.String? refreshToken,
      _i3.DateTime? refreshExpiresAt,
      _i4.Me? user,
    }) => LoginV2Response(
      token: token ?? this.token,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshExpiresAt: refreshExpiresAt ?? this.refreshExpiresAt,
      user: user ?? this.user,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginV2Response &&
        other.token == this.token &&
        other.tokenExpiresAt == this.tokenExpiresAt &&
        other.refreshToken == this.refreshToken &&
        other.refreshExpiresAt == this.refreshExpiresAt &&
        other.user == this.user;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.token,
      this.tokenExpiresAt,
      this.refreshToken,
      this.refreshExpiresAt,
      this.user,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for LoginV2Response: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode LoginV2Response: complex types cannot be URI-encoded',
    );
  }
}
