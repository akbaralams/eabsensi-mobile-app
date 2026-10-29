import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token perangkat. Login v2 mengisi semua field; login v1 (backend Laravel)
/// hanya [accessToken], tanpa refresh token dan masa berlaku.
@immutable
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    this.accessExpiresAt,
    this.refreshToken,
    this.refreshExpiresAt,
  });

  final String accessToken;
  final DateTime? accessExpiresAt;
  final String? refreshToken;
  final DateTime? refreshExpiresAt;

  bool get canRefresh => refreshToken != null;

  /// Sisa masa berlaku token akses kurang dari [margin] pada [now].
  bool expiresWithin(Duration margin, DateTime now) {
    final at = accessExpiresAt;
    return at != null && at.difference(now) < margin;
  }

  Map<String, Object?> toJson() => {
    'token': accessToken,
    'token_expires_at': accessExpiresAt?.toUtc().toIso8601String(),
    'refresh_token': refreshToken,
    'refresh_expires_at': refreshExpiresAt?.toUtc().toIso8601String(),
  };

  static AuthTokens? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final token = json['token'];
    if (token is! String || token.isEmpty) return null;
    DateTime? date(Object? v) => v is String ? DateTime.tryParse(v) : null;
    final refresh = json['refresh_token'];
    return AuthTokens(
      accessToken: token,
      accessExpiresAt: date(json['token_expires_at']),
      refreshToken: refresh is String && refresh.isNotEmpty ? refresh : null,
      refreshExpiresAt: date(json['refresh_expires_at']),
    );
  }
}

/// Penyimpanan token. Implementasi nyata memakai Keystore/Keychain.
abstract class TokenStore {
  Future<AuthTokens?> readTokens();
  Future<void> writeTokens(AuthTokens tokens);
  Future<void> clear();

  /// Token akses saja (untuk header `Authorization`).
  Future<String?> read() async => (await readTokens())?.accessToken;

  /// Simpan token v1 (tanpa refresh token).
  Future<void> write(String token) =>
      writeTokens(AuthTokens(accessToken: token));
}

class SecureTokenStore extends TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_session';
  static const _legacyKey = 'auth_token';
  final FlutterSecureStorage _storage;

  /// Cache di memori: header `Authorization` dibaca di setiap request.
  AuthTokens? _cache;
  bool _loaded = false;

  @override
  Future<AuthTokens?> readTokens() async {
    if (_loaded) return _cache;
    final raw = await _storage.read(key: _key);
    AuthTokens? tokens;
    if (raw != null) {
      try {
        tokens = AuthTokens.fromJson(jsonDecode(raw));
      } on FormatException {
        tokens = null;
      }
    } else {
      final legacy = await _storage.read(key: _legacyKey);
      if (legacy != null && legacy.isNotEmpty) {
        tokens = AuthTokens(accessToken: legacy);
      }
    }
    _cache = tokens;
    _loaded = true;
    return tokens;
  }

  @override
  Future<void> writeTokens(AuthTokens tokens) async {
    _cache = tokens;
    _loaded = true;
    await _storage.write(key: _key, value: jsonEncode(tokens.toJson()));
    await _storage.delete(key: _legacyKey);
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    await _storage.delete(key: _key);
    await _storage.delete(key: _legacyKey);
  }
}

/// Untuk test.
class MemoryTokenStore extends TokenStore {
  MemoryTokenStore([String? token])
    : _tokens = token == null ? null : AuthTokens(accessToken: token);

  MemoryTokenStore.withTokens(this._tokens);

  AuthTokens? _tokens;

  @override
  Future<AuthTokens?> readTokens() async => _tokens;

  @override
  Future<void> writeTokens(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

/// Token selalu di penyimpanan aman (Keystore/Keychain); test meng-override.
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());
