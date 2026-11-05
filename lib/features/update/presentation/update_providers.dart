import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/config/app_config.dart';
import '../data/http_update_repository.dart';
import '../data/ota_apk_installer.dart';
import '../domain/app_update.dart';

final appVersionProvider = FutureProvider<AppVersion>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return AppVersion(
    name: info.version,
    code: int.tryParse(info.buildNumber) ?? 0,
  );
});

final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  final url = Uri.tryParse(AppConfig.updateManifestUrl);
  if (AppConfig.useMock || url == null || url.scheme != 'https') {
    return const DisabledUpdateRepository();
  }
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  ref.onDispose(dio.close);
  return HttpUpdateRepository(dio, url);
});

final apkInstallerProvider = Provider<ApkInstaller>(
  (ref) => const OtaApkInstaller(),
);

/// Pembaruan yang tersedia (lebih baru dari versi terpasang), atau `null`.
/// Galat pemeriksaan menjadi `AsyncError` ([UpdateCheckFailure]).
final availableUpdateProvider = FutureProvider<UpdateInfo?>((ref) async {
  final current = await ref.watch(appVersionProvider.future);
  final latest = await ref.watch(updateRepositoryProvider).latest();
  if (latest == null || !latest.isNewerThan(current)) return null;
  return latest.forDevice(await ref.watch(supportedAbisProvider.future));
});

/// ABI yang didukung perangkat, urut preferensi (`Build.SUPPORTED_ABIS`).
/// Galat atau bukan Android: daftar kosong, sehingga APK universal dipakai.
final supportedAbisProvider = FutureProvider<List<String>>((ref) async {
  try {
    if (!Platform.isAndroid) return const [];
    return (await DeviceInfoPlugin().androidInfo).supportedAbis;
  } on Object {
    return const [];
  }
});

sealed class UpdateState {
  const UpdateState();
}

final class UpdateIdle extends UpdateState {
  const UpdateIdle();
}

final class UpdateDownloading extends UpdateState {
  const UpdateDownloading(this.fraction);

  final double? fraction;
}

final class UpdateHandedOff extends UpdateState {
  const UpdateHandedOff();
}

final class UpdateFailed extends UpdateState {
  const UpdateFailed(this.message);

  final String message;
}

class UpdateController extends Notifier<UpdateState> {
  StreamSubscription<InstallEvent>? _sub;

  @override
  UpdateState build() {
    ref.onDispose(() => _sub?.cancel());
    return const UpdateIdle();
  }

  bool get busy => state is UpdateDownloading;

  void start(UpdateInfo info) {
    if (busy) return;
    state = const UpdateDownloading(null);
    _sub?.cancel();
    _sub = ref
        .read(apkInstallerProvider)
        .install(info)
        .listen(
          (e) => state = switch (e) {
            InstallDownloading(:final fraction) => UpdateDownloading(fraction),
            InstallHandedOff() => const UpdateHandedOff(),
            InstallFailed(:final message) => UpdateFailed(message),
          },
          onError: (Object _) => state = const UpdateFailed(
            'Pembaruan gagal. Coba lagi beberapa saat lagi.',
          ),
        );
  }

  /// Tampilan langsung kembali ke awal; pembersihan unduhan menyusul.
  Future<void> cancel() async {
    final sub = _sub;
    _sub = null;
    state = const UpdateIdle();
    final cancelling = ref.read(apkInstallerProvider).cancel();
    await sub?.cancel();
    await cancelling;
  }

  void reset() => state = const UpdateIdle();
}

final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateState>(UpdateController.new);
