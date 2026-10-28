import 'user_profile.dart';

abstract class AuthRepository {
  /// Melempar `ValidationFailure`, `RuleRejectedFailure` (422), `ForbiddenFailure`
  /// (403), atau `TooManyRequestsFailure` (429). Token disimpan oleh repository.
  Future<UserProfile> login({
    required String login,
    required String password,
    required String deviceName,
  });

  Future<UserProfile> fetchMe();

  Future<void> logout();
}
