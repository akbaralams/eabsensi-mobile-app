import 'package:flutter/material.dart';

import '../phosphor.dart';

import '../tokens.dart';

/// Tombol ikon bulat 46 (area sentuh 48) dengan dot notifikasi opsional.
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.showBadge = false,
    this.iconSize = 20,
    this.background,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final bool showBadge;
  final double iconSize;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: AppSpace.minTouch,
        height: AppSpace.minTouch,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Ink(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: background ?? c.surface,
                  shape: BoxShape.circle,
                  boxShadow: c.circleShadow,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PhosphorIcon(icon, size: iconSize, color: c.textPrimary),
                    if (showBadge)
                      Positioned(
                        top: 11,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.surface, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
