import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../domain/inbox.dart';
import 'inbox_providers.dart';

/// Pita pemberitahuan: layar ini memakai data contoh karena kontrak API belum
/// punya endpoint-nya (Task 10 menunggu kontrak).
class _SampleDataNote extends StatelessWidget {
  const _SampleDataNote();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(PhosphorIconsRegular.info, size: 18, color: c.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data contoh. Fitur ini menunggu kontrak API.',
              style: AppType.caption.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final items = ref.watch(notificationsProvider);
    return AppScaffold(
      body: Column(
        children: [
          const PageHeader(title: 'Notifikasi'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screenH,
                8,
                AppSpace.screenH,
                24,
              ),
              children: [
                const _SampleDataNote(),
                const SizedBox(height: AppSpace.block),
                items.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Text(
                    'Tidak dapat memuat notifikasi.',
                    style: AppType.body.copyWith(color: c.textMuted),
                  ),
                  data: (list) => Column(
                    children: [
                      for (final n in list) ...[
                        _NotificationTile(item: n),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, icon) = switch (item.tone) {
      MenuTone.mint => (c.mintTint, c.accent, PhosphorIconsFill.checkCircle),
      MenuTone.teal => (
        c.tealTint,
        c.isDark ? c.teal : const Color(0xFF0D9488),
        PhosphorIconsFill.bellRinging,
      ),
      MenuTone.amber => (
        c.amberTint,
        c.amberIcon,
        PhosphorIconsFill.hourglassMedium,
      ),
    };
    return Semantics(
      label: '${item.read ? '' : 'Belum dibaca. '}${item.title}. ${item.meta}',
      excludeSemantics: true,
      child: AppCard(
        secondary: true,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: PhosphorIcon(icon, size: 20, color: fg)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppType.body.copyWith(
                      color: c.textPrimary,
                      fontWeight: item.read ? FontWeight.w600 : FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.meta,
                    style: AppType.caption.copyWith(color: c.textMuted),
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

class ApprovalsPage extends ConsumerWidget {
  const ApprovalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final items = ref.watch(approvalsProvider);
    return AppScaffold(
      body: Column(
        children: [
          const PageHeader(title: 'Persetujuan Tim'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screenH,
                8,
                AppSpace.screenH,
                24,
              ),
              children: [
                const _SampleDataNote(),
                const SizedBox(height: AppSpace.block),
                items.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Text(
                    'Tidak dapat memuat persetujuan.',
                    style: AppType.body.copyWith(color: c.textMuted),
                  ),
                  data: (list) => list.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Semua pengajuan sudah ditanggapi.',
                            textAlign: TextAlign.center,
                            style: AppType.body.copyWith(color: c.textMuted),
                          ),
                        )
                      : Column(
                          children: [
                            for (final a in list) ...[
                              _ApprovalCard(request: a),
                              const SizedBox(height: AppSpace.block),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends ConsumerWidget {
  const _ApprovalCard({required this.request});

  final ApprovalRequest request;

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref, {
    required bool approve,
  }) async {
    await ref
        .read(inboxRepositoryProvider)
        .decide(request.id, approve: approve);
    ref.invalidate(approvalsProvider);
    if (!context.mounted) return;
    AppToast.show(
      context,
      approve ? 'Pengajuan disetujui' : 'Pengajuan ditolak',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return AppCard(
      key: Key('approval-${request.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: c.badgeGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  IdFormat.initials(request.requester),
                  semanticsLabel: '',
                  style: AppType.bodyBold.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.kind,
                      style: AppType.microBold.copyWith(color: c.amberText),
                    ),
                    Text(
                      request.requester,
                      style: AppType.cardTitle.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
              ),
              Text(
                request.whenLabel,
                style: AppType.micro.copyWith(color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.detail,
            style: AppType.caption.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Setujui',
                  height: 46,
                  onPressed: () => _decide(context, ref, approve: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlineButton(
                  label: 'Tolak',
                  height: 46,
                  onPressed: () => _decide(context, ref, approve: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
