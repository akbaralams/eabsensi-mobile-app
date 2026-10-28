import 'dart:math' as math;

import 'package:flutter/painting.dart';

double _channel(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

double luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

/// Menumpuk [fg] (boleh transparan) di atas [bg] yang buram.
Color over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

/// Rasio kontras WCAG 2.x antara dua warna buram.
double contrast(Color a, Color b) {
  final la = luminance(a);
  final lb = luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}
