import 'package:flutter/material.dart';

import '../tokens.dart';

class SegmentItem<T> {
  const SegmentItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// Segmented berbentuk pil. `gradient: true` = segmen aktif bergradien (kategori
/// cuti); selain itu segmen aktif putih dengan bayangan (Login/SSO).
/// Pada teks sistem besar (> 1,3x) segmen disusun 2 kolom dan labelnya boleh
/// membungkus, supaya tidak terpotong menjadi "Din…".
class PillSegmented<T> extends StatelessWidget {
  const PillSegmented({
    required this.items,
    required this.value,
    required this.onChanged,
    this.gradient = false,
    super.key,
  });

  final List<SegmentItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final large = MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.segmentTrack),
      ),
      child: large
          ? LayoutBuilder(
              builder: (context, box) {
                final width = (box.maxWidth - 4) / 2;
                return Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: _segment(context, item, wrap: true),
                      ),
                  ],
                );
              },
            )
          : Row(
              children: [
                for (final item in items)
                  Expanded(child: _segment(context, item)),
              ],
            ),
    );
  }

  Widget _segment(
    BuildContext context,
    SegmentItem<T> item, {
    bool wrap = false,
  }) {
    final c = context.colors;
    final selected = item.value == value;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(item.value),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: AppSpace.minTouch),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: _decoration(c, selected),
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: wrap ? 3 : 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.captionBold.copyWith(color: _textColor(c, selected)),
          ),
        ),
      ),
    );
  }

  BoxDecoration? _decoration(AppColors c, bool active) {
    if (!active) return null;
    final radius = BorderRadius.circular(AppRadius.segment);
    if (gradient) {
      return BoxDecoration(gradient: c.primaryGradient, borderRadius: radius);
    }
    return BoxDecoration(
      color: c.surface,
      borderRadius: radius,
      boxShadow: [
        BoxShadow(
          color: c.shadow.withValues(alpha: c.isDark ? .3 : .1),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Color _textColor(AppColors c, bool active) {
    if (!active) return c.textMuted;
    return gradient ? c.onGradient : c.accentText;
  }
}
