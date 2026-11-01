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
import 'approval_card.dart';
import 'attendance_summary.dart';
import 'event_card.dart';
import 'status_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(sessionProvider).value;
    // Jam yang berdetak hanya dibangun di TickingAttendanceCard/StatusCard,
    // bukan seluruh halaman.
    final now = ref.watch(clockProvider)();
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
            child: TickingAttendanceCard(
              summary: summary,
              loading: punches.isLoading && !punches.hasValue,
              onCheckIn: () => context.push('/punch/in'),
              onCheckOut: () => context.push('/punch/out'),
            ),
          ),
          const SizedBox(height: AppSpace.block),
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: StatusCard(summary: summary),
          ),
          const SizedBox(height: AppSpace.block),
          const FadeSlideIn(
            delay: Duration(milliseconds: 120),
            child: _MenuGrid(),
          ),
          if (nextEvent != null) ...[
            const SizedBox(height: AppSpace.block),
            EventCard(
              event: nextEvent,
              total: events.length,
              requiresPhoto: profile?.requiresPhoto ?? false,
              onTap: () => context.push('/events'),
            ),
          ],
          if ((profile?.isSupervisor ?? false) && approvals != null) ...[
            const SizedBox(height: AppSpace.block),
            ApprovalCard(
              approvals: approvals,
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
                maxLines: 2,
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
