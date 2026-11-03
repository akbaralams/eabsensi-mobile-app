import 'package:flutter/material.dart';

import '../phosphor.dart';

import '../tokens.dart';

enum MenuTone { mint, teal, amber }

const double _iconBox = 44;
const double _padTop = 12;
const double _padBottom = 8;
const double _gap = 8;

/// Tinggi area label: selalu dua baris (mengikuti ukuran teks sistem) supaya
/// ikon semua tile sejajar walau labelnya satu atau dua baris.
double _labelHeight(BuildContext context) {
  final size = AppType.micro.fontSize ?? 11;
  return MediaQuery.textScalerOf(context).scale(size) * 1.25 * 2;
}

/// Tinggi sel grid menu; ikut membesar bersama ukuran teks sistem.
double menuTileExtent(BuildContext context) =>
    _padTop + _iconBox + _gap + _labelHeight(context) + _padBottom;

/// Tile menu beranda dengan ukuran, padding, dan ikon yang sama untuk semua.
/// Nonaktif: ikon diredupkan dan abu-abu, label memakai warna redup yang tetap
/// terbaca, gembok di sudut kotak ikon, tidak bisa ditekan, dan dibaca
/// "nonaktif" oleh screen reader (status tidak hanya lewat warna).
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
      MenuTone.teal => (c.tealTint, c.tealIcon),
      MenuTone.amber => (c.amberTint, c.amberIcon),
    };
    final radius = BorderRadius.circular(AppRadius.tile);

    Widget box = Container(
      width: _iconBox,
      height: _iconBox,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.iconBox),
      ),
      child: Center(child: PhosphorIcon(icon, size: 22, color: fg)),
    );
    if (!enabled) {
      box = Opacity(
        opacity: .55,
        child: ColorFiltered(colorFilter: _grayscale, child: box),
      );
      box = Stack(
        clipBehavior: Clip.none,
        children: [
          box,
          Positioned(right: -5, bottom: -5, child: _LockBadge(colors: c)),
        ],
      );
    }

    final content = Container(
      padding: const EdgeInsets.fromLTRB(4, _padTop, 4, _padBottom),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: radius,
        boxShadow: c.tileShadow,
      ),
      child: Column(
        children: [
          box,
          const SizedBox(height: _gap),
          SizedBox(
            height: _labelHeight(context),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppType.micro.copyWith(
                  height: 1.25,
                  color: enabled ? c.textPrimary : c.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!enabled) {
      return Semantics(
        label: '$label, nonaktif',
        enabled: false,
        button: true,
        excludeSemantics: true,
        child: content,
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

class _LockBadge extends StatelessWidget {
  const _LockBadge({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: colors.textMuted,
        shape: BoxShape.circle,
        border: Border.all(color: colors.surface, width: 2),
      ),
      child: Center(
        child: PhosphorIcon(
          PhosphorIconsFill.lock,
          size: 10,
          color: colors.surface,
        ),
      ),
    );
  }
}
