// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Message extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Message({required this.message});

  factory Message.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'message'},
      listKeys: {},
      context: r'Message',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Message(
      message: _$values[r'message'].decodeSimpleString(
        context: r'Message.message',
      ),
    );
  }

  factory Message.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Message');
    return Message(
      message: _$map[r'message'].decodeJsonString(context: r'Message.message'),
    );
  }

  factory Message.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'message'},
      listKeys: {},
      context: r'Message',
    );
    return Message(
      message: _$values[r'message'].decodeFormString(
        context: r'Message.message',
      ),
    );
  }

  final _i3.String message;

  @_i3.override
  _i3.Object? toJson() => {r'message': this.message};

  Message Function({_i3.String? message}) get copyWith {
    return ({_i3.String? message}) => Message(message: message ?? this.message);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Message && other.message == this.message;
  }

  @_i3.override
  _i3.int get hashCode => this.message.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'message'] = _i1.PropertyValue.scalar(this.message);
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i4.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Message: complex types cannot be URI-encoded',
    );
  }
}
