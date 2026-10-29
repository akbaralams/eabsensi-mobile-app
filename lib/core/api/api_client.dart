import 'package:dio/dio.dart';
import 'package:eabsensi_api/eabsensi_api.dart';
import 'package:flutter/foundation.dart';
import 'package:tonik_util/tonik_util.dart';

import '../../features/auth/data/token_store.dart';
import '../network/api_failure.dart';
import 'token_refresher.dart';

typedef RawResponse = Response<Object?>;
typedef ApiResult<R> = TonikResult<R, RawResponse>;

/// Lapisan HTTP tipis di atas client hasil generator (`packages/eabsensi_api`):
/// `Accept: application/json` dan `Authorization: Bearer` di setiap request,
/// base URL dari konfigurasi build, timeout sambung 10 dtk dan kirim/terima
/// 60 dtk (server memutus di 60 dtk), refresh token sekali saat 401, dan
/// pemetaan galat ke [ApiFailure]. UI tidak menyentuh model hasil generator.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.tokens,
    HttpClientAdapter? adapter,
  }) : dio = Dio(
         BaseOptions(
           connectTimeout: const Duration(seconds: 10),
           sendTimeout: const Duration(seconds: 60),
           receiveTimeout: const Duration(seconds: 60),
           headers: const {'Accept': 'application/json'},
         ),
       ) {
    if (adapter != null) dio.httpClientAdapter = adapter;
    dio.interceptors.add(_AuthHeaders(tokens));
    if (kDebugMode) dio.interceptors.add(_DebugLog());
    final server = CustomServer(
      baseUrl: baseUrl,
      serverConfig: ServerConfig<Dio>.client(dio),
    );
    auth = AuthApi(server);
    punches = PunchApi(server);
    events = EventApi(server);
    leaves = CutiApi(server);
    refresher = TokenRefresher(tokens, _exchange);
  }

  final Dio dio;
  final TokenStore tokens;
  late final AuthApi auth;
  late final PunchApi punches;
  late final EventApi events;
  late final CutiApi leaves;
  late final TokenRefresher refresher;

  /// Jalankan operasi hasil generator. [onSuccess] memetakan respons sukses
  /// (2xx) ke model domain dan mengembalikan `null` untuk varian lain, yang
  /// lalu dipetakan dari status dan body mentahnya.
  ///
  /// [authenticated]: 401 memicu satu refresh token lalu request diulang
  /// sekali; 401 kedua -> [UnauthenticatedFailure].
  Future<T> send<R, T extends Object>(
    Future<ApiResult<R>> Function() operation,
    T? Function(R value) onSuccess, {
    bool authenticated = true,
  }) async {
    var result = await operation();
    if (authenticated && statusOf(result) == 401) {
      await refresher.recover(_bearerOf(result));
      result = await operation();
    }
    return unwrapResult(result, onSuccess);
  }

  Future<AuthTokens> _exchange(String refreshToken) => send(
    () => auth.refreshToken(body: RefreshRequest(refreshToken: refreshToken)),
    (r) => r is RefreshTokenResponse200 ? tokensFromPair(r.body) : null,
    authenticated: false,
  );

  void close() => dio.close(force: true);
}

AuthTokens tokensFromPair(TokenPair p) => AuthTokens(
  accessToken: p.token,
  accessExpiresAt: p.tokenExpiresAt,
  refreshToken: p.refreshToken,
  refreshExpiresAt: p.refreshExpiresAt,
);

int? statusOf(ApiResult<Object?> result) => switch (result) {
  TonikSuccess(:final response) => response.statusCode,
  TonikError(:final response) => response?.statusCode,
};

String? _bearerOf(ApiResult<Object?> result) {
  final response = switch (result) {
    TonikSuccess(:final response) => response,
    TonikError(:final response) => response,
  };
  final header = response?.requestOptions.headers['Authorization'];
  if (header is! String || !header.startsWith('Bearer ')) return null;
  return header.substring(7);
}

/// Ambil nilai sukses atau lempar [ApiFailure] yang sesuai kontrak.
T unwrapResult<R, T extends Object>(
  ApiResult<R> result,
  T? Function(R value) onSuccess,
) {
  switch (result) {
    case TonikSuccess(:final value, :final response):
      final mapped = onSuccess(value);
      if (mapped != null) return mapped;
      throw failureFromRaw(response);
    case TonikError(:final error, :final type, :final response):
      final status = response?.statusCode;
      if (response != null &&
          status != null &&
          (status < 200 || status > 299)) {
        throw failureFromRaw(response);
      }
      if (kDebugMode) debugPrint('API galat ($type): $error');
      if (type == TonikErrorType.network && _isConnectivity(error)) {
        throw const OfflineFailure();
      }
      throw const UnknownFailure();
  }
}

ApiFailure failureFromRaw(RawResponse response) => failureFromResponse(
  response.statusCode,
  retryAfter: response.headers.value('retry-after'),
  body: response.data,
);

bool _isConnectivity(Object error) {
  if (error is! DioException) return true;
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.unknown => true,
    DioExceptionType.badCertificate ||
    DioExceptionType.badResponse ||
    DioExceptionType.cancel => false,
  };
}

/// Endpoint tanpa token (kontrak: `security: []`).
bool _isPublic(String path) =>
    path.endsWith('/auth/login') || path.endsWith('/auth/refresh');

class _AuthHeaders extends Interceptor {
  _AuthHeaders(this._tokens);

  final TokenStore _tokens;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';
    if (!_isPublic(options.uri.path)) {
      final token = await _tokens.read();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Log debug ringkas: metode, path, status, dan ukuran berkas multipart.
/// Tidak mencatat token maupun isi body.
class _DebugLog extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = options.data;
    var extra = '';
    if (data is FormData) {
      final files = data.files
          .where((f) => f.value.filename != null)
          .map(
            (f) => '${f.key}=${(f.value.length / 1024).toStringAsFixed(1)} KB',
          )
          .join(', ');
      if (files.isNotEmpty) extra = ' [$files]';
    }
    debugPrint('API -> ${options.method} ${options.uri.path}$extra');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      'API <- ${response.statusCode} ${response.requestOptions.uri.path}',
    );
    handler.next(response);
  }
}
