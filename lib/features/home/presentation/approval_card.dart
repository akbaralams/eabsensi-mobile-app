import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../inbox/domain/inbox.dart';

/// Kartu "Menunggu Persetujuan" untuk atasan: lencana jumlah, rincian per
/// kategori, dan ajakan "Tinjau". Tanpa antrean tampil tenang, tanpa lencana.
class ApprovalCard extends StatelessWidget {
  const ApprovalCard({required this.approvals, required this.onTap, super.key});

  final List<ApprovalRequest> approvals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = approvals.length;
    final radius = BorderRadius.circular(AppRadius.cardSecondary);

    if (total == 0) {
      return AppCard(
        secondary: true,
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        semanticLabel: 'Tidak ada persetujuan tertunda. Buka persetujuan tim',
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIconsFill.checkCircle,
              size: 22,
              color: c.accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tidak ada persetujuan tertunda',
                style: AppType.bodyBold.copyWith(color: c.textPrimary),
              ),
            ),
            PhosphorIcon(
              PhosphorIconsBold.caretRight,
              size: 18,
              color: c.textMuted,
            ),
          ],
        ),
      );
    }

    final byCategory = <ApprovalCategory, int>{};
    for (final a in approvals) {
      byCategory[a.category] = (byCategory[a.category] ?? 0) + 1;
    }
    final spoken = [
      for (final e in byCategory.entries) '${e.value} ${e.key.label}',
    ].join(', ');

    return Semantics(
      button: true,
      label: '$total menunggu persetujuanmu: $spoken. Tinjau persetujuan tim',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.amberTint,
              borderRadius: radius,
              border: Border.all(color: c.amberIcon.withValues(alpha: .35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.iconBox),
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.stamp,
                      size: 22,
                      color: c.amberIcon,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Menunggu Persetujuan',
                              style: AppType.cardTitle.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CountBadge(count: total),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final e in byCategory.entries)
                            _CategoryChip(category: e.key, count: e.value),
                          const _ReviewPill(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.amberText,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        '$count',
        style: AppType.captionBold.copyWith(color: c.surface),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.count});

  final ApprovalCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(category.icon, size: 12, color: c.amberIcon),
          const SizedBox(width: 5),
          Text(
            '${category.label} · $count',
            style: AppType.microBold.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Tinjau', style: AppType.captionBold.copyWith(color: c.amberText)),
        const SizedBox(width: 2),
        PhosphorIcon(
          PhosphorIconsBold.caretRight,
          size: 14,
          color: c.amberText,
        ),
      ],
    );
  }
}
