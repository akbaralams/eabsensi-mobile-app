import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden dibangkitkan di Linux; render font di OS lain bergeser sedikit.
/// Selisih piksel sampai 0,5% dianggap sama.
class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const _tolerance = 0.005;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _tolerance) return true;
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}

/// Memuat semua font dari FontManifest (Plus Jakarta Sans, Phosphor, Material
/// Icons) supaya golden menampilkan teks dan ikon asli, bukan kotak Ahem.
Future<void> _loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest = json.decode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest) {
    final map = entry as Map<String, dynamic>;
    final loader = FontLoader(map['family'] as String);
    for (final font in map['fonts'] as List<dynamic>) {
      loader.addFont(
        rootBundle.load((font as Map<String, dynamic>)['asset'] as String),
      );
    }
    await loader.load();
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await _loadAppFonts();
  final current = goldenFileComparator;
  if (current is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(
      current.basedir.resolve('x.dart'),
    );
  }
  await testMain();
}
