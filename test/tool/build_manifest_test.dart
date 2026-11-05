import 'dart:convert';
import 'dart:io';

import 'package:eabsensi/features/update/domain/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/release/build_manifest.dart' as tool;

const _sha = 'abc0000000000000000000000000000000000000000000000000000000000def';

tool.ApkFile _apk(String name, {String sha = _sha, int size = 10}) =>
    tool.ApkFile(fileName: name, sha256: sha, size: size);

Map<String, Object?> _build({
  String repo = 'akbaralams/eabsensi-mobile-app',
  tool.ApkFile? universal,
  Map<String, tool.ApkFile> variants = const {},
  String notes = '',
}) => tool.buildManifest(
  name: '1.0.5',
  code: 10005,
  tag: 'v1.0.5',
  repo: repo,
  universal: universal ?? _apk('eabsensi-v1.0.5.apk'),
  variants: variants,
  notes: notes,
);

void main() {
  test('manifes terbaca aplikasi: universal + per-ABI', () {
    final manifest = _build(
      universal: _apk('eabsensi-v1.0.5.apk', size: 91000000),
      variants: {
        'arm64-v8a': _apk('eabsensi-v1.0.5-arm64-v8a.apk', size: 31000000),
      },
      notes: '  Perbaikan selfie\n\n',
    );
    // Lewat JSON, persis seperti yang diunduh dari GitHub.
    final info = UpdateInfo.fromJson(
      (jsonDecode(jsonEncode(manifest)) as Map).cast<String, Object?>(),
    );
    expect(
      info.apkUrl.toString(),
      'https://github.com/akbaralams/eabsensi-mobile-app/releases/download/v1.0.5/eabsensi-v1.0.5.apk',
    );
    expect(info.size, 91000000);
    expect(info.notes, 'Perbaikan selfie');
    final arm64 = info.forDevice(['arm64-v8a']);
    expect(arm64.apkUrl.path, endsWith('/eabsensi-v1.0.5-arm64-v8a.apk'));
    expect(arm64.size, 31000000);
  });

  test('catatan kosong tidak ditulis', () {
    expect(_build().containsKey('notes'), isFalse);
  });

  test('nilai tidak aman membuat CI gagal', () {
    expect(
      () => _build(universal: _apk('u.apk', sha: 'pendek')),
      throwsArgumentError,
    );
    expect(
      () => _build(universal: _apk('u.apk', size: 0)),
      throwsArgumentError,
    );
    expect(() => _build(universal: _apk('../u.apk')), throwsArgumentError);
    expect(() => _build(repo: 'evil.com/a/b'), throwsArgumentError);
  });

  test('CLI membaca dist: sha256 dan ukuran berkas sungguhan', () async {
    final dir = await Directory.systemTemp.createTemp('manifest');
    addTearDown(() => dir.delete(recursive: true));
    File('${dir.path}/eabsensi-v1.0.5.apk').writeAsStringSync('universal');
    for (final abi in tool.abis) {
      File('${dir.path}/eabsensi-v1.0.5-$abi.apk').writeAsStringSync(abi);
    }
    final notes = File('${dir.path}/notes.txt')..writeAsStringSync('Catatan');
    final out = '${dir.path}/version.json';
    await tool.main([
      '--name',
      '1.0.5',
      '--code',
      '10005',
      '--tag',
      'v1.0.5',
      '--repo',
      'akbaralams/eabsensi-mobile-app',
      '--dist',
      dir.path,
      '--notes-file',
      notes.path,
      '--out',
      out,
    ]);
    final json = jsonDecode(File(out).readAsStringSync()) as Map;
    expect(
      json['sha256'],
      'a9fd078562420a276b6902ca3d8bf583c0366e38af72e23be99b16035a76b39a',
    );
    expect(json['size'], 'universal'.length);
    expect(json['notes'], 'Catatan');
    expect((json['apks'] as Map).keys, tool.abis);
  });
}
