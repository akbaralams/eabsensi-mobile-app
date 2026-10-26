import 'package:eabsensi/core/design/tokens.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/contrast.dart';

/// Pasangan (teks, latar) yang benar-benar dipakai widget bersama.
List<(String, Color, Color)> _textPairs(AppColors c) {
  final amberOnSurface = over(c.amberTint, c.surface);
  final errorOnSurface = over(c.errorTint, c.surface);
  final amberSoft = over(c.amberSoft, c.surface);
  final errorSoft = over(c.errorSoft, c.surface);
  final tileHadir = c.isDark ? c.successTint : const Color(0xFFECFDF5);
  return [
    ('textPrimary/surface', c.textPrimary, c.surface),
    ('textSecondary/surface', c.textSecondary, c.surface),
    ('textMuted/surface', c.textMuted, c.surface),
    ('textMuted/surfaceAlt', c.textMuted, c.surfaceAlt),
    ('textPrimary/surfaceAlt', c.textPrimary, c.surfaceAlt),
    ('textMuted/backgroundTop', c.textMuted, c.backgroundTop),
    ('textMuted/backgroundBottom', c.textMuted, c.backgroundBottom),
    ('textPrimary/backgroundTop', c.textPrimary, c.backgroundTop),
    ('accentText/surface', c.accentText, c.surface),
    ('accentText/surfaceAlt', c.accentText, c.surfaceAlt),
    ('onGradient/gradientStart', c.onGradient, c.gradientStart),
    ('onGradient/gradientEnd', c.onGradient, c.gradientEnd),
    ('chip sukses', c.successText, c.successTint),
    ('chip terlambat/menunggu', c.amberText, amberOnSurface),
    ('chip tidak hadir', c.errorText, errorOnSurface),
    ('chip netral', c.textMuted, c.rowDivider),
    ('errorText/surface', c.errorText, c.surface),
    ('kotak aturan', c.amberText, amberOnSurface),
    ('tile Hadir', c.accentText, tileHadir),
    ('tile Terlambat', c.amberText, amberSoft),
    ('tile Tidak Hadir', c.errorStrong, errorSoft),
    ('label tile statistik', c.textSecondary, tileHadir),
    ('banner event (mint)', c.textSecondary, c.mintTint),
    ('banner event (teal)', c.textSecondary, c.tealTint),
    ('judul banner', c.textPrimary, c.mintTint),
    ('toast', c.toastText, c.toastBackground),
  ];
}

void main() {
  for (final (name, c) in [
    ('terang', AppColors.light),
    ('gelap', AppColors.dark),
  ]) {
    test('kontras teks >= 4.5:1 (mode $name)', () {
      final failures = <String>[];
      for (final (label, fg, bg) in _textPairs(c)) {
        final ratio = contrast(fg, bg);
        if (ratio < 4.5) failures.add('$label = ${ratio.toStringAsFixed(2)}');
      }
      expect(failures, isEmpty, reason: failures.join('; '));
    });

    test('kontras ikon dan border berarti >= 3:1 (mode $name)', () {
      final pairs = <(String, Color, Color)>[
        ('ikon aksen/tint mint', c.accent, c.mintTint),
        ('ikon amber/tint amber', c.amberIcon, over(c.amberTint, c.surface)),
        (
          'ikon teal/tint teal',
          c.isDark ? c.teal : const Color(0xFF0D9488),
          c.tealTint,
        ),
        ('ikon muted/surface', c.textMuted, c.surface),
        ('ikon aksen/surface', c.accent, c.surface),
      ];
      final failures = [
        for (final (label, fg, bg) in pairs)
          if (contrast(fg, bg) < 3)
            '$label = ${contrast(fg, bg).toStringAsFixed(2)}',
      ];
      expect(failures, isEmpty, reason: failures.join('; '));
    });
  }
}
