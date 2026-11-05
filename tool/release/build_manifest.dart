// Menyusun `version.json` untuk GitHub Release dari APK di folder dist.
// Dipanggil oleh .github/workflows/release.yml; bisa dijalankan lokal:
//
//   dart run tool/release/build_manifest.dart --name 1.0.5 --code 10005 \
//     --tag v1.0.5 --repo akbaralams/eabsensi-mobile-app --dist dist \
//     [--notes-file notes.txt] --out version.json
//
// Folder dist wajib berisi `eabsensi-v<name>.apk` (universal, dibaca semua
// versi aplikasi lewat `apk_url`) dan `eabsensi-v<name>-<abi>.apk` untuk
// setiap ABI di [abis].
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// ABI yang diterbitkan, sesuai keluaran `flutter build apk --split-per-abi`.
const abis = ['arm64-v8a', 'armeabi-v7a', 'x86_64'];

class ApkFile {
  const ApkFile({
    required this.fileName,
    required this.sha256,
    required this.size,
  });

  final String fileName;
  final String sha256;
  final int size;
}

/// Isi manifes. Melempar [ArgumentError] bila ada nilai yang tidak aman,
/// supaya CI gagal sebelum rilis terbit.
Map<String, Object?> buildManifest({
  required String name,
  required int code,
  required String tag,
  required String repo,
  required ApkFile universal,
  required Map<String, ApkFile> variants,
  String notes = '',
}) {
  if (!RegExp(r'^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$').hasMatch(repo)) {
    throw ArgumentError('repo tidak valid: $repo');
  }
  final base = 'https://github.com/$repo/releases/download/$tag';
  Map<String, Object?> entry(ApkFile f) {
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(f.fileName)) {
      throw ArgumentError('Nama berkas tidak aman: ${f.fileName}');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(f.sha256)) {
      throw ArgumentError('sha256 tidak valid untuk ${f.fileName}');
    }
    if (f.size <= 0) throw ArgumentError('${f.fileName} kosong');
    return {'url': '$base/${f.fileName}', 'sha256': f.sha256, 'size': f.size};
  }

  final u = entry(universal);
  final trimmed = notes.trim();
  return {
    'version_name': name,
    'version_code': code,
    'apk_url': u['url'],
    'sha256': u['sha256'],
    'size': u['size'],
    if (trimmed.isNotEmpty) 'notes': trimmed,
    'apks': {
      for (final MapEntry(:key, :value) in variants.entries) key: entry(value),
    },
  };
}

Future<ApkFile> readApk(File file) async => ApkFile(
  fileName: file.uri.pathSegments.last,
  sha256: (await sha256.bind(file.openRead()).first).toString(),
  size: await file.length(),
);

Future<void> main(List<String> args) async {
  final opts = <String, String>{};
  for (var i = 0; i + 1 < args.length; i += 2) {
    if (!args[i].startsWith('--')) break;
    opts[args[i].substring(2)] = args[i + 1];
  }
  String need(String key) {
    final v = opts[key];
    if (v == null || v.isEmpty) {
      stderr.writeln('Argumen --$key wajib diisi.');
      exit(64);
    }
    return v;
  }

  final name = need('name');
  final code = int.tryParse(need('code'));
  if (code == null || code <= 0) {
    stderr.writeln('--code harus bilangan bulat positif.');
    exit(64);
  }
  final dist = opts['dist'] ?? 'dist';
  Future<ApkFile> apk(String fileName) {
    final f = File('$dist/$fileName');
    if (!f.existsSync()) {
      stderr.writeln('Tidak ada ${f.path}');
      exit(66);
    }
    return readApk(f);
  }

  final notesFile = opts['notes-file'];
  final manifest = buildManifest(
    name: name,
    code: code,
    tag: need('tag'),
    repo: need('repo'),
    universal: await apk('eabsensi-v$name.apk'),
    variants: {
      for (final abi in abis) abi: await apk('eabsensi-v$name-$abi.apk'),
    },
    notes: notesFile == null ? '' : File(notesFile).readAsStringSync(),
  );
  final json = const JsonEncoder.withIndent('  ').convert(manifest);
  final out = opts['out'];
  if (out == null) {
    stdout.writeln(json);
  } else {
    File(out).writeAsStringSync('$json\n');
  }
}
