import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_failure.dart';
import '../../../core/storage/preferences.dart';
import '../data/device_name.dart';
import '../data/mock_auth_repository.dart';
import '../data/token_store.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.useMock) return MockAuthRepository(ref.watch(mockEnvProvider));
  throw UnimplementedError('Client API nyata belum tersedia (Task 3).');
});

/// Sesi pengguna: profil bila sudah masuk, `null` bila belum.
/// Respons 401 di endpoint mana pun memanggil [expire] (token dihapus, ke login).
class SessionController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final store = ref.read(tokenStoreProvider);
    if (await store.read() == null) return null;
    try {
      return await ref.read(authRepositoryProvider).fetchMe();
    } on UnauthenticatedFailure {
      await store.clear();
      return null;
    }
  }

  Future<void> login(String login, String password) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final profile = await ref
        .read(authRepositoryProvider)
        .login(
          login: login.trim(),
          password: password,
          deviceName: await stableDeviceName(prefs),
        );
    state = AsyncData(profile);
  }

  /// Muat ulang `/me` (mis. flag `requires_photo` berubah).
  Future<void> refresh() async {
    try {
      final profile = await ref.read(authRepositoryProvider).fetchMe();
      state = AsyncData(profile);
    } on UnauthenticatedFailure {
      await expire();
    } on ApiFailure {
      // Pertahankan profil lama bila jaringan bermasalah.
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } on ApiFailure {
      // Token tetap dihapus di perangkat walau server tidak terjangkau.
    }
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(null);
  }

  /// Dipanggil saat server menjawab 401.
  Future<void> expire() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(null);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionController, UserProfile?>(
  SessionController.new,
);

/// `ref.read` dari `Ref` maupun `WidgetRef`.
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

/// Pembungkus pemanggilan repository: 401 mencabut sesi lalu galat diteruskan.
/// Dipanggil sebagai `withSession(ref.read, () => ...)`.
Future<T> withSession<T>(ProviderReader read, Future<T> Function() call) async {
  try {
    return await call();
  } on UnauthenticatedFailure {
    await read(sessionProvider.notifier).expire();
    rethrow;
  }
}

/// Nama perangkat stabil per instalasi (juga ditampilkan di layar absen).
final deviceNameProvider = FutureProvider<String>(
  (ref) => stableDeviceName(ref.read(sharedPreferencesProvider)),
);
