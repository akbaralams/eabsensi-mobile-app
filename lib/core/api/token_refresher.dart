import '../../features/auth/data/token_store.dart';
import '../network/api_failure.dart';

/// Menukar refresh token dengan pasangan token baru (`POST /v2/auth/refresh`).
typedef TokenExchange = Future<AuthTokens> Function(String refreshToken);

/// Refresh token dijalankan **satu per satu**: refresh token berotasi, jadi dari
/// dua refresh serentak hanya satu yang berhasil. Request lain yang mendapat
/// 401 menunggu refresh yang sedang berjalan lalu mengulang dengan token baru.
class TokenRefresher {
  TokenRefresher(this._tokens, this._exchange);

  final TokenStore _tokens;
  final TokenExchange _exchange;
  Future<void>? _inflight;

  /// Jumlah pemanggilan endpoint refresh (untuk test dan log debug).
  int exchanges = 0;

  /// Dipanggil setelah respons 401 untuk request yang memakai [usedToken].
  /// Selesai normal bila token baru siap (request boleh diulang sekali).
  /// Melempar [UnauthenticatedFailure] bila sesi berakhir: token v1 tanpa
  /// refresh token, refresh ditolak 401/422, atau 403 (pesan server dibawa).
  Future<void> recover(String? usedToken) async {
    final running = _inflight;
    if (running != null) return running;
    final current = await _tokens.readTokens();
    if (current == null) throw const UnauthenticatedFailure();
    // Token sudah diganti oleh refresh lain selama request ini berjalan.
    if (usedToken != null && current.accessToken != usedToken) return;
    final refresh = current.refreshToken;
    if (refresh == null) throw const UnauthenticatedFailure();
    return _start(refresh);
  }

  /// Refresh lebih awal saat aplikasi dibuka bila sisa masa berlaku token
  /// akses < [margin]. Gagal jaringan diabaikan (token lama masih berlaku);
  /// sesi yang berakhir melempar [UnauthenticatedFailure].
  Future<void> refreshIfExpiring(
    DateTime now, {
    Duration margin = const Duration(days: 1),
  }) async {
    final current = await _tokens.readTokens();
    final refresh = current?.refreshToken;
    if (current == null || refresh == null) return;
    if (!current.expiresWithin(margin, now)) return;
    try {
      await (_inflight ?? _start(refresh));
    } on UnauthenticatedFailure {
      rethrow;
    } on ApiFailure {
      // Coba lagi saat 401 berikutnya.
    }
  }

  Future<void> _start(String refresh) =>
      _inflight ??= _run(refresh).whenComplete(() => _inflight = null);

  Future<void> _run(String refresh) async {
    exchanges++;
    try {
      await _tokens.writeTokens(await _exchange(refresh));
    } on UnauthenticatedFailure {
      await _tokens.clear();
      rethrow;
    } on ForbiddenFailure catch (e) {
      await _tokens.clear();
      throw UnauthenticatedFailure(e.message);
    } on ValidationFailure {
      await _tokens.clear();
      throw const UnauthenticatedFailure();
    } on RuleRejectedFailure {
      await _tokens.clear();
      throw const UnauthenticatedFailure();
    }
  }
}
