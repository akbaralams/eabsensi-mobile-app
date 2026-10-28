import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eabsensi/core/network/api_providers.dart';
import 'package:eabsensi/core/network/generated/export.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';

typedef StubHandler = Future<ResponseBody> Function(RequestOptions options);

/// Adapter HTTP palsu: mencatat permintaan dan menjawab lewat [handler].
class StubAdapter implements HttpClientAdapter {
  StubAdapter(this.handler);

  StubHandler handler;
  final List<RequestOptions> requests = [];

  RequestOptions get last => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Respons JSON dengan header `content-type` seperti server sungguhan.
ResponseBody jsonBody(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

StubAdapter stubReturning(int status, Object body) =>
    StubAdapter((_) async => jsonBody(status, body));

Dio stubDio(StubAdapter adapter, {TokenStore? tokens}) => buildDio(
  tokens ?? MemoryTokenStore('7|rahasia'),
  baseUrl: 'http://test/api',
)..httpClientAdapter = adapter;

MobileApiClient stubClient(StubAdapter adapter, {TokenStore? tokens}) =>
    MobileApiClient(stubDio(adapter, tokens: tokens));

/// Contoh dari `docs/openapi/mobile-api.yaml`.
const meJson = {
  'id': 1,
  'name': 'Pegawai Kontrak',
  'username': 'kontrak',
  'employee': {
    'id': 10,
    'employee_number': '198001012005011001',
    'name': 'Pegawai Kontrak',
    'department': 'Dinas Contoh',
  },
  'timezone': 'Asia/Jakarta',
  'requires_photo': true,
  'requires_approval': true,
};

const punchJson = {
  'id': 5,
  'punched_at': '2026-10-25T07:58:12+07:00',
  'source': 'mobile',
  'status': 'pending',
  'status_label': 'Menunggu persetujuan',
  'has_photo': true,
};
