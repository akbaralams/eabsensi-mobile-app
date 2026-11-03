import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Request yang diterima [FakeAdapter], dengan body mentahnya.
class SeenRequest {
  SeenRequest(this.options, this.body);

  final RequestOptions options;
  final Uint8List body;

  String get path => options.uri.path;
  String get bodyText => utf8.decode(body, allowMalformed: true);
  String? header(String name) {
    final v = options.headers[name];
    return v?.toString();
  }
}

typedef FakeHandler = FutureOr<ResponseBody> Function(
  SeenRequest request,
  int index,
);

/// Adapter HTTP palsu untuk Dio: tanpa jaringan, respons diatur per test.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  FakeHandler handler;
  final requests = <SeenRequest>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final builder = BytesBuilder();
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        builder.add(chunk);
      }
    }
    final seen = SeenRequest(options, builder.takeBytes());
    requests.add(seen);
    return handler(seen, requests.length - 1);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(
  int status,
  Object body, {
  Map<String, List<String>> headers = const {},
}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
    ...headers,
  },
);

ResponseBody textBody(int status, String body, {String type = 'text/html'}) =>
    ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [type],
      },
    );

/// Galat jaringan seperti saat mode pesawat.
Never offline(SeenRequest r) => throw DioException.connectionError(
  requestOptions: r.options,
  reason: 'Failed host lookup',
);

/// Contoh `Me` dari kontrak.
Map<String, Object?> meJson({
  String? username = 'kontrak',
  bool withEmployee = true,
  bool requiresPhoto = true,
  bool requiresApproval = false,
  String timezone = 'Asia/Jakarta',
}) => {
  'id': 7,
  'name': 'Pegawai Kontrak',
  'username': username,
  'employee': withEmployee
      ? {
          'id': 12,
          'employee_number': '2010011004',
          'name': 'Pegawai Kontrak',
          'department': null,
        }
      : null,
  'timezone': timezone,
  'requires_photo': requiresPhoto,
  'requires_approval': requiresApproval,
};

Map<String, Object?> tokenPairJson(String token, {String refresh = 'r1'}) => {
  'token': token,
  'token_expires_at': '2026-11-06T10:00:00+07:00',
  'refresh_token': refresh,
  'refresh_expires_at': '2027-01-28T10:00:00+07:00',
};
