// Bangkitkan client Dart dari `api/openapi.yaml` dengan Tonik (pure Dart,
// OpenAPI 3.1, tanpa Java). Hasilnya paket `packages/eabsensi_api` yang dipakai
// aplikasi lewat path dependency. Jangan edit hasilnya dengan tangan.
//
//   dart run tool/generate_api.dart
//
// Versi Tonik dipin di [_tonikVersion] agar hasil bisa diulang; naikkan bersama
// `tonik_util` di pubspec.yaml aplikasi.
import 'dart:io';

const _tonikVersion = '0.11.1';
const _spec = 'api/openapi.yaml';
const _outDir = 'packages';
const _package = 'eabsensi_api';

Future<void> main() async {
  final spec = File(_spec);
  if (!spec.existsSync()) {
    stderr.writeln('Tidak ada $_spec. Jalankan dulu tool/sync_contract.dart.');
    exit(66);
  }

  // Spesifikasi yang dinormalkan untuk generator saja; api/openapi.yaml tetap
  // salinan persis kontrak.
  final normalized = File('.dart_tool/openapi.tonik.yaml')
    ..createSync(recursive: true)
    ..writeAsStringSync(normalizeForTonik(spec.readAsStringSync()));

  await _run('dart', [
    'pub',
    'global',
    'activate',
    'tonik',
    _tonikVersion,
  ], quiet: true);

  final target = Directory('$_outDir/$_package');
  if (target.existsSync()) target.deleteSync(recursive: true);

  await _run('dart', [
    'pub',
    'global',
    'run',
    'tonik',
    '--package-name=$_package',
    '--spec=${normalized.path}',
    '--output-dir=$_outDir',
    '--backend=dio',
    '--log-level=warn',
  ]);
  stdout.writeln(
    'Client dibangkitkan di ${target.path} (tonik $_tonikVersion).',
  );
}

/// Tonik 0.11 menyalin `encoding.contentType` apa adanya ke header bagian
/// multipart, dan `DioMediaType.parse` menolak daftar berkoma
/// (`image/jpeg, image/png`, sah di OpenAPI). Ambil jenis pertama: aplikasi
/// selalu mengirim JPEG. Server memeriksa jenis dari isi berkas.
String normalizeForTonik(String yaml) => yaml.replaceAllMapped(
  RegExp(r"contentType: '([^',]+),[^']*'"),
  (m) => "contentType: '${m[1]!.trim()}'",
);

Future<void> _run(String exe, List<String> args, {bool quiet = false}) async {
  final result = await Process.run(exe, args, runInShell: true);
  if (!quiet || result.exitCode != 0) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }
  if (result.exitCode != 0) {
    stderr.writeln('Gagal: $exe ${args.join(' ')}');
    exit(result.exitCode);
  }
}
