import 'package:flutter/material.dart';

import '../tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.card),
    this.secondary = false,
    this.color,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Kartu sekunder: radius 22 dan bayangan lebih tipis.
  final bool secondary;
  final Color? color;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(
      secondary ? AppRadius.cardSecondary : AppRadius.card,
    );
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: radius,
        boxShadow: secondary ? c.tileShadow : c.cardShadow,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return decorated;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: radius, onTap: onTap, child: decorated),
      ),
    );
  }
}
