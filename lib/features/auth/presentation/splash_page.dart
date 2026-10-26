import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/network/api_failure.dart';
import 'session_controller.dart';

/// Tampil saat sesi dipulihkan (`/me` saat start). Galat jaringan: coba lagi.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final session = ref.watch(sessionProvider);
    return AppScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoMark(size: 32, animate: true),
              const SizedBox(height: 20),
              Text(
                'eAbsensi',
                style: AppType.brand.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: 24),
              if (session.hasError) ...[
                Text(
                  session.error is ApiFailure
                      ? (session.error! as ApiFailure).message
                      : 'Terjadi kesalahan. Coba lagi.',
                  textAlign: TextAlign.center,
                  style: AppType.body.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 16),
                OutlineButton(
                  label: 'Coba lagi',
                  onPressed: () => ref.invalidate(sessionProvider),
                ),
              ] else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
