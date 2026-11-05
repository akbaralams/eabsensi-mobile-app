import 'package:dio/dio.dart';
import 'package:eabsensi/core/format/id_format.dart';
import 'package:eabsensi/features/update/data/http_update_repository.dart';
import 'package:eabsensi/features/update/domain/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

const _base =
    'https://github.com/akbaralams/eabsensi-mobile-app/releases/download/v1.0.5';

Map<String, Object?> _variant(String abi, {String? url, Object? size}) => {
  'url': url ?? '$_base/eabsensi-v1.0.5-$abi.apk',
  'sha256': abi.hashCode.toRadixString(16).padLeft(64, '0').substring(0, 64),
  'size': ?size,
};

Map<String, Object?> _manifest({Object? apks}) => {
  'version_name': '1.0.5',
  'version_code': 10005,
  'apk_url': '$_base/eabsensi-v1.0.5.apk',
  'sha256': 'a' * 64,
  'size': 91130636,
  'apks': ?apks,
};

void main() {
  group('UpdateInfo dengan apks per-ABI', () {
    final info = UpdateInfo.fromJson(
      _manifest(
        apks: {
          'arm64-v8a': _variant('arm64-v8a', size: 33000000),
          'armeabi-v7a': _variant('armeabi-v7a'),
        },
      ),
    );

    test('APK universal tetap dari apk_url, dengan ukuran', () {
      expect(info.apkUrl.path, endsWith('/eabsensi-v1.0.5.apk'));
      expect(info.size, 91130636);
      expect(info.variants.keys, ['arm64-v8a', 'armeabi-v7a']);
      expect(info.variants['armeabi-v7a']!.size, isNull);
    });

    test('forDevice memilih ABI pertama yang tersedia sesuai urutan HP', () {
      final arm64 = info.forDevice(['arm64-v8a', 'armeabi-v7a', 'armeabi']);
      expect(arm64.apkUrl.path, endsWith('-arm64-v8a.apk'));
      expect(arm64.sha256, info.variants['arm64-v8a']!.sha256);
      expect(arm64.size, 33000000);
      expect(arm64.versionCode, 10005);

      // HP Android Go 32-bit: SUPPORTED_ABIS hanya armeabi-v7a.
      expect(
        info.forDevice(['armeabi-v7a', 'armeabi']).apkUrl.path,
        endsWith('-armeabi-v7a.apk'),
      );
    });

    test('ABI tidak tersedia atau tidak diketahui: APK universal', () {
      expect(info.forDevice(['x86']), same(info));
      expect(info.forDevice(const []), same(info));
    });

    test('manifes lama tanpa apks: universal', () {
      final old = UpdateInfo.fromJson(_manifest());
      expect(old.variants, isEmpty);
      expect(old.forDevice(['arm64-v8a']), same(old));
    });

    test('entri rusak dilewati, bukan menggagalkan manifes', () {
      final lenient = UpdateInfo.fromJson(
        _manifest(
          apks: {
            'arm64-v8a': _variant('arm64-v8a', url: 'http://github.com/a.apk'),
            'armeabi-v7a': {'url': '$_base/b.apk', 'sha256': 'pendek'},
            'x86_64': _variant('x86_64', size: -1),
            'ABI ASING!': _variant('x86'),
            'riscv64': 'bukan objek',
            'x86': _variant('x86'),
          },
        ),
      );
      expect(lenient.variants.keys, ['x86']);
    });

    test('apks bukan objek: manifes ditolak', () {
      expect(
        () => UpdateInfo.fromJson(_manifest(apks: ['arm64-v8a'])),
        throwsFormatException,
      );
    });
  });

  test('APK per-ABI dari host lain daripada manifes ditolak', () async {
    final adapter = FakeAdapter(
      (r, i) => jsonBody(
        200,
        _manifest(
          apks: {
            'arm64-v8a': _variant(
              'arm64-v8a',
              url: 'https://evil.example.com/a.apk',
            ),
          },
        ),
      ),
    );
    final repo = HttpUpdateRepository(
      Dio()..httpClientAdapter = adapter,
      Uri.parse(
        'https://github.com/akbaralams/eabsensi-mobile-app/releases/latest/download/version.json',
      ),
    );
    await expectLater(repo.latest(), throwsA(isA<UpdateCheckFailure>()));
  });

  test('ukuran unduhan dalam MB dengan koma desimal', () {
    expect(IdFormat.megabytes(91130636), '86,9 MB');
    expect(IdFormat.megabytes(33000000), '31,5 MB');
    expect(IdFormat.megabytes(512 * 1024), '0,5 MB');
  });
}
