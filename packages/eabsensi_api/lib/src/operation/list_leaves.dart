// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:eabsensi_api/src/model/leaves_get200_body_model.dart' as _i6;
import 'package:eabsensi_api/src/model/message.dart' as _i7;
import 'package:eabsensi_api/src/operation/dio_operation.dart' as _i1;
import 'package:eabsensi_api/src/response_wrapper/list_leaves_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class ListLeaves extends _i1.DioOperation<_i2.ListLeavesResponse> {
  ListLeaves(super.baseUrl, super.clientAccessor);

  _i3.Future<_i4.TonikResult<_i2.ListLeavesResponse, _i5.Response<_i3.Object?>>>
  call({_i4.TonikCancellation? cancellation}) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(),
        query: null,
        data: _data(),
        options: _options(),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path() {
    return [r'leaves'];
  }

  _i3.Object? _data() {
    return null;
  }

  _i5.Options _options() {
    final _$headers = <_i3.String, _i3.dynamic>{};
    _$headers['Accept'] = r'application/json';
    return _i5.Options(
      method: 'GET',
      headers: _$headers,
      responseType: _i5.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.ListLeavesResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i6.LeavesGet200BodyModel.fromJson(_$json);
        return _i2.ListLeavesResponse200(body: _$body);
      case (200, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (401, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i7.Message.fromJson(_$json);
        return _i2.ListLeavesResponse401(body: _$body);
      case (401, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (403, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i7.Message.fromJson(_$json);
        return _i2.ListLeavesResponse403(body: _$body);
      case (403, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (429, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i7.Message.fromJson(_$json);
        return _i2.ListLeavesResponse429(body: _$body);
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
