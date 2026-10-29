// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:eabsensi_api/src/model/token_pair.dart' as _i2;
import 'package:eabsensi_api/src/model/unprocessable_body_any_of_model.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class RefreshTokenResponse {
  const RefreshTokenResponse();
}

@_i1.immutable
class RefreshTokenResponse200 extends RefreshTokenResponse {
  const RefreshTokenResponse200({required this.body});

  final _i2.TokenPair body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshTokenResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RefreshTokenResponse401 extends RefreshTokenResponse {
  const RefreshTokenResponse401({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshTokenResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RefreshTokenResponse403 extends RefreshTokenResponse {
  const RefreshTokenResponse403({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshTokenResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RefreshTokenResponse422 extends RefreshTokenResponse {
  const RefreshTokenResponse422({required this.body});

  final _i5.UnprocessableBodyAnyOfModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshTokenResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RefreshTokenResponse429 extends RefreshTokenResponse {
  const RefreshTokenResponse429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RefreshTokenResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
