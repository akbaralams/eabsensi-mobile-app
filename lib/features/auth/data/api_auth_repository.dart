import 'package:eabsensi_api/eabsensi_api.dart' as api;

import '../../../core/api/api_client.dart';
import '../../../core/api/mappers.dart';
import '../../../core/network/api_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';
import 'token_store.dart';

/// Login v2 (`/v2/auth/login`, token akses + refresh token) lebih dulu; bila
/// 404 (backend masih Laravel) jatuh ke v1 (`/auth/login`, tanpa refresh token).
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final ApiClient _api;
  final DateTime Function() _now;

  @override
  Future<UserProfile> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    final body = api.LoginRequest(
      login: login,
      password: password,
      deviceName: deviceName,
    );
    AuthTokens tokens;
    UserProfile profile;
    try {
      (tokens, profile) = await _api.send(
        () => _api.auth.loginV2(body: body),
        (r) => r is api.LoginV2ResponseWrapper200
            ? (
                AuthTokens(
                  accessToken: r.body.token,
                  accessExpiresAt: r.body.tokenExpiresAt,
                  refreshToken: r.body.refreshToken,
                  refreshExpiresAt: r.body.refreshExpiresAt,
                ),
                profileFromApi(r.body.user),
              )
            : null,
        authenticated: false,
      );
    } on NotFoundFailure {
      (tokens, profile) = await _api.send(
        () => _api.auth.login(body: body),
        (r) => r is api.LoginResponseWrapper200
            ? (
                AuthTokens(accessToken: r.body.token),
                profileFromApi(r.body.user),
              )
            : null,
        authenticated: false,
      );
    }
    await _api.tokens.writeTokens(tokens);
    return profile;
  }

  @override
  Future<void> resume() => _api.refresher.refreshIfExpiring(_now());

  @override
  Future<UserProfile> fetchMe() => _api.send(
    () => _api.auth.meOperation(),
    (r) => r is api.MeOperationResponse200 ? profileFromApi(r.body.data) : null,
  );

  @override
  Future<void> logout() async {
    final tokens = await _api.tokens.readTokens();
    if (tokens == null) return;
    // Tanpa refresh: mengeluarkan token yang sudah mati tidak perlu dihidupkan.
    if (tokens.canRefresh) {
      await _api.send(
        () => _api.auth.logoutV2(),
        (r) => r is api.LogoutV2Response200 ? true : null,
        authenticated: false,
      );
    } else {
      await _api.send(
        () => _api.auth.logout(),
        (r) => r is api.LogoutResponse200 ? true : null,
        authenticated: false,
      );
    }
  }
}
