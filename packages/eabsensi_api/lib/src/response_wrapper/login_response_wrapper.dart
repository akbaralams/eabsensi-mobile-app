// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/auth_login_post422_body_any_of_model.dart'
    as _i5;
import 'package:eabsensi_api/src/model/login_response.dart' as _i2;
import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class LoginResponseWrapper {
  const LoginResponseWrapper();
}

@_i1.immutable
class LoginResponseWrapper200 extends LoginResponseWrapper {
  const LoginResponseWrapper200({required this.body});

  final _i2.LoginResponse body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponseWrapper200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LoginResponseWrapper403 extends LoginResponseWrapper {
  const LoginResponseWrapper403({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponseWrapper403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LoginResponseWrapper422 extends LoginResponseWrapper {
  const LoginResponseWrapper422({required this.body});

  final _i5.AuthLoginPost422BodyAnyOfModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponseWrapper422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LoginResponseWrapper429 extends LoginResponseWrapper {
  const LoginResponseWrapper429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginResponseWrapper429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
