// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:eabsensi_api/src/model/login_request.dart' as _i6;
import 'package:eabsensi_api/src/model/login_v2_response.dart' as _i8;
import 'package:eabsensi_api/src/model/message.dart' as _i9;
import 'package:eabsensi_api/src/model/unprocessable_body_any_of_model.dart'
    as _i10;
import 'package:eabsensi_api/src/operation/dio_operation.dart' as _i1;
import 'package:eabsensi_api/src/response_wrapper/login_v2_response_wrapper.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class LoginV2 extends _i1.DioOperation<_i2.LoginV2ResponseWrapper> {
  LoginV2(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<_i2.LoginV2ResponseWrapper, _i5.Response<_i3.Object?>>
  >
  call({required _i6.LoginRequest body, _i4.TonikCancellation? cancellation}) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(),
        query: null,
        data: _data(body: body),
        options: _options(),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path() {
    return [r'v2', r'auth', r'login'];
  }

  _i3.Object? _data({required _i6.LoginRequest body}) {
    return _i7.jsonEncode(body.toJson());
  }

  _i5.Options _options() {
    final _$headers = <_i3.String, _i3.dynamic>{};
    _$headers['Accept'] = r'application/json';
    return _i5.Options(
      method: 'POST',
      headers: _$headers,
      contentType: r'application/json',
      responseType: _i5.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.LoginV2ResponseWrapper _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i8.LoginV2Response.fromJson(_$json);
        return _i2.LoginV2ResponseWrapper200(body: _$body);
      case (200, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (403, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.Message.fromJson(_$json);
        return _i2.LoginV2ResponseWrapper403(body: _$body);
      case (403, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (422, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i10.UnprocessableBodyAnyOfModel.fromJson(_$json);
        return _i2.LoginV2ResponseWrapper422(body: _$body);
      case (422, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (429, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.Message.fromJson(_$json);
        return _i2.LoginV2ResponseWrapper429(body: _$body);
      default:
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
    }
  }
}
