// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/leaves_get200_body_model.dart' as _i2;
import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class ListLeavesResponse {
  const ListLeavesResponse();
}

@_i1.immutable
class ListLeavesResponse200 extends ListLeavesResponse {
  const ListLeavesResponse200({required this.body});

  final _i2.LeavesGet200BodyModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListLeavesResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListLeavesResponse401 extends ListLeavesResponse {
  const ListLeavesResponse401({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListLeavesResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListLeavesResponse403 extends ListLeavesResponse {
  const ListLeavesResponse403({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListLeavesResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListLeavesResponse429 extends ListLeavesResponse {
  const ListLeavesResponse429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListLeavesResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
