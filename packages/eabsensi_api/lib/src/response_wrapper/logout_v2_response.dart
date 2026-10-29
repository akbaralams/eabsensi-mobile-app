// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/message.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class LogoutV2Response {
  const LogoutV2Response();
}

@_i1.immutable
class LogoutV2Response200 extends LogoutV2Response {
  const LogoutV2Response200({required this.body});

  final _i2.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LogoutV2Response200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LogoutV2Response401 extends LogoutV2Response {
  const LogoutV2Response401({required this.body});

  final _i2.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LogoutV2Response401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LogoutV2Response429 extends LogoutV2Response {
  const LogoutV2Response429({required this.body});

  final _i2.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LogoutV2Response429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
