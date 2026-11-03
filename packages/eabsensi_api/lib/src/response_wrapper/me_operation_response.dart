// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/me_get200_body_model.dart' as _i2;
import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class MeOperationResponse {
  const MeOperationResponse();
}

@_i1.immutable
class MeOperationResponse200 extends MeOperationResponse {
  const MeOperationResponse200({required this.body});

  final _i2.MeGet200BodyModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is MeOperationResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class MeOperationResponse401 extends MeOperationResponse {
  const MeOperationResponse401({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is MeOperationResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class MeOperationResponse429 extends MeOperationResponse {
  const MeOperationResponse429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is MeOperationResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
