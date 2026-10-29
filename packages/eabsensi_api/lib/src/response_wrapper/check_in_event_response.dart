// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/events_event_check_in_post201_body_model.dart'
    as _i2;
import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:eabsensi_api/src/model/unprocessable_body_any_of_model.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class CheckInEventResponse {
  const CheckInEventResponse();
}

@_i1.immutable
class CheckInEventResponse201 extends CheckInEventResponse {
  const CheckInEventResponse201({required this.body});

  final _i2.EventsEventCheckInPost201BodyModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CheckInEventResponse201 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CheckInEventResponse401 extends CheckInEventResponse {
  const CheckInEventResponse401({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CheckInEventResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CheckInEventResponse404 extends CheckInEventResponse {
  const CheckInEventResponse404({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CheckInEventResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CheckInEventResponse422 extends CheckInEventResponse {
  const CheckInEventResponse422({required this.body});

  final _i5.UnprocessableBodyAnyOfModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CheckInEventResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class CheckInEventResponse429 extends CheckInEventResponse {
  const CheckInEventResponse429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CheckInEventResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
