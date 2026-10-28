import '../../../core/network/api_error_mapper.dart';
import '../../../core/network/generated/export.dart' as api;
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';
import 'token_store.dart';

/// Client nyata: `POST /auth/login`, `GET /me`, `POST /auth/logout`.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._client, this._tokens);

  final api.MobileApiClient _client;
  final TokenStore _tokens;

  @override
  Future<UserProfile> login({
    required String login,
    required String password,
    required String deviceName,
  }) => apiCall(() async {
    final res = await _client.auth.login(
      body: api.LoginRequest(
        login: login,
        password: password,
        deviceName: deviceName,
      ),
    );
    await _tokens.write(res.token);
    return profileFromApi(res.user);
  });

  @override
  Future<UserProfile> fetchMe() =>
      apiCall(() async => profileFromApi((await _client.auth.me()).data));

  @override
  Future<void> logout() => apiCall(() async {
    await _client.auth.logout();
  });
}

UserProfile profileFromApi(api.Me me) {
  final e = me.employee;
  return UserProfile(
    id: me.id,
    name: me.name,
    username: me.username,
    employee: e == null
        ? null
        : EmployeeSummary(
            id: e.id,
            employeeNumber: e.employeeNumber,
            name: e.name,
            department: e.department,
          ),
    timezone: me.timezone,
    requiresPhoto: me.requiresPhoto,
    requiresApproval: me.requiresApproval,
  );
}
