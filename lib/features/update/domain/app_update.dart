import 'package:flutter/foundation.dart';

/// Versi aplikasi yang sedang terpasang (`version: nama+kode` di pubspec).
@immutable
class AppVersion {
  const AppVersion({required this.name, required this.code});

  final String name;

  /// `versionCode` Android. Hanya ini yang dibandingkan untuk menentukan
  /// pembaruan; nama versi hanya untuk tampilan.
  final int code;

  @override
  String toString() => '$name ($code)';
}

/// Satu berkas APK di manifes: universal (`apk_url`) atau per-ABI (`apks`).
@immutable
class ApkPackage {
  const ApkPackage({required this.url, required this.sha256, this.size});

  /// Melempar [FormatException] bila URL bukan HTTPS atau SHA-256 tidak valid.
  factory ApkPackage.fromJson(Object? url, Object? hash, Object? size) {
    final uri = url is String ? Uri.tryParse(url) : null;
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('URL APK wajib HTTPS');
    }
    if (hash is! String || !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash)) {
      throw const FormatException('sha256 tidak valid');
    }
    if (size != null && (size is! int || size <= 0)) {
      throw const FormatException('size tidak valid');
    }
    return ApkPackage(url: uri, sha256: hash.toLowerCase(), size: size as int?);
  }

  final Uri url;
  final String sha256;

  /// Ukuran berkas dalam byte; `null` bila manifes tidak menyebutkannya.
  final int? size;
}

/// Satu rilis dari manifes pembaruan (`version.json`).
@immutable
class UpdateInfo {
  const UpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    required this.sha256,
    this.size,
    this.notes,
    this.variants = const {},
  });

  /// Memvalidasi manifes. Melempar [FormatException] bila bentuknya salah atau
  /// tidak aman: URL APK wajib HTTPS dan SHA-256 wajib ada (APK yang
  /// diunduh diperiksa terhadap nilai ini sebelum dipasang).
  ///
  /// `apk_url`/`sha256` menunjuk APK universal (dibaca semua versi aplikasi);
  /// `apks` opsional berisi APK per-ABI yang jauh lebih kecil.
  factory UpdateInfo.fromJson(Map<String, Object?> json) {
    final name = json['version_name'];
    final code = json['version_code'];
    final notes = json['notes'];
    if (name is! String || name.trim().isEmpty || name.length > 32) {
      throw const FormatException('version_name tidak valid');
    }
    if (code is! int || code <= 0) {
      throw const FormatException('version_code tidak valid');
    }
    final universal = ApkPackage.fromJson(
      json['apk_url'],
      json['sha256'],
      json['size'],
    );
    final apks = json['apks'];
    if (apks != null && apks is! Map) {
      throw const FormatException('apks tidak valid');
    }
    // Entri per-ABI yang rusak dilewati (perangkat jatuh ke APK universal),
    // supaya satu kesalahan CI tidak mematikan pembaruan sama sekali.
    final variants = <String, ApkPackage>{
      for (final MapEntry(:key, :value) in (apks as Map? ?? const {}).entries)
        if (key is String && _abiPattern.hasMatch(key)) key: ?_variant(value),
    };
    return UpdateInfo(
      versionName: name.trim(),
      versionCode: code,
      apkUrl: universal.url,
      sha256: universal.sha256,
      size: universal.size,
      notes: notes is String && notes.trim().isNotEmpty
          ? (notes.length > 1000 ? notes.substring(0, 1000) : notes.trim())
          : null,
      variants: Map.unmodifiable(variants),
    );
  }

  static final _abiPattern = RegExp(r'^[a-z0-9_-]{1,16}$');

  static ApkPackage? _variant(Object? json) {
    if (json is! Map) return null;
    try {
      return ApkPackage.fromJson(json['url'], json['sha256'], json['size']);
    } on FormatException {
      return null;
    }
  }

  final String versionName;
  final int versionCode;

  /// APK yang akan diunduh: universal, atau per-ABI setelah [forDevice].
  final Uri apkUrl;
  final String sha256;
  final int? size;
  final String? notes;

  /// APK per-ABI dari manifes, dengan kunci nama ABI (mis. `arm64-v8a`).
  final Map<String, ApkPackage> variants;

  bool isNewerThan(AppVersion current) => versionCode > current.code;

  /// Rilis ini dengan APK untuk ABI pertama di [abis] (urutan preferensi
  /// perangkat, `Build.SUPPORTED_ABIS`) yang tersedia; APK universal bila
  /// tidak ada yang cocok.
  UpdateInfo forDevice(List<String> abis) {
    for (final abi in abis) {
      final apk = variants[abi];
      if (apk == null) continue;
      return UpdateInfo(
        versionName: versionName,
        versionCode: versionCode,
        apkUrl: apk.url,
        sha256: apk.sha256,
        size: apk.size,
        notes: notes,
        variants: variants,
      );
    }
    return this;
  }
}

/// Gagal memeriksa pembaruan; [message] aman ditampilkan.
class UpdateCheckFailure implements Exception {
  const UpdateCheckFailure(this.message);

  final String message;

  @override
  String toString() => 'UpdateCheckFailure: $message';
}

abstract class UpdateRepository {
  /// Rilis terbaru, atau `null` bila belum ada rilis atau fitur dimatikan.
  /// Melempar [UpdateCheckFailure].
  Future<UpdateInfo?> latest();
}

sealed class InstallEvent {
  const InstallEvent();
}

/// Mengunduh; [fraction] 0..1, `null` bila belum diketahui.
final class InstallDownloading extends InstallEvent {
  const InstallDownloading(this.fraction);

  final double? fraction;
}

/// Pemasang Android sudah dibuka; pengguna menyelesaikannya di sana.
final class InstallHandedOff extends InstallEvent {
  const InstallHandedOff();
}

final class InstallFailed extends InstallEvent {
  const InstallFailed(this.message);

  final String message;
}

abstract class ApkInstaller {
  /// Mengunduh APK, memeriksa SHA-256, lalu membuka pemasang Android.
  Stream<InstallEvent> install(UpdateInfo info);

  Future<void> cancel();
}
