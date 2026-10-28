import 'package:flutter/material.dart';

import '../phosphor.dart';

import '../tokens.dart';

enum StatusVariant { success, late, pending, absent, neutral }

/// Chip status. Selalu ikon + teks (status tidak hanya lewat warna).
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.variant,
    this.icon,
    this.large = false,
    super.key,
  });

  final String label;
  final StatusVariant variant;
  final IconData? icon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, defaultIcon) = switch (variant) {
      StatusVariant.success => (
        c.successTint,
        c.successText,
        PhosphorIconsFill.checkCircle,
      ),
      StatusVariant.late => (
        c.amberTint,
        c.amberText,
        PhosphorIconsFill.clockCountdown,
      ),
      StatusVariant.pending => (
        c.amberTint,
        c.amberText,
        PhosphorIconsFill.hourglassMedium,
      ),
      StatusVariant.absent => (
        c.errorTint,
        c.errorText,
        PhosphorIconsFill.xCircle,
      ),
      StatusVariant.neutral => (
        c.rowDivider,
        c.textMuted,
        PhosphorIconsFill.minusCircle,
      ),
    };
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 12 : 9,
          vertical: large ? 6 : 4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(icon ?? defaultIcon, size: large ? 14 : 12, color: fg),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: (large ? AppType.captionBold : AppType.microBold)
                    .copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
