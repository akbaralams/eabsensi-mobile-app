import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/token_store.dart';
import '../config/app_config.dart';
import 'generated/export.dart';

/// Menambahkan `Authorization: Bearer <token>` dari penyimpanan aman. Login
/// tidak membawa token. Token tidak pernah dicatat ke log.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final TokenStore _tokens;

  static const loginPath = '/auth/login';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path != loginPath) {
      final token = await _tokens.read();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

Dio buildDio(TokenStore tokens, {String? baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? AppConfig.baseUrl,
      headers: const {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.add(AuthInterceptor(tokens));
  return dio;
}

final dioProvider = Provider<Dio>((ref) {
  final dio = buildDio(ref.watch(tokenStoreProvider));
  ref.onDispose(dio.close);
  return dio;
});

final mobileApiClientProvider = Provider<MobileApiClient>(
  (ref) => MobileApiClient(ref.watch(dioProvider)),
);
