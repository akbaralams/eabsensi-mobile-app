// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:eabsensi_api/src/model/punches_post201_body_model.dart' as _i2;
import 'package:eabsensi_api/src/model/unprocessable_body_any_of_model.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class CreatePunchResponse {
  const CreatePunchResponse();
}

@_i1.immutable
class CreatePunchResponse201 extends CreatePunchResponse {
  const CreatePunchResponse201({required this.body});

  final _i2.PunchesPost201BodyModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreatePunchResponse201 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CreatePunchResponse401 extends CreatePunchResponse {
  const CreatePunchResponse401({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreatePunchResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CreatePunchResponse422 extends CreatePunchResponse {
  const CreatePunchResponse422({required this.body});

  final _i5.UnprocessableBodyAnyOfModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreatePunchResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CreatePunchResponse429 extends CreatePunchResponse {
  const CreatePunchResponse429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreatePunchResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
