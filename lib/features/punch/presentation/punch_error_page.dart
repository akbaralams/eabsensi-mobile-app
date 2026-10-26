import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/network/api_failure.dart';
import 'punch_actions.dart';
import 'punch_providers.dart';

/// Galat absen. Offline: tanpa antrean. 422 aturan: pesan server apa adanya.
class PunchErrorPage extends ConsumerWidget {
  const PunchErrorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final flow = ref.watch(punchFlowProvider);
    final failure = flow.failure;

    final (title, message, icon) = switch (failure) {
      OfflineFailure() => (
        'Tidak ada koneksi',
        failure.message,
        PhosphorIconsFill.wifiSlash,
      ),
      ValidationFailure(:final errors, :final message) => (
        'Data belum lengkap',
        errors.values.expand((v) => v).isEmpty
            ? message
            : errors.values.expand((v) => v).join('\n'),
        PhosphorIconsFill.warning,
      ),
      ApiFailure(:final message) => (
        'Belum bisa dicatat',
        message,
        PhosphorIconsFill.warning,
      ),
      _ => (
        'Terjadi kesalahan',
        'Coba lagi beberapa saat lagi.',
        PhosphorIconsFill.warning,
      ),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: AppScaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenH),
          child: Column(
            children: [
              const Spacer(),
              AppCard(
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: c.amberTint,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: PhosphorIcon(icon, size: 24, color: c.amberIcon),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppType.title.copyWith(
                          color: c.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      key: const Key('error-message'),
                      textAlign: TextAlign.center,
                      style: AppType.body.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    OutlineButton(
                      label: 'Coba lagi',
                      icon: PhosphorIconsRegular.arrowClockwise,
                      onPressed: () => submitAndShowOutcome(context, ref),
                    ),
                  ],
                ),
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
