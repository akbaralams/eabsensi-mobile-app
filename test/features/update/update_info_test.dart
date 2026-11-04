import 'package:eabsensi/features/update/domain/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _json({
  Object? name = '1.0.3',
  Object? code = 10003,
  Object? url = 'https://github.com/akbaralams/eabsensi-mobile-app/releases/download/v1.0.3/eabsensi-v1.0.3.apk',
  Object? sha =
      'A3F5C0DE0000000000000000000000000000000000000000000000000000BEEF',
  Object? notes = '  Perbaikan selfie  ',
}) => {
  'version_name': name,
  'version_code': code,
  'apk_url': url,
  'sha256': sha,
  'notes': notes,
};

void main() {
  group('UpdateInfo.fromJson', () {
    test('manifes sah: dibersihkan dan sha256 dibuat huruf kecil', () {
      final info = UpdateInfo.fromJson(_json());
      expect(info.versionName, '1.0.3');
      expect(info.versionCode, 10003);
      expect(info.apkUrl.host, 'github.com');
      expect(info.sha256, 'a3f5c0de${'0' * 52}beef');
      expect(info.notes, 'Perbaikan selfie');
    });

    test('catatan opsional', () {
      expect(UpdateInfo.fromJson(_json(notes: null)).notes, isNull);
      expect(UpdateInfo.fromJson(_json(notes: '   ')).notes, isNull);
    });

    test('apk_url wajib HTTPS', () {
      for (final bad in [
        'http://github.com/x.apk',
        'ftp://github.com/x.apk',
        '//github.com/x.apk',
        'bukan url',
        null,
        42,
      ]) {
        expect(
          () => UpdateInfo.fromJson(_json(url: bad)),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });

    test('sha256 wajib 64 heksadesimal', () {
      for (final bad in [null, '', 'abc', 'z' * 64, '${'a' * 63}g', 'a' * 65]) {
        expect(
          () => UpdateInfo.fromJson(_json(sha: bad)),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });

    test('version_code harus bilangan bulat positif', () {
      for (final bad in [null, 0, -1, '10003', 1.5]) {
        expect(
          () => UpdateInfo.fromJson(_json(code: bad)),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });

    test('version_name tidak boleh kosong atau terlalu panjang', () {
      for (final bad in [null, '', '  ', 'x' * 33, 3]) {
        expect(
          () => UpdateInfo.fromJson(_json(name: bad)),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });
  });

  test('pembaruan ditentukan oleh versionCode, bukan nama versi', () {
    final info = UpdateInfo.fromJson(_json(code: 10003));
    expect(
      info.isNewerThan(const AppVersion(name: '9.9.9', code: 10002)),
      true,
    );
    expect(
      info.isNewerThan(const AppVersion(name: '0.0.1', code: 10003)),
      false,
    );
    expect(
      info.isNewerThan(const AppVersion(name: '0.0.1', code: 20000)),
      false,
    );
  });
}
