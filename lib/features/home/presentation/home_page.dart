import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/clock/clock.dart';
import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../../auth/presentation/session_controller.dart';
import '../../events/domain/event_item.dart';
import '../../events/presentation/event_providers.dart';
import '../../inbox/presentation/inbox_providers.dart';
import '../../menus/domain/menu_item.dart';
import '../../menus/presentation/menu_providers.dart';
import '../../punch/presentation/punch_providers.dart';
import 'attendance_card.dart';
import 'attendance_summary.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(sessionProvider).value;
    final now = ref
        .watch(tickingClockProvider)
        .maybeWhen(data: (d) => d, orElse: () => ref.read(clockProvider)());
    final punches = ref.watch(todayPunchesProvider);
    final summary = punches.maybeWhen(
      data: AttendanceSummary.from,
      orElse: () => const AttendanceSummary(phase: DayPhase.none),
    );
    final events = ref.watch(eventsTodayProvider).value ?? const <EventItem>[];
    final nextEvent = events.where((e) => !e.checkedIn).firstOrNull;
    final approvals = ref.watch(approvalsProvider).value;

    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(todayPunchesProvider)
          ..invalidate(eventsTodayProvider);
        await ref
            .read(todayPunchesProvider.future)
            .catchError((_) => <Never>[]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screenH,
          6,
          AppSpace.screenH,
          AppSpace.contentBottom,
        ),
        children: [
          FadeSlideIn(
            child: _Header(
              now: now,
              name: profile?.name ?? '',
              onBell: () => context.push('/notifications'),
            ),
          ),
          const SizedBox(height: AppSpace.block),
          if (punches.hasError) ...[
            _LoadError(
              message: _errorText(punches.error),
              onRetry: () => ref.invalidate(todayPunchesProvider),
            ),
            const SizedBox(height: AppSpace.block),
          ],
          FadeSlideIn(
            delay: const Duration(milliseconds: 40),
            child: AttendanceCard(
              now: now,
              summary: summary,
              loading: punches.isLoading && !punches.hasValue,
              onCheckIn: () => context.push('/punch/in'),
              onCheckOut: () => context.push('/punch/out'),
            ),
          ),
          const SizedBox(height: AppSpace.block),
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: _StatusCard(now: now, summary: summary),
          ),
          const SizedBox(height: AppSpace.block),
          const FadeSlideIn(
            delay: Duration(milliseconds: 120),
            child: _MenuGrid(),
          ),
          if (nextEvent != null) ...[
            const SizedBox(height: AppSpace.block),
            _EventBanner(
              event: nextEvent,
              total: events.length,
              onTap: () => context.push('/events'),
            ),
          ],
          if (profile?.isSupervisor ?? false) ...[
            const SizedBox(height: AppSpace.block),
            _ApprovalCard(
              count: approvals?.length ?? 0,
              onTap: () => context.push('/approvals'),
            ),
          ],
        ],
      ),
    );
  }

  static String _errorText(Object? e) => e is Exception
      ? e.toString().replaceFirst(RegExp(r'^\w+: '), '')
      : 'Terjadi kesalahan.';
}

class _Header extends StatelessWidget {
  const _Header({required this.now, required this.name, required this.onBell});

  final DateTime now;
  final String name;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        const LogoMark(size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                IdFormat.greeting(now),
                style: AppType.caption.copyWith(color: c.textMuted),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.header.copyWith(color: c.textPrimary),
              ),
              Text(
                'Tetap semangat hari ini!',
                style: AppType.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
        IconCircleButton(
          icon: PhosphorIconsRegular.bell,
          semanticLabel: 'Notifikasi, ada pesan baru',
          showBadge: true,
          onPressed: onBell,
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.amberTint,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Row(
          children: [
            PhosphorIcon(
              PhosphorIconsFill.warning,
              size: 18,
              color: c.amberIcon,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppType.caption.copyWith(color: c.amberText),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                minimumSize: const Size(AppSpace.minTouch, AppSpace.minTouch),
                foregroundColor: c.amberText,
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard({required this.now, required this.summary});

  final DateTime now;
  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final office = ref.watch(officeAreaProvider);
    final (label, variant) = switch (summary.phase) {
      DayPhase.none => ('Belum absen', StatusVariant.neutral),
      DayPhase.pending => ('Menunggu', StatusVariant.pending),
      _ when summary.hasPending => ('Menunggu', StatusVariant.pending),
      _ => ('Hadir', StatusVariant.success),
    };
    final d = summary.workDuration(now);
    final work = '${d.inHours}j ${d.inMinutes % 60}m';
    return AppCard(
      secondary: true,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Status Kehadiran Hari Ini',
                    style: AppType.cardTitle.copyWith(color: c.textPrimary),
                  ),
                ),
              ),
              StatusChip(label: label, variant: variant),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoCell(
                  icon: PhosphorIconsRegular.timer,
                  tint: c.amberTint,
                  iconColor: c.amberIcon,
                  label: 'Jam Kerja',
                  value: work,
                ),
              ),
              Expanded(
                child: _InfoCell(
                  icon: PhosphorIconsFill.mapPin,
                  tint: c.mintTint,
                  iconColor: c.accent,
                  label: 'Lokasi',
                  value: office?.name ?? '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Center(
              child: PhosphorIcon(icon, size: 18, color: iconColor),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.bodyBold.copyWith(color: c.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGrid extends ConsumerWidget {
  const _MenuGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(menuInactiveModeProvider);
    final items = (ref.watch(menusProvider).value ?? const <MenuItemData>[])
        .where((m) => m.isActive || mode == MenuInactiveMode.locked)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpace.grid,
        crossAxisSpacing: AppSpace.grid,
        mainAxisExtent: menuTileExtent(context),
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return MenuTile(
          icon: menuIcon(item.icon),
          label: item.label,
          tone: item.tone,
          enabled: item.isActive,
          onTap: item.isActive ? () => _open(context, item) : null,
        );
      },
    );
  }

  void _open(BuildContext context, MenuItemData item) {
    switch (item.action) {
      case LeaveFormAction(:final category, :final typeCode):
        final q = <String, String>{'category': category, 'type': ?typeCode};
        context.go(Uri(path: '/leaves', queryParameters: q).toString());
      case EventsAction():
        context.push('/events');
      case ComingSoonAction():
        AppToast.show(context, '${item.label} segera tersedia');
    }
  }
}

class _EventBanner extends StatelessWidget {
  const _EventBanner({
    required this.event,
    required this.total,
    required this.onTap,
  });

  final EventItem event;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final start = event.startsAt.replaceFirst(':', '.');
    return Semantics(
      button: true,
      label: '${event.name}, $start. Buka daftar event hari ini',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: c.bannerGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.flag,
                      size: 22,
                      color: c.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.name} · $start',
                        style: AppType.bodyBold.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$total event hari ini · check-in dengan foto dan lokasi',
                        style: AppType.caption.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  size: 18,
                  color: c.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      secondary: true,
      onTap: onTap,
      semanticLabel: '$count menunggu persetujuanmu. Buka persetujuan tim',
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.amberTint,
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
                Text(
                  '$count menunggu persetujuanmu',
                  style: AppType.cardTitle.copyWith(color: c.textPrimary),
                ),
                Text(
                  'Absen di luar area & cuti tim',
                  style: AppType.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          PhosphorIcon(
            PhosphorIconsRegular.caretRight,
            size: 18,
            color: c.textMuted,
          ),
        ],
      ),
    );
  }
}
