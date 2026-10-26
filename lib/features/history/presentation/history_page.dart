import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/clock/clock.dart';
import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../domain/history.dart';
import 'history_providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({this.showBack = false, super.key});

  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final month = ref.watch(historyMonthProvider);
    final now = ref.watch(clockProvider)();
    final isCurrent = month.year == now.year && month.month == now.month;
    final data = ref.watch(monthHistoryProvider);

    return Column(
      children: [
        PageHeader(
          title: 'Riwayat Absensi',
          showBack: showBack,
          onBack: () => context.pop(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.screenH,
              8,
              AppSpace.screenH,
              AppSpace.contentBottom,
            ),
            children: [
              AppCard(
                child: Column(
                  children: [
                    _MonthNav(
                      month: month,
                      canNext: !isCurrent,
                      onPrev: () => ref
                          .read(historyMonthProvider.notifier)
                          .set(DateTime(month.year, month.month - 1)),
                      onNext: () => ref
                          .read(historyMonthProvider.notifier)
                          .set(DateTime(month.year, month.month + 1)),
                    ),
                    const SizedBox(height: 14),
                    data.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Text(
                              e is Exception
                                  ? e.toString().replaceFirst(
                                      RegExp(r'^\w+: '),
                                      '',
                                    )
                                  : 'Terjadi kesalahan.',
                              textAlign: TextAlign.center,
                              style: AppType.body.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlineButton(
                              label: 'Coba lagi',
                              onPressed: () =>
                                  ref.invalidate(monthHistoryProvider),
                            ),
                          ],
                        ),
                      ),
                      data: (h) => _Content(history: h),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.month,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconCircleButton(
          icon: PhosphorIconsRegular.caretLeft,
          iconSize: 16,
          semanticLabel: 'Bulan sebelumnya',
          background: c.surfaceAlt,
          onPressed: onPrev,
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            IdFormat.monthYear(month),
            style: AppType.cardTitle.copyWith(color: c.textPrimary),
          ),
        ),
        Opacity(
          opacity: canNext ? 1 : .35,
          child: IconCircleButton(
            icon: PhosphorIconsRegular.caretRight,
            iconSize: 16,
            semanticLabel: 'Bulan berikutnya',
            background: c.surfaceAlt,
            onPressed: canNext ? onNext : null,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.history});

  final MonthHistory history;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: history.count(DayStatus.present),
                label: 'Hadir',
                bg: c.isDark ? c.successTint : const Color(0xFFECFDF5),
                fg: c.accentText,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                value: history.count(DayStatus.late),
                label: 'Terlambat',
                bg: c.amberSoft,
                fg: c.amberText,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                value: history.count(DayStatus.absent),
                label: 'Tidak Hadir',
                bg: c.errorSoft,
                fg: c.errorStrong,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (history.days.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Text(
              'Belum ada data absensi pada bulan ini.',
              style: AppType.body.copyWith(color: c.textMuted),
            ),
          )
        else
          for (final d in history.days) _DayRow(day: d),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final int value;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$label $value hari',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text('$value', style: AppType.title.copyWith(color: fg)),
            const SizedBox(height: 2),
            Text(label, style: AppType.micro.copyWith(color: c.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final DayRecord day;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (label, variant) = switch (day.status) {
      DayStatus.present => ('Hadir', StatusVariant.success),
      DayStatus.late => ('Terlambat', StatusVariant.late),
      DayStatus.absent => ('Tidak Hadir', StatusVariant.absent),
      DayStatus.pending => ('Menunggu', StatusVariant.pending),
    };
    final times = day.checkIn == null
        ? '-'
        : '${day.checkIn} - ${day.checkOut ?? '-'}';
    return Semantics(
      label:
          '${IdFormat.dayName(day.date)} ${day.date.day}, $label, jam $times',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.rowDivider)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${day.date.day}',
                    style: AppType.cardTitle.copyWith(
                      color: c.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    IdFormat.dayName(day.date).substring(0, 3),
                    style: AppType.micro.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusChip(label: label, variant: variant),
            const Spacer(),
            Text(
              times,
              style: AppType.small.copyWith(
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
