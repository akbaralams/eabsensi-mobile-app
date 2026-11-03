// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:eabsensi_api/src/model/punches_get200_body_model.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class ListPunchesResponse {
  const ListPunchesResponse();
}

@_i1.immutable
class ListPunchesResponse200 extends ListPunchesResponse {
  const ListPunchesResponse200({required this.body});

  final _i2.PunchesGet200BodyModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListPunchesResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListPunchesResponse401 extends ListPunchesResponse {
  const ListPunchesResponse401({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListPunchesResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListPunchesResponse403 extends ListPunchesResponse {
  const ListPunchesResponse403({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListPunchesResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListPunchesResponse429 extends ListPunchesResponse {
  const ListPunchesResponse429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListPunchesResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
