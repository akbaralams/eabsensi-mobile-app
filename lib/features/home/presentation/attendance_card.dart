import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import 'attendance_summary.dart';

/// Kartu absen: hero jam, Masuk/Keluar, tombol Check In / Check Out.
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    required this.now,
    required this.summary,
    required this.loading,
    required this.onCheckIn,
    required this.onCheckOut,
    super.key,
  });

  final DateTime now;
  final AttendanceSummary summary;
  final bool loading;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        children: [
          _Hero(now: now, summary: summary, loading: loading),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _TimeCell(
                    icon: PhosphorIconsRegular.signIn,
                    iconBg: c.mintTint,
                    label: 'Masuk',
                    time: summary.checkIn,
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: c.divider),
                Expanded(
                  child: _TimeCell(
                    icon: PhosphorIconsRegular.signOut,
                    iconBg: c.surfaceAlt,
                    label: 'Keluar',
                    time: summary.checkOut,
                    padLeft: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Check In',
                  icon: PhosphorIconsRegular.signIn,
                  primary: !summary.nextIsCheckOut,
                  onTap: onCheckIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Check Out',
                  icon: PhosphorIconsRegular.signOut,
                  primary: summary.nextIsCheckOut,
                  onTap: onCheckOut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.now,
    required this.summary,
    required this.loading,
  });

  final DateTime now;
  final AttendanceSummary summary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (label, variant) = loading
        ? ('Memuat…', StatusVariant.neutral)
        : switch (summary.phase) {
            DayPhase.none => ('Belum Check In', StatusVariant.neutral),
            DayPhase.checkedIn => ('Sudah Check In', StatusVariant.success),
            DayPhase.pending => ('Menunggu persetujuan', StatusVariant.pending),
            DayPhase.checkedOut => ('Sudah Check Out', StatusVariant.success),
          };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: c.surfaceAlt,
        gradient: RadialGradient(
          center: const Alignment(.9, -.4),
          radius: .9,
          colors: [c.blobMint, c.blobMint.withValues(alpha: 0)],
          stops: const [0, .7],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  IdFormat.longDate(now),
                  style: AppType.small.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: 2),
                Semantics(
                  label: 'Pukul ${IdFormat.time(now)}',
                  excludeSemantics: true,
                  child: Text(
                    IdFormat.time(now),
                    key: const Key('hero-clock'),
                    style: AppType.clock.copyWith(color: c.textPrimary),
                  ),
                ),
                const SizedBox(height: 8),
                StatusChip(label: label, variant: variant, large: true),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Floating(
            child: Transform.rotate(
              angle: -8 * 3.1415926 / 180,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  gradient: c.badgeGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: .3),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsRegular.clock,
                        size: 34,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.time,
    this.padLeft = 0,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final DateTime? time;
  final double padLeft;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = time == null ? '-' : IdFormat.time(time!);
    return Padding(
      padding: EdgeInsets.only(left: padLeft),
      child: Semantics(
        label: '$label ${time == null ? 'belum ada' : value}',
        excludeSemantics: true,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: PhosphorIcon(icon, size: 20, color: c.accent),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppType.caption.copyWith(color: c.textMuted),
                  ),
                  Text(
                    value,
                    style: AppType.cardTitle.copyWith(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = primary ? c.onGradient : c.textPrimary;
    final radius = BorderRadius.circular(18);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: primary ? c.primaryGradient : null,
          color: primary ? null : c.surfaceAlt,
          borderRadius: radius,
          boxShadow: primary ? c.buttonShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: SizedBox(
              height: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(icon, size: 22, color: fg),
                  const SizedBox(height: 4),
                  Text(label, style: AppType.bodyBold.copyWith(color: fg)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
