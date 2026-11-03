// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/login_v2_response.dart' as _i2;
import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:eabsensi_api/src/model/unprocessable_body_any_of_model.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class LoginV2ResponseWrapper {
  const LoginV2ResponseWrapper();
}

@_i1.immutable
class LoginV2ResponseWrapper200 extends LoginV2ResponseWrapper {
  const LoginV2ResponseWrapper200({required this.body});

  final _i2.LoginV2Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginV2ResponseWrapper200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LoginV2ResponseWrapper403 extends LoginV2ResponseWrapper {
  const LoginV2ResponseWrapper403({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginV2ResponseWrapper403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LoginV2ResponseWrapper422 extends LoginV2ResponseWrapper {
  const LoginV2ResponseWrapper422({required this.body});

  final _i5.UnprocessableBodyAnyOfModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginV2ResponseWrapper422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LoginV2ResponseWrapper429 extends LoginV2ResponseWrapper {
  const LoginV2ResponseWrapper429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LoginV2ResponseWrapper429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
