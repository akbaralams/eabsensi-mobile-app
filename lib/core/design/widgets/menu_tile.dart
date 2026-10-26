import 'package:flutter/material.dart';

import '../phosphor.dart';

import '../tokens.dart';

enum MenuTone { mint, teal, amber }

/// Tinggi sel grid menu; ikut membesar bersama ukuran teks sistem.
double menuTileExtent(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(11) / 11;
  return 104 + 34 * (scale < 1 ? 0 : scale - 1);
}

/// Tile menu beranda. Nonaktif = abu-abu, gembok, tidak bisa ditekan, dan
/// dibaca "nonaktif" oleh screen reader.
class MenuTile extends StatelessWidget {
  const MenuTile({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final MenuTone tone;
  final VoidCallback? onTap;
  final bool enabled;

  static const _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      MenuTone.mint => (c.mintTint, c.accent),
      MenuTone.teal => (
        c.tealTint,
        c.isDark ? c.teal : const Color(0xFF0D9488),
      ),
      MenuTone.amber => (c.amberTint, c.amberIcon),
    };
    final radius = BorderRadius.circular(AppRadius.tile);

    Widget content = Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: radius,
        boxShadow: c.tileShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.iconBox),
            ),
            child: Center(child: PhosphorIcon(icon, size: 22, color: fg)),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppType.micro.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );

    if (!enabled) {
      content = Opacity(
        opacity: .5,
        child: ColorFiltered(colorFilter: _grayscale, child: content),
      );
      return Semantics(
        label: '$label, nonaktif',
        enabled: false,
        button: true,
        excludeSemantics: true,
        child: Stack(
          children: [
            content,
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: c.textMuted,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIconsFill.lock,
                    size: 11,
                    color: c.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: radius, onTap: onTap, child: content),
      ),
    );
  }
}
