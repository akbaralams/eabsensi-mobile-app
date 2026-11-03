// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/leaves_post201_body_model.dart' as _i2;
import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:eabsensi_api/src/model/unprocessable_body_any_of_model.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class CreateLeaveResponse {
  const CreateLeaveResponse();
}

@_i1.immutable
class CreateLeaveResponse201 extends CreateLeaveResponse {
  const CreateLeaveResponse201({required this.body});

  final _i2.LeavesPost201BodyModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateLeaveResponse201 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CreateLeaveResponse401 extends CreateLeaveResponse {
  const CreateLeaveResponse401({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateLeaveResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CreateLeaveResponse403 extends CreateLeaveResponse {
  const CreateLeaveResponse403({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateLeaveResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CreateLeaveResponse422 extends CreateLeaveResponse {
  const CreateLeaveResponse422({required this.body});

  final _i5.UnprocessableBodyAnyOfModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateLeaveResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CreateLeaveResponse429 extends CreateLeaveResponse {
  const CreateLeaveResponse429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CreateLeaveResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
