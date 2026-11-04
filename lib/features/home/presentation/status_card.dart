import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock/clock.dart';
import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../../punch/presentation/punch_providers.dart';
import 'attendance_summary.dart';

/// Kartu "Status Kehadiran Hari Ini" di beranda. Jamnya berdetak sendiri
/// supaya hanya kartu ini yang dibangun ulang.
class StatusCard extends ConsumerWidget {
  const StatusCard({required this.summary, super.key});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref
        .watch(tickingClockProvider)
        .maybeWhen(data: (d) => d, orElse: () => ref.read(clockProvider)());
    return AttendanceStatusCard(
      summary: summary,
      now: now,
      locationName: ref.watch(officeAreaProvider)?.name,
    );
  }
}

/// Isi kartu: judul dan status (lokasi di bawah judul), lalu Masuk, Keluar,
/// dan Durasi kerja sebaris.
/// [locationName] `null` (kontrak belum punya lokasi kerja) menyembunyikan sel
/// Lokasi, bukan menampilkan tanda strip.
class AttendanceStatusCard extends StatelessWidget {
  const AttendanceStatusCard({
    required this.summary,
    required this.now,
    this.locationName,
    super.key,
  });

  final AttendanceSummary summary;
  final DateTime now;
  final String? locationName;

  static (String, StatusVariant) statusOf(AttendanceState state) =>
      switch (state) {
        AttendanceState.notYet => ('Belum Absen', StatusVariant.neutral),
        AttendanceState.checkedIn => ('Sudah Check In', StatusVariant.success),
        AttendanceState.checkedOut => (
          'Sudah Check Out',
          StatusVariant.success,
        ),
        AttendanceState.pending => ('Menunggu atasan', StatusVariant.pending),
        AttendanceState.late => ('Terlambat', StatusVariant.late),
        AttendanceState.absent => ('Tidak Hadir', StatusVariant.absent),
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final large = MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3;
    final (label, variant) = statusOf(summary.state);

    final checkIn = summary.checkIn;
    final checkOut = summary.checkOut;
    final running = checkIn != null && checkOut == null;
    final d = summary.workDuration(now);
    final hasWork = checkIn != null;

    final timeRow = [
      _StatCell(
        icon: PhosphorIconsRegular.signIn,
        label: 'Masuk',
        value: checkIn == null ? '-' : IdFormat.time(checkIn),
        spoken: checkIn == null ? 'belum ada' : IdFormat.time(checkIn),
      ),
      _StatCell(
        icon: PhosphorIconsRegular.signOut,
        label: 'Keluar',
        value: checkOut == null ? '-' : IdFormat.time(checkOut),
        spoken: checkOut == null ? 'belum ada' : IdFormat.time(checkOut),
      ),
      _StatCell(
        icon: PhosphorIconsRegular.timer,
        label: 'Durasi',
        value: hasWork ? '${d.inHours}j ${d.inMinutes % 60}m' : '-',
        spoken: hasWork
            ? 'kerja ${d.inHours} jam ${d.inMinutes % 60} menit'
                  '${running ? ', masih berjalan' : ''}'
            : 'kerja belum ada',
      ),
    ];
    final title = Semantics(
      header: true,
      child: Text(
        'Status Kehadiran Hari Ini',
        style: AppType.cardTitle.copyWith(color: c.textPrimary),
      ),
    );
    // Lokasi adalah konteks, bukan angka: satu baris di bawah judul.
    final place = locationName == null
        ? null
        : Semantics(
            label: 'Lokasi $locationName',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsRegular.mapPin,
                    size: 14,
                    color: c.accent,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      locationName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.caption.copyWith(color: c.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          );
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, ?place],
    );

    return AppCard(
      secondary: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (large)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: 8),
                StateSwitcher(
                  id: label,
                  child: StatusChip(label: label, variant: variant),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: heading),
                const SizedBox(width: 8),
                StateSwitcher(
                  id: label,
                  child: StatusChip(label: label, variant: variant),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (large)
            for (final (i, cell) in timeRow.indexed) ...[
              if (i > 0) const SizedBox(height: 8),
              cell,
            ]
          else ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, cell) in timeRow.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: cell),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.spoken,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Teks untuk pembaca layar.
  final String spoken;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$label $spoken',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PhosphorIcon(icon, size: 15, color: c.accent),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.caption.copyWith(color: c.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.cardTitle.copyWith(
                color: c.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
