// Salin kontrak OpenAPI dari repo API ke `api/openapi.yaml` dan catat asalnya
// di `api/CONTRACT_VERSION`, agar build tidak bergantung pada folder tetangga.
//
//   dart run tool/sync_contract.dart [path-repo-api]
//
// Default path repo API: `../eabsensi-mobile-api` relatif terhadap checkout
// utama aplikasi (bekerja juga dari worktree `.claude/worktrees/*`).
// Setelah sinkron, bangkitkan ulang client: `dart run tool/generate_api.dart`.
import 'dart:io';

Future<void> main(List<String> args) async {
  final apiRepo = args.isNotEmpty ? Directory(args.first) : _findApiRepo();
  if (apiRepo == null || !apiRepo.existsSync()) {
    stderr.writeln(
      'Repo eabsensi-mobile-api tidak ditemukan. '
      'Berikan path-nya: dart run tool/sync_contract.dart <path>',
    );
    exit(64);
  }
  final source = File('${apiRepo.path}/docs/openapi.yaml');
  if (!source.existsSync()) {
    stderr.writeln('Tidak ada ${source.path}');
    exit(66);
  }

  Future<String> git(List<String> a) async {
    final r = await Process.run('git', ['-C', apiRepo.path, ...a]);
    if (r.exitCode != 0) throw ProcessException('git', a, '${r.stderr}');
    return (r.stdout as String).trim();
  }

  final head = await git(['rev-parse', 'HEAD']);
  final last = await git([
    'log',
    '-1',
    '--format=%H %cs %s',
    '--',
    'docs/openapi.yaml',
  ]);
  final dirty = (await git([
    'status',
    '--porcelain',
    '--',
    'docs/openapi.yaml',
  ])).isNotEmpty;
  if (dirty) {
    stderr.writeln(
      'Peringatan: docs/openapi.yaml di repo API punya perubahan belum di-commit; '
      'CONTRACT_VERSION menandainya "dirty".',
    );
  }

  Directory('api').createSync();
  source.copySync('api/openapi.yaml');
  File('api/CONTRACT_VERSION').writeAsStringSync(
    [
      '# Asal api/openapi.yaml. Diperbarui oleh tool/sync_contract.dart; jangan edit tangan.',
      'repo: eabsensi-mobile-api',
      'file: docs/openapi.yaml',
      'head: $head${dirty ? ' (dirty)' : ''}',
      'last_change: $last',
      '',
    ].join('\n'),
  );
  stdout.writeln('api/openapi.yaml disalin dari ${source.path} @ $head');
}

Directory? _findApiRepo() {
  var dir = Directory.current.absolute;
  // Naik sampai menemukan folder tetangga `eabsensi-mobile-api`.
  for (var i = 0; i < 6; i++) {
    final candidate = Directory('${dir.parent.path}/eabsensi-mobile-api');
    if (candidate.existsSync()) return candidate;
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}
