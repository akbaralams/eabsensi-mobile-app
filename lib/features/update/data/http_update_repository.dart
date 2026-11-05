import 'dart:convert';

import 'package:dio/dio.dart';

import '../domain/app_update.dart';

/// Membaca `version.json` dari [manifest] (mis. aset rilis GitHub). Memakai
/// Dio tersendiri tanpa token API: jangan pernah mengirim Bearer ke host lain.
class HttpUpdateRepository implements UpdateRepository {
  HttpUpdateRepository(this._dio, this.manifest);

  final Dio _dio;
  final Uri manifest;

  @override
  Future<UpdateInfo?> latest() async {
    final Response<String> res;
    try {
      res = await _dio.getUri<String>(
        manifest,
        options: Options(
          // Aset rilis GitHub disajikan sebagai octet-stream: urai sendiri.
          responseType: ResponseType.plain,
          headers: const {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      // Belum ada rilis yang terbit: bukan galat bagi pengguna.
      if (e.response?.statusCode == 404) return null;
      throw const UpdateCheckFailure(
        'Tidak dapat memeriksa pembaruan. Periksa koneksi internet.',
      );
    }
    try {
      final json = jsonDecode(res.data ?? '');
      if (json is! Map) throw const FormatException('bukan objek');
      final info = UpdateInfo.fromJson(json.cast<String, Object?>());
      // Semua APK (universal dan per-ABI) harus dari host yang sama dengan
      // manifes.
      final hosts = {
        info.apkUrl.host,
        for (final v in info.variants.values) v.url.host,
      };
      if (hosts.any((h) => h != manifest.host)) {
        throw const FormatException('host apk_url berbeda dari manifes');
      }
      return info;
    } on FormatException {
      throw const UpdateCheckFailure(
        'Data pembaruan dari server tidak valid. Coba lagi nanti.',
      );
    }
  }
}

/// Pembaruan dimatikan (mode contoh atau `UPDATE_MANIFEST_URL` kosong).
class DisabledUpdateRepository implements UpdateRepository {
  const DisabledUpdateRepository();

  @override
  Future<UpdateInfo?> latest() async => null;
}
