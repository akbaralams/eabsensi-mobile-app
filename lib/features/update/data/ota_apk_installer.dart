import 'package:ota_update/ota_update.dart';

import '../domain/app_update.dart';

/// Mengunduh APK dan membuka pemasang Android lewat plugin `ota_update`.
/// Plugin memeriksa SHA-256 sebelum memasang; Android sendiri menolak APK yang
/// ditandatangani kunci berbeda dari aplikasi terpasang.
class OtaApkInstaller implements ApkInstaller {
  const OtaApkInstaller();

  @override
  Stream<InstallEvent> install(UpdateInfo info) {
    return OtaUpdate()
        .execute(
          info.apkUrl.toString(),
          // Per versionCode, agar berkas lama bisa dibersihkan berdasarkan
          // versi yang sudah terpasang.
          destinationFilename: 'eabsensi-${info.versionCode}.apk',
          sha256checksum: info.sha256,
        )
        .map(mapOtaEvent);
  }

  @override
  Future<void> cancel() => OtaUpdate().cancel();
}

/// Memetakan status plugin ke peristiwa domain dengan pesan berbahasa
/// Indonesia.
InstallEvent mapOtaEvent(OtaEvent e) => switch (e.status) {
  OtaStatus.DOWNLOADING => InstallDownloading(_percent(e.value)),
  OtaStatus.INSTALLING ||
  OtaStatus.INSTALLATION_DONE => const InstallHandedOff(),
  OtaStatus.PERMISSION_NOT_GRANTED_ERROR => const InstallFailed(
    'Izin memasang aplikasi belum diberikan. Aktifkan "Izinkan dari sumber '
    'ini" untuk eAbsensi di pengaturan, lalu coba lagi.',
  ),
  OtaStatus.CHECKSUM_ERROR => const InstallFailed(
    'Berkas pembaruan tidak sesuai (checksum). Pembaruan dibatalkan demi '
    'keamanan.',
  ),
  OtaStatus.DOWNLOAD_ERROR => const InstallFailed(
    'Gagal mengunduh pembaruan. Periksa koneksi internet lalu coba lagi.',
  ),
  OtaStatus.ALREADY_RUNNING_ERROR => const InstallFailed(
    'Pembaruan sedang diunduh.',
  ),
  OtaStatus.CANCELED => const InstallFailed('Pembaruan dibatalkan.'),
  OtaStatus.INSTALLATION_ERROR ||
  OtaStatus.INTERNAL_ERROR => const InstallFailed(
    'Pembaruan gagal dipasang. Coba lagi, atau unduh ulang aplikasinya.',
  ),
};

double? _percent(String? value) {
  final n = int.tryParse(value ?? '');
  return n == null ? null : n.clamp(0, 100) / 100;
}
