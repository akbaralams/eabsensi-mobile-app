import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../domain/punch.dart';
import 'punch_providers.dart';

/// Hasil: waktu dari respons server dan status (`approved` / `pending`).
class PunchResultPage extends ConsumerWidget {
  const PunchResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final flow = ref.watch(punchFlowProvider);
    final result = flow.result;
    if (result == null) {
      return const AppScaffold(body: SizedBox.shrink());
    }
    final pending = result.status == PunchStatus.pending;
    final target = flow.target;
    final heading = switch (target) {
      PunchTarget(:final kind) =>
        '${kind == PunchKind.checkIn ? 'Check In' : 'Check Out'} tercatat',
      EventTarget(:final event) => 'Check-in ${event.name} tercatat',
    };
    final (chipLabel, chipVariant) = switch (result.status) {
      PunchStatus.pending => ('Menunggu atasan', StatusVariant.pending),
      PunchStatus.rejected => ('Ditolak', StatusVariant.absent),
      PunchStatus.approved => ('Disetujui', StatusVariant.success),
      null => ('Tercatat', StatusVariant.success),
    };
    final message = pending
        ? 'Absenmu menunggu persetujuan atasan dan belum dihitung sebagai kehadiran sampai disetujui.'
        : 'Kehadiranmu sudah tercatat. Terima kasih!';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: AppScaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Floating(
                distance: 8,
                period: const Duration(seconds: 4),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: pending
                        ? const RadialGradient(
                            center: Alignment(-.3, -.3),
                            colors: [
                              Colors.white,
                              Color(0xFFFBBF24),
                              Color(0xFFD97706),
                            ],
                            stops: [0, .35, 1],
                          )
                        : const RadialGradient(
                            center: Alignment(-.3, -.3),
                            colors: [
                              Colors.white,
                              Color(0xFF34D399),
                              Color(0xFF059669),
                            ],
                            stops: [0, .35, 1],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (pending
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF059669))
                                .withValues(alpha: .35),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      pending
                          ? PhosphorIconsBold.hourglassMedium
                          : PhosphorIconsBold.check,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  '$heading · waktu server',
                  textAlign: TextAlign.center,
                  style: AppType.small.copyWith(color: c.textMuted),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                IdFormat.time(result.time),
                key: const Key('result-time'),
                style: AppType.resultTime.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                IdFormat.longDate(result.time),
                style: AppType.small.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: 14),
              StatusChip(label: chipLabel, variant: chipVariant, large: true),
              const SizedBox(height: 18),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppType.body.copyWith(color: c.textSecondary),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Kembali ke Beranda',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
