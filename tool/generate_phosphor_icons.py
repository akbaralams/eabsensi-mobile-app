#!/usr/bin/env python3
"""Membangkitkan lib/core/design/phosphor.dart.

phosphor_flutter 2.1.0 (rilis terbaru) tidak bisa dikompilasi di Flutter 3.47:
kelasnya memperluas `IconData`, yang sekarang `final class`. Paket itu tetap
dipakai untuk berkas font-nya; skrip ini hanya menyalin kode titik ikon yang
dipakai aplikasi menjadi konstanta `IconData` biasa. Gaya Duotone terdiri dari
dua glyph (garis utama dan lapisan isi), jadi dibangkitkan sebagai
`DuotoneIconData` yang digambar oleh `PhosphorDuotoneIcon`.

Pakai: python3 tool/generate_phosphor_icons.py
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'lib/core/design/phosphor.dart')
STYLES = {'Regular': 'regular', 'Fill': 'fill', 'Bold': 'bold'}

caches = [
    os.environ.get('PUB_CACHE', ''),
    os.path.expanduser('~/.pub-cache'),
    os.path.join(os.environ.get('LOCALAPPDATA', ''), 'Pub', 'Cache'),
]
pkg = sorted(
    p for c in caches if c
    for p in glob.glob(os.path.join(c, 'hosted/pub.dev/phosphor_flutter-*'))
)
if not pkg:
    sys.exit('phosphor_flutter belum ada di pub cache; jalankan flutter pub get')
src_dir = os.path.join(pkg[-1], 'lib/src')

used = {s: set() for s in [*STYLES, 'Duotone']}
for path in glob.glob(os.path.join(ROOT, 'lib/**/*.dart'), recursive=True):
    if path == OUT:
        continue
    text = open(path, encoding='utf-8').read()
    for style, name in re.findall(r'PhosphorIcons(Regular|Fill|Bold|Duotone)\.(\w+)', text):
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
    '',
    '/// Ikon Duotone: glyph garis utama dan lapisan isi.',
    'final class DuotoneIconData {',
    '  const DuotoneIconData(this.main, this.secondary);',
    '',
    '  final IconData main;',
    '  final IconData secondary;',
    '}',
    '',
    '/// Satu warna untuk dua lapis: isi digambar dengan [secondaryOpacity]',
    '/// (bawaan Phosphor 20%), jadi tetap satu aksen.',
    'class PhosphorDuotoneIcon extends StatelessWidget {',
    '  const PhosphorDuotoneIcon(',
    '    this.icon, {',
    '    this.size,',
    '    this.color,',
    '    this.secondaryOpacity = .2,',
    '    super.key,',
    '  });',
    '',
    '  final DuotoneIconData icon;',
    '  final double? size;',
    '  final Color? color;',
    '  final double secondaryOpacity;',
    '',
    '  @override',
    '  Widget build(BuildContext context) => Stack(',
    '    alignment: Alignment.center,',
    '    children: [',
    '      Opacity(',
    '        opacity: secondaryOpacity,',
    '        child: Icon(icon.secondary, size: size, color: color),',
    '      ),',
    '      Icon(icon.main, size: size, color: color),',
    '    ],',
    '  );',
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

duo_code = open(os.path.join(src_dir, 'phosphor_icons_duotone.dart'), encoding='utf-8').read()
duo = {
    name: (main, sec)
    for name, main, sec in re.findall(
        r"static const (\w+) = PhosphorDuotoneIconData\(\s*(0x[0-9a-fA-F]+),\s*"
        r"PhosphorIconData\((0x[0-9a-fA-F]+), 'Duotone'\)",
        duo_code,
    )
}
missing = sorted(n for n in used['Duotone'] if n not in duo)
if missing:
    sys.exit(f'Ikon Duotone tidak ada di paket: {missing}')
if used['Duotone']:
    glyph = ("IconData(%s, fontFamily: 'PhosphorDuotone', "
             "fontPackage: 'phosphor_flutter', matchTextDirection: true)")
    lines += ['', 'abstract final class PhosphorIconsDuotone {']
    for name in sorted(used['Duotone']):
        main, sec = duo[name]
        lines.append(f'  static const {name} = DuotoneIconData({glyph % main}, {glyph % sec});')
    lines.append('}')
open(OUT, 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
print('ditulis', OUT, {s: len(v) for s, v in used.items()})
