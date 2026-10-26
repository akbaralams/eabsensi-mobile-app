import 'package:flutter/material.dart';

import '../tokens.dart';
import 'motion.dart';

/// Logo eAbsensi: 4 lingkaran dalam grid 2x2.
class LogoMark extends StatelessWidget {
  const LogoMark({this.size = 40, this.animate = false, super.key});

  /// Diameter satu lingkaran.
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget dot(Color base) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-.4, -.4),
          colors: [Colors.white.withValues(alpha: .55), base],
          stops: const [0, .75],
        ),
      ),
    );

    final gap = size / 10;
    final mark = Semantics(
      label: 'Logo eAbsensi',
      image: true,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              dot(c.mint400),
              SizedBox(width: gap),
              dot(c.teal),
            ],
          ),
          SizedBox(height: gap),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              dot(c.teal),
              SizedBox(width: gap),
              dot(c.primary),
            ],
          ),
        ],
      ),
    );
    return animate ? Floating(distance: 6, child: mark) : mark;
  }
}
