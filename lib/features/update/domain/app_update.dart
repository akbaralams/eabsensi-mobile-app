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

/// Satu rilis dari manifes pembaruan (`version.json`).
@immutable
class UpdateInfo {
  const UpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    required this.sha256,
    this.notes,
  });

  /// Memvalidasi manifes. Melempar [FormatException] bila bentuknya salah atau
  /// tidak aman: URL APK wajib HTTPS dan SHA-256 wajib ada (APK yang
  /// diunduh diperiksa terhadap nilai ini sebelum dipasang).
  factory UpdateInfo.fromJson(Map<String, Object?> json) {
    final name = json['version_name'];
    final code = json['version_code'];
    final url = json['apk_url'];
    final hash = json['sha256'];
    final notes = json['notes'];
    if (name is! String || name.trim().isEmpty || name.length > 32) {
      throw const FormatException('version_name tidak valid');
    }
    if (code is! int || code <= 0) {
      throw const FormatException('version_code tidak valid');
    }
    final uri = url is String ? Uri.tryParse(url) : null;
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('apk_url wajib HTTPS');
    }
    if (hash is! String || !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash)) {
      throw const FormatException('sha256 tidak valid');
    }
    return UpdateInfo(
      versionName: name.trim(),
      versionCode: code,
      apkUrl: uri,
      sha256: hash.toLowerCase(),
      notes: notes is String && notes.trim().isNotEmpty
          ? (notes.length > 1000 ? notes.substring(0, 1000) : notes.trim())
          : null,
    );
  }

  final String versionName;
  final int versionCode;
  final Uri apkUrl;
  final String sha256;
  final String? notes;

  bool isNewerThan(AppVersion current) => versionCode > current.code;
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
