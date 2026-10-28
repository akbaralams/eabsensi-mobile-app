import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../../../core/network/api_failure.dart';
import '../../punch/domain/punch.dart';
import '../../punch/presentation/punch_providers.dart';
import 'attendance_card.dart';
import 'attendance_summary.dart';
import 'home_page.dart' show StatusCard;

/// Tab Absensi: tujuan tersendiri (bukan aksi) berisi status hari ini, tombol
/// Check In/Out, dan daftar punch hari ini dari server.
class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final punches = ref.watch(todayPunchesProvider);
    final summary = punches.maybeWhen(
      data: AttendanceSummary.from,
      orElse: () => const AttendanceSummary(phase: DayPhase.none),
    );

    return Column(
      children: [
        const PageHeader(title: 'Absensi', showBack: false),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todayPunchesProvider);
              await ref
                  .read(todayPunchesProvider.future)
                  .catchError((_) => <Punch>[]);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screenH,
                8,
                AppSpace.screenH,
                AppSpace.contentBottom,
              ),
              children: [
                TickingAttendanceCard(
                  summary: summary,
                  loading: punches.isLoading && !punches.hasValue,
                  onCheckIn: () => context.push('/punch/in'),
                  onCheckOut: () => context.push('/punch/out'),
                ),
                const SizedBox(height: AppSpace.block),
                StatusCard(summary: summary),
                const SizedBox(height: 22),
                Semantics(
                  header: true,
                  child: Text(
                    'Punch hari ini',
                    style: AppType.cardTitle.copyWith(color: c.textPrimary),
                  ),
                ),
                const SizedBox(height: 10),
                punches.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Column(
                    children: [
                      Text(
                        e is ApiFailure ? e.message : 'Terjadi kesalahan.',
                        textAlign: TextAlign.center,
                        style: AppType.body.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      OutlineButton(
                        label: 'Coba lagi',
                        onPressed: () => ref.invalidate(todayPunchesProvider),
                      ),
                    ],
                  ),
                  data: (list) => list.isEmpty
                      ? Text(
                          'Belum ada punch hari ini.',
                          style: AppType.body.copyWith(color: c.textMuted),
                        )
                      : Column(
                          children: [
                            for (final p in list) ...[
                              _PunchTile(punch: p),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PunchTile extends StatelessWidget {
  const _PunchTile({required this.punch});

  final Punch punch;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (label, variant) = switch (punch.status) {
      PunchStatus.pending => ('Menunggu atasan', StatusVariant.pending),
      PunchStatus.approved => ('Disetujui', StatusVariant.success),
      PunchStatus.rejected => ('Ditolak', StatusVariant.absent),
    };
    return AppCard(
      secondary: true,
      padding: const EdgeInsets.all(14),
      child: Semantics(
        label:
            'Punch pukul ${IdFormat.time(punch.punchedAt)}, $label, ${punch.hasPhoto ? 'dengan foto' : 'tanpa foto'}',
        excludeSemantics: true,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    IdFormat.time(punch.punchedAt),
                    style: AppType.header.copyWith(
                      color: c.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    punch.hasPhoto ? 'Dengan foto' : 'Tanpa foto',
                    style: AppType.caption.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
            StatusChip(label: label, variant: variant),
          ],
        ),
      ),
    );
  }
}
