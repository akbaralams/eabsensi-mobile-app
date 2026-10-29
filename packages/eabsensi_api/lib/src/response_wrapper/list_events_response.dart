// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:eabsensi_api/src/model/events_get200_body_model.dart' as _i2;
import 'package:eabsensi_api/src/model/message.dart' as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class ListEventsResponse {
  const ListEventsResponse();
}

@_i1.immutable
class ListEventsResponse200 extends ListEventsResponse {
  const ListEventsResponse200({required this.body});

  final _i2.EventsGet200BodyModel body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListEventsResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListEventsResponse401 extends ListEventsResponse {
  const ListEventsResponse401({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListEventsResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListEventsResponse403 extends ListEventsResponse {
  const ListEventsResponse403({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListEventsResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListEventsResponse429 extends ListEventsResponse {
  const ListEventsResponse429({required this.body});

  final _i4.Message body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListEventsResponse429 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
