// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/message.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class LogoutResponse {
  const LogoutResponse();
}

@_i1.immutable
class LogoutResponse200 extends LogoutResponse {
  const LogoutResponse200({required this.body});

  final _i2.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LogoutResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LogoutResponse401 extends LogoutResponse {
  const LogoutResponse401({required this.body});

  final _i2.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LogoutResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LogoutResponse429 extends LogoutResponse {
  const LogoutResponse429({required this.body});

  final _i2.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LogoutResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
