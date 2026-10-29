// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class TokenPair extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const TokenPair({
    required this.token,
    required this.tokenExpiresAt,
    required this.refreshToken,
    required this.refreshExpiresAt,
  });

  factory TokenPair.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'token',
        r'token_expires_at',
        r'refresh_token',
        r'refresh_expires_at',
      },
      listKeys: {},
      context: r'TokenPair',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return TokenPair(
      token: _$values[r'token'].decodeSimpleString(context: r'TokenPair.token'),
      tokenExpiresAt: _$values[r'token_expires_at'].decodeSimpleDateTime(
        context: r'TokenPair.token_expires_at',
      ),
      refreshToken: _$values[r'refresh_token'].decodeSimpleString(
        context: r'TokenPair.refresh_token',
      ),
      refreshExpiresAt: _$values[r'refresh_expires_at'].decodeSimpleDateTime(
        context: r'TokenPair.refresh_expires_at',
      ),
    );
  }

  factory TokenPair.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TokenPair');
    return TokenPair(
      token: _$map[r'token'].decodeJsonString(context: r'TokenPair.token'),
      tokenExpiresAt: _$map[r'token_expires_at'].decodeJsonDateTime(
        context: r'TokenPair.token_expires_at',
      ),
      refreshToken: _$map[r'refresh_token'].decodeJsonString(
        context: r'TokenPair.refresh_token',
      ),
      refreshExpiresAt: _$map[r'refresh_expires_at'].decodeJsonDateTime(
        context: r'TokenPair.refresh_expires_at',
      ),
    );
  }

  factory TokenPair.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'token',
        r'token_expires_at',
        r'refresh_token',
        r'refresh_expires_at',
      },
      listKeys: {},
      context: r'TokenPair',
    );
    return TokenPair(
      token: _$values[r'token'].decodeFormString(context: r'TokenPair.token'),
      tokenExpiresAt: _$values[r'token_expires_at'].decodeFormDateTime(
        context: r'TokenPair.token_expires_at',
      ),
      refreshToken: _$values[r'refresh_token'].decodeFormString(
        context: r'TokenPair.refresh_token',
      ),
      refreshExpiresAt: _$values[r'refresh_expires_at'].decodeFormDateTime(
        context: r'TokenPair.refresh_expires_at',
      ),
    );
  }

  /// Token akses untuk header Authorization Bearer
  final _i3.String token;

  final _i3.DateTime tokenExpiresAt;

  /// Simpan aman; hanya untuk POST /v2/auth/refresh
  final _i3.String refreshToken;

  final _i3.DateTime refreshExpiresAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'token': this.token,
    r'token_expires_at': this.tokenExpiresAt.toTimeZonedIso8601String(),
    r'refresh_token': this.refreshToken,
    r'refresh_expires_at': this.refreshExpiresAt.toTimeZonedIso8601String(),
  };

  TokenPair Function({
    _i3.String? token,
    _i3.DateTime? tokenExpiresAt,
    _i3.String? refreshToken,
    _i3.DateTime? refreshExpiresAt,
  })
  get copyWith {
    return ({
      _i3.String? token,
      _i3.DateTime? tokenExpiresAt,
      _i3.String? refreshToken,
      _i3.DateTime? refreshExpiresAt,
    }) => TokenPair(
      token: token ?? this.token,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshExpiresAt: refreshExpiresAt ?? this.refreshExpiresAt,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TokenPair &&
        other.token == this.token &&
        other.tokenExpiresAt == this.tokenExpiresAt &&
        other.refreshToken == this.refreshToken &&
        other.refreshExpiresAt == this.refreshExpiresAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.token,
      this.tokenExpiresAt,
      this.refreshToken,
      this.refreshExpiresAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'token'] = _i1.PropertyValue.scalar(this.token);
    _$result[r'token_expires_at'] = _i1.PropertyValue.scalar(
      this.tokenExpiresAt.toTimeZonedIso8601String(),
    );
    _$result[r'refresh_token'] = _i1.PropertyValue.scalar(this.refreshToken);
    _$result[r'refresh_expires_at'] = _i1.PropertyValue.scalar(
      this.refreshExpiresAt.toTimeZonedIso8601String(),
    );
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
      r'Cannot uriEncode TokenPair: complex types cannot be URI-encoded',
    );
  }
}
