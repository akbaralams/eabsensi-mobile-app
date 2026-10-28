/// Membangkitkan client Dart (Dio + Retrofit) dan model dari kontrak OpenAPI.
///
///   dart run tool/generate_api.dart [path/ke/mobile-api.yaml]
///
/// Sumber kontrak, berurutan: argumen, `../eabsensi-mobile-api/docs/openapi/`,
/// `../eabsensi-v2/docs/openapi/`. Salinan kontrak disimpan di
/// `api/mobile-api.yaml` (di-commit) supaya hasil bisa diulang tanpa repo lain;
/// tanpa sumber di atas, skrip memakai salinan itu.
library;

import 'dart:io';

const _snapshot = 'api/mobile-api.yaml';
const _derived = '.dart_tool/api/mobile-api.yaml';
const _candidates = [
  '../eabsensi-mobile-api/docs/openapi/mobile-api.yaml',
  '../eabsensi-v2/docs/openapi/mobile-api.yaml',
];

Future<void> main(List<String> args) async {
  final root = File.fromUri(Platform.script).parent.parent.path;
  Directory.current = root;

  final source = args.isNotEmpty
      ? args.first
      : _candidates.firstWhere(
          (p) => File(p).existsSync(),
          orElse: () => _snapshot,
        );
  if (!File(source).existsSync()) {
    stderr.writeln('Kontrak tidak ditemukan: $source');
    exit(1);
  }
  if (File(source).absolute.path != File(_snapshot).absolute.path) {
    stdout.writeln('Menyalin kontrak dari $source -> $_snapshot');
    File(_snapshot)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(File(source).readAsBytesSync());
  }

  _writeDerivedSpec();

  await _run('dart', ['run', 'swagger_parser']);
  await _run('dart', [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  await _run('dart', ['format', 'lib/core/network/generated']);
  stdout.writeln('Selesai. Hasil di lib/core/network/generated.');
}

Future<void> _run(String exe, List<String> args) async {
  stdout.writeln('\$ $exe ${args.join(' ')}');
  final p = await Process.start(
    exe,
    args,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  final code = await p.exitCode;
  if (code != 0) exit(code);
}

/// Waktu di kontrak adalah teks ISO 8601 di zona bisnis, bukan instan UTC:
/// - `format: date` (`2026-10-25`) dipetakan pembangkit ke `DateTime` dan
///   dikirim sebagai ISO penuh; query `date` seperti itu dianggap tidak valid
///   oleh server (= hari ini) dan server yang ketat menolaknya.
/// - `format: date-time` (`2026-10-25T07:58:12+07:00`) di-parse ke UTC sehingga
///   jam dinding zona bisnis hilang.
/// Salinan turunan di `.dart_tool` mengganti kedua format itu agar menjadi
/// `String`; konversinya ada di `lib/core/network/api_time.dart`. Salinan di
/// `api/` tetap persis kontrak.
void _writeDerivedSpec() {
  final date = RegExp(r'format:\s*date(?=\s*[,}\n])');
  final dateTime = RegExp(r'format:\s*date-time(?=\s*[,}\n])');
  final text = File(_snapshot).readAsStringSync();
  stdout.writeln(
    'Mengganti ${date.allMatches(text).length} `date` dan '
    '${dateTime.allMatches(text).length} `date-time` menjadi String.',
  );
  File(_derived)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      text
          .replaceAll(date, 'format: date-only')
          .replaceAll(dateTime, 'format: iso-datetime'),
    );
}
