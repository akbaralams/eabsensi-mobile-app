// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i7;
import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:eabsensi_api/src/model/events_event_check_in_post201_body_model.dart'
    as _i8;
import 'package:eabsensi_api/src/model/evidence_form.dart' as _i6;
import 'package:eabsensi_api/src/model/message.dart' as _i9;
import 'package:eabsensi_api/src/model/unprocessable_body_any_of_model.dart'
    as _i10;
import 'package:eabsensi_api/src/operation/dio_operation.dart' as _i1;
import 'package:eabsensi_api/src/response_wrapper/check_in_event_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class CheckInEvent extends _i1.DioOperation<_i2.CheckInEventResponse> {
  CheckInEvent(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<_i2.CheckInEventResponse, _i5.Response<_i3.Object?>>
  >
  call({
    required _i6.EvidenceForm body,
    required _i3.int event,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.executeAsync(
      cancellation: cancellation,
      prepare: () async => _i1.DioOperationRequest(
        path: _path(event: event),
        query: null,
        data: await _data(body: body),
        options: _options(),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path({required _i3.int event}) {
    return [
      r'events',
      event.toSimple(explode: false, allowEmpty: false),
      r'check-in',
    ];
  }

  _i7.Future<_i3.Object?> _data({required _i6.EvidenceForm body}) async {
    final _$formData = _i5.FormData();
    if (body.photo != null) {
      switch (body.photo!) {
        case _i4.TonikFileBytes(:final bytes, :final fileName):
          _$formData.files.add(
            _i3.MapEntry(
              (r'photo').replaceAll(r'\', r'\\'),
              _i5.MultipartFile.fromBytes(
                bytes,
                filename: (fileName ?? r'photo').replaceAll(r'\', r'\\'),
                contentType: _i5.DioMediaType.parse(r'image/jpeg'),
              ),
            ),
          );
        case _i4.TonikFilePath(:final path, :final fileName):
          _$formData.files.add(
            _i3.MapEntry(
              (r'photo').replaceAll(r'\', r'\\'),
              await _i5.MultipartFile.fromFile(
                path,
                filename: (fileName ?? r'photo').replaceAll(r'\', r'\\'),
                contentType: _i5.DioMediaType.parse(r'image/jpeg'),
              ),
            ),
          );
      }
    }
    if (body.latitude != null) {
      _$formData.files.add(
        _i3.MapEntry(
          (r'latitude').replaceAll(r'\', r'\\'),
          _i5.MultipartFile.fromString(
            body.latitude!.toString(),
            contentType: _i5.DioMediaType.parse(r'text/plain'),
          ),
        ),
      );
    }
    if (body.longitude != null) {
      _$formData.files.add(
        _i3.MapEntry(
          (r'longitude').replaceAll(r'\', r'\\'),
          _i5.MultipartFile.fromString(
            body.longitude!.toString(),
            contentType: _i5.DioMediaType.parse(r'text/plain'),
          ),
        ),
      );
    }
    if (body.accuracy != null) {
      _$formData.files.add(
        _i3.MapEntry(
          (r'accuracy').replaceAll(r'\', r'\\'),
          _i5.MultipartFile.fromString(
            body.accuracy!.toString(),
            contentType: _i5.DioMediaType.parse(r'text/plain'),
          ),
        ),
      );
    }
    if (_$formData.fields.isEmpty && _$formData.files.isEmpty) {
      throw _i4.EncodingException(
        r'Multipart request body must contain at least one part.',
      );
    }
    return _$formData;
  }

  _i5.Options _options() {
    final _$headers = <_i3.String, _i3.dynamic>{};
    _$headers['Accept'] = r'application/json';
    return _i5.Options(
      method: 'POST',
      headers: _$headers,
      contentType: null,
      responseType: _i5.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.CheckInEventResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (201, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i8.EventsEventCheckInPost201BodyModel.fromJson(_$json);
        return _i2.CheckInEventResponse201(body: _$body);
      case (201, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (401, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.Message.fromJson(_$json);
        return _i2.CheckInEventResponse401(body: _$body);
      case (401, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (404, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.Message.fromJson(_$json);
        return _i2.CheckInEventResponse404(body: _$body);
      case (404, _):
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
        return _i2.CheckInEventResponse422(body: _$body);
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
        return _i2.CheckInEventResponse429(body: _$body);
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
