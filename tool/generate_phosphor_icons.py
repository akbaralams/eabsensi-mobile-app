#!/usr/bin/env python3
"""Membangkitkan lib/core/design/phosphor.dart.

phosphor_flutter 2.1.0 (rilis terbaru) tidak bisa dikompilasi di Flutter 3.47:
kelasnya memperluas `IconData`, yang sekarang `final class`. Paket itu tetap
dipakai untuk berkas font-nya; skrip ini hanya menyalin kode titik ikon yang
dipakai aplikasi menjadi konstanta `IconData` biasa.

Pakai: python3 tool/generate_phosphor_icons.py
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'lib/core/design/phosphor.dart')
STYLES = {'Regular': 'regular', 'Fill': 'fill', 'Bold': 'bold'}

pkg = sorted(glob.glob(os.path.expanduser('~/.pub-cache/hosted/pub.dev/phosphor_flutter-*')))
if not pkg:
    sys.exit('phosphor_flutter belum ada di pub cache; jalankan flutter pub get')
src_dir = os.path.join(pkg[-1], 'lib/src')

used = {s: set() for s in STYLES}
for path in glob.glob(os.path.join(ROOT, 'lib/**/*.dart'), recursive=True):
    if path == OUT:
        continue
    text = open(path, encoding='utf-8').read()
    for style, name in re.findall(r'PhosphorIcons(Regular|Fill|Bold)\.(\w+)', text):
        used[style].add(name)

lines = [
    '// DIBANGKITKAN oleh tool/generate_phosphor_icons.py. Jangan diedit tangan.',
    '// Ikon Phosphor (MIT) memakai berkas font dari paket phosphor_flutter.',
    '',
    "import 'package:flutter/widgets.dart';",
    '',
    '/// Pengganti widget `PhosphorIcon` dari paket (yang tidak bisa dikompilasi).',
    'class PhosphorIcon extends StatelessWidget {',
    '  const PhosphorIcon(this.icon, {this.size, this.color, super.key});',
    '',
    '  final IconData icon;',
    '  final double? size;',
    '  final Color? color;',
    '',
    '  @override',
    '  Widget build(BuildContext context) =>',
    '      Icon(icon, size: size, color: color);',
    '}',
]
for style, fname in STYLES.items():
    code = open(os.path.join(src_dir, f'phosphor_icons_{fname}.dart'), encoding='utf-8').read()
    points = dict(re.findall(r"static const (\w+) = PhosphorFlatIconData\((0x[0-9a-fA-F]+), '%s'\)" % style, code))
    missing = sorted(n for n in used[style] if n not in points)
    if missing:
        sys.exit(f'Ikon {style} tidak ada di paket: {missing}')
    lines += ['', f'abstract final class PhosphorIcons{style} {{']
    for name in sorted(used[style]):
        lines.append(
            f"  static const {name} = IconData({points[name]}, fontFamily: 'Phosphor{style}', "
            "fontPackage: 'phosphor_flutter', matchTextDirection: true);"
        )
    lines.append('}')
open(OUT, 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
print('ditulis', OUT, {s: len(v) for s, v in used.items()})
