import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import 'api_failure.dart';

/// Memetakan galat Dio ke [ApiFailure] sesuai kontrak:
/// 401 -> [UnauthenticatedFailure], 403 -> [ForbiddenFailure],
/// 422 dengan `errors` -> [ValidationFailure], 422 `message` saja ->
/// [RuleRejectedFailure], 429 -> [TooManyRequestsFailure], tanpa jaringan ->
/// [OfflineFailure], selain itu [UnknownFailure].
ApiFailure failureFromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const OfflineFailure();
    case DioExceptionType.badCertificate:
      return const UnknownFailure(
        'Sambungan ke server tidak aman. Hubungi administrator.',
      );
    case DioExceptionType.transformTimeout:
      return const UnknownFailure();
    case DioExceptionType.cancel:
      return const UnknownFailure('Permintaan dibatalkan.');
    case DioExceptionType.unknown:
      return e.error is SocketException
          ? const OfflineFailure()
          : const UnknownFailure();
    case DioExceptionType.badResponse:
      return _fromResponse(e.response);
  }
}

ApiFailure _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode ?? 0;
  final body = _asMap(response?.data);
  final message = _text(body?['message']);
  switch (status) {
    case 401:
      return const UnauthenticatedFailure();
    case 403:
      return ForbiddenFailure(message ?? 'Akses ditolak.');
    case 422:
      final errors = _errors(body?['errors']);
      if (errors.isNotEmpty) {
        return ValidationFailure(
          message ?? 'Data yang diberikan tidak valid.',
          errors,
        );
      }
      return RuleRejectedFailure(message ?? 'Permintaan ditolak.');
    case 429:
      return const TooManyRequestsFailure();
    default:
      if (status >= 400 && status < 500 && message != null) {
        return UnknownFailure(message);
      }
      return const UnknownFailure();
  }
}

Map<String, Object?>? _asMap(Object? data) {
  if (data is Map) return data.cast<String, Object?>();
  if (data is String && data.isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) return decoded.cast<String, Object?>();
    } on FormatException {
      return null;
    }
  }
  return null;
}

String? _text(Object? v) => v is String && v.trim().isNotEmpty ? v : null;

Map<String, List<String>> _errors(Object? raw) {
  if (raw is! Map) return const {};
  final out = <String, List<String>>{};
  raw.forEach((key, value) {
    final list = value is List
        ? value.whereType<String>().toList()
        : [if (value is String) value];
    if (list.isNotEmpty) out['$key'] = list;
  });
  return out;
}

/// Menjalankan pemanggilan client dan menerjemahkan galatnya ke [ApiFailure].
/// Respons yang tidak sesuai kontrak (JSON rusak, field hilang) menjadi
/// [UnknownFailure], bukan crash.
Future<T> apiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    final inner = e.error;
    if (inner is ApiFailure) throw inner;
    throw failureFromDio(e);
  } on CheckedFromJsonException {
    throw const UnknownFailure('Respons server tidak sesuai kontrak.');
  } on FormatException {
    throw const UnknownFailure('Respons server tidak sesuai kontrak.');
  } on TypeError {
    throw const UnknownFailure('Respons server tidak sesuai kontrak.');
  }
}
