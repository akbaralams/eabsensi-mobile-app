import 'user_profile.dart';

abstract class AuthRepository {
  /// Melempar `ValidationFailure`, `RuleRejectedFailure` (422), `ForbiddenFailure`
  /// (403), atau `TooManyRequestsFailure` (429). Token disimpan oleh repository.
  Future<UserProfile> login({
    required String login,
    required String password,
    required String deviceName,
  });

  /// Saat aplikasi dibuka: perbarui token akses lebih awal bila hampir
  /// kedaluwarsa. Melempar `UnauthenticatedFailure` bila sesi berakhir.
  Future<void> resume() async {}

  Future<UserProfile> fetchMe();

  /// Cabut token di server. Token di perangkat dihapus oleh pemanggil walau
  /// server tidak terjangkau.
  Future<void> logout();
}
