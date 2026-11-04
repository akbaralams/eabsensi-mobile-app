import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../domain/app_update.dart';
import 'update_providers.dart';

/// Lembar "Pembaruan tersedia": catatan rilis, unduhan dengan progres, dan
/// serah-terima ke pemasang Android (pengguna tetap mengetuk "Pasang").
Future<void> showUpdateSheet(BuildContext context, UpdateInfo info) {
  final c = context.colors;
  // Toast "Pembaruan tersedia" mengambang di atas tombol lembar: tutup dulu.
  ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: c.surface,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => UpdateSheet(info: info),
  );
}

class UpdateSheet extends ConsumerWidget {
  const UpdateSheet({required this.info, super.key});

  final UpdateInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final state = ref.watch(updateControllerProvider);
    final controller = ref.read(updateControllerProvider.notifier);
    final busy = state is UpdateDownloading;
    return PopScope(
      canPop: !busy,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Pembaruan tersedia',
                  style: AppType.title.copyWith(color: c.textPrimary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Versi ${info.versionName} (${info.versionCode})',
                key: const Key('update-version'),
                style: AppType.small.copyWith(color: c.textMuted),
              ),
              if (info.notes != null) ...[
                const SizedBox(height: 14),
                Text(
                  info.notes!,
                  key: const Key('update-notes'),
                  style: AppType.body.copyWith(color: c.textSecondary),
                ),
              ],
              const SizedBox(height: 18),
              switch (state) {
                UpdateDownloading(:final fraction) => _Progress(
                  fraction: fraction,
                  onCancel: controller.cancel,
                ),
                UpdateHandedOff() => _Message(
                  icon: PhosphorIconsFill.checkCircle,
                  color: c.accent,
                  text:
                      'Pemasang Android dibuka. Ketuk "Pasang" untuk '
                      'menyelesaikan pembaruan.',
                  action: OutlineButton(
                    label: 'Tutup',
                    onPressed: () {
                      controller.reset();
                      Navigator.pop(context);
                    },
                  ),
                ),
                UpdateFailed(:final message) => _Message(
                  icon: PhosphorIconsFill.warning,
                  color: c.errorText,
                  text: message,
                  action: PrimaryButton(
                    key: const Key('update-retry'),
                    label: 'Coba lagi',
                    onPressed: () => controller.start(info),
                  ),
                ),
                UpdateIdle() => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(
                      key: const Key('update-start'),
                      label: 'Perbarui sekarang',
                      icon: PhosphorIconsBold.arrowRight,
                      onPressed: () => controller.start(info),
                    ),
                    const SizedBox(height: 10),
                    OutlineButton(
                      label: 'Nanti',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.fraction, required this.onCancel});

  final double? fraction;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final percent = fraction == null ? null : (fraction! * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          label: percent == null
              ? 'Mengunduh pembaruan'
              : 'Mengunduh pembaruan, $percent persen',
          child: ExcludeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    percent == null ? 'Mengunduh…' : 'Mengunduh… $percent%',
                    key: const Key('update-progress-text'),
                    style: AppType.bodyBold.copyWith(color: c.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            color: c.accent,
            backgroundColor: c.mintTint,
          ),
        ),
        const SizedBox(height: 14),
        OutlineButton(label: 'Batal', onPressed: onCancel),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.color,
    required this.text,
    required this.action,
  });

  final IconData icon;
  final Color color;
  final String text;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhosphorIcon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  key: const Key('update-message'),
                  style: AppType.body.copyWith(color: c.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        action,
      ],
    );
  }
}
