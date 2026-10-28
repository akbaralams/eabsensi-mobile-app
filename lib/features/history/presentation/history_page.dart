import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/clock/clock.dart';
import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../../../core/network/api_failure.dart';
import '../domain/history.dart';
import 'history_providers.dart';

/// Skala teks di atas ini memakai tata letak bertumpuk (WCAG 1.4.4).
bool _largeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3;

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({this.showBack = false, super.key});

  final bool showBack;

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  DayStatus? _filter;

  Future<void> _pickMonth(DateTime current) async {
    final now = ref.read(clockProvider)();
    final months = [
      for (var i = 0; i <= 12; i++) DateTime(now.year, now.month - i),
    ];
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .6,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Pilih bulan',
                  style: AppType.cardTitle.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              for (final m in months)
                ListTile(
                  minTileHeight: AppSpace.minTouch,
                  contentPadding: EdgeInsets.zero,
                  selected: m.year == current.year && m.month == current.month,
                  title: Text(
                    IdFormat.monthYear(m),
                    style: AppType.bodyBold.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  trailing: m.year == current.year && m.month == current.month
                      ? PhosphorIcon(
                          PhosphorIconsFill.checkCircle,
                          color: context.colors.accent,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, m),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      ref.read(historyMonthProvider.notifier).set(picked);
    }
  }

  void _showDetail(DayRecord day) {
    final c = context.colors;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          child: _DayDetail(day: day),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(historyMonthProvider);
    final now = ref.watch(clockProvider)();
    final isCurrent = month.year == now.year && month.month == now.month;
    final earliest = earliestHistoryMonth(now);
    final isEarliest =
        month.year == earliest.year && month.month == earliest.month;
    final data = ref.watch(monthHistoryProvider);
    final classified = ref
        .watch(historyRepositoryProvider)
        .supportsClassification;

    return Column(
      children: [
        PageHeader(
          title: 'Riwayat Absensi',
          showBack: widget.showBack,
          onBack: () => context.pop(),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(monthHistoryProvider);
              await ref
                  .read(monthHistoryProvider.future)
                  .catchError(
                    (_) => const MonthHistory(year: 0, month: 0, days: []),
                  );
            },
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
                        canPrev: !isEarliest,
                        canNext: !isCurrent,
                        onPrev: () {
                          setState(() => _filter = null);
                          ref
                              .read(historyMonthProvider.notifier)
                              .set(DateTime(month.year, month.month - 1));
                        },
                        onNext: () {
                          setState(() => _filter = null);
                          ref
                              .read(historyMonthProvider.notifier)
                              .set(DateTime(month.year, month.month + 1));
                        },
                        onPick: () => _pickMonth(month),
                      ),
                      const SizedBox(height: 14),
                      if (data.isLoading && data.hasValue)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LinearProgressIndicator(minHeight: 3),
                        ),
                      if (data.hasValue)
                        // Data bulan sebelumnya tetap tampil (diredupkan)
                        // selama bulan baru dimuat: tidak berkedip.
                        Opacity(
                          opacity: data.isLoading ? .5 : 1,
                          child: _Content(
                            history: data.requireValue,
                            classified: classified,
                            filter: _filter,
                            onFilter: (s) => setState(
                              () => _filter = _filter == s ? null : s,
                            ),
                            onOpen: _showDetail,
                          ),
                        )
                      else if (data.hasError)
                        _LoadError(
                          error: data.error,
                          onRetry: () => ref.invalidate(monthHistoryProvider),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(child: CircularProgressIndicator()),
                        ),
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

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              error is ApiFailure
                  ? (error! as ApiFailure).message
                  : 'Terjadi kesalahan. Coba lagi.',
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(color: c.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          OutlineButton(label: 'Coba lagi', onPressed: onRetry),
        ],
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.month,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  final DateTime month;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Opacity(
          opacity: canPrev ? 1 : .35,
          child: IconCircleButton(
            icon: PhosphorIconsRegular.caretLeft,
            iconSize: 16,
            semanticLabel: 'Bulan sebelumnya',
            background: c.surfaceAlt,
            onPressed: canPrev ? onPrev : null,
          ),
        ),
        Expanded(
          child: Semantics(
            button: true,
            liveRegion: true,
            label: 'Pilih bulan, ${IdFormat.monthYear(month)}',
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.input),
              onTap: onPick,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSpace.minTouch),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            IdFormat.monthYear(month),
                            style: AppType.cardTitle.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      PhosphorIcon(
                        PhosphorIconsRegular.caretDown,
                        size: 14,
                        color: c.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
  const _Content({
    required this.history,
    required this.classified,
    required this.filter,
    required this.onFilter,
    required this.onOpen,
  });

  final MonthHistory history;
  final bool classified;
  final DayStatus? filter;
  final ValueChanged<DayStatus> onFilter;
  final ValueChanged<DayRecord> onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tiles = <_StatTile>[
      _StatTile(
        status: DayStatus.present,
        value: history.count(DayStatus.present),
        label: 'Hadir',
        bg: c.statHadir,
        fg: c.accentText,
        selected: filter == DayStatus.present,
        onTap: onFilter,
      ),
      if (classified) ...[
        _StatTile(
          status: DayStatus.late,
          value: history.count(DayStatus.late),
          label: 'Terlambat',
          bg: c.amberSoft,
          fg: c.amberText,
          selected: filter == DayStatus.late,
          onTap: onFilter,
        ),
        _StatTile(
          status: DayStatus.absent,
          value: history.count(DayStatus.absent),
          label: 'Tidak Hadir',
          bg: c.errorSoft,
          fg: c.errorStrong,
          selected: filter == DayStatus.absent,
          onTap: onFilter,
        ),
      ] else
        _StatTile(
          status: DayStatus.pending,
          value: history.count(DayStatus.pending),
          label: 'Menunggu',
          bg: c.amberSoft,
          fg: c.amberText,
          selected: filter == DayStatus.pending,
          onTap: onFilter,
        ),
    ];

    final days = [
      for (final d in history.days)
        if (filter == null || d.status == filter) d,
    ];
    final large = _largeText(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (large)
          for (final t in tiles) ...[t, const SizedBox(height: 8)]
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: tiles[i]),
                ],
              ],
            ),
          ),
        if (filter != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onFilter(filter!),
              style: TextButton.styleFrom(
                minimumSize: const Size(AppSpace.minTouch, AppSpace.minTouch),
              ),
              child: const Text('Tampilkan semua hari'),
            ),
          )
        else
          const SizedBox(height: 8),
        if (history.days.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Text(
              'Belum ada data absensi pada bulan ini.',
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(color: c.textMuted),
            ),
          )
        else if (days.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Tidak ada hari dengan status ini.',
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(color: c.textMuted),
            ),
          )
        else
          for (final d in days) _DayRow(day: d, large: large, onTap: onOpen),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.status,
    required this.value,
    required this.label,
    required this.bg,
    required this.fg,
    required this.selected,
    required this.onTap,
  });

  final DayStatus status;
  final int value;
  final String label;
  final Color bg;
  final Color fg;
  final bool selected;
  final ValueChanged<DayStatus> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final large = _largeText(context);
    final number = Text('$value', style: AppType.title.copyWith(color: fg));
    final caption = Text(
      label,
      textAlign: TextAlign.center,
      style: AppType.micro.copyWith(color: c.textSecondary),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: '$label $value hari. Ketuk untuk menyaring daftar',
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: selected ? BorderSide(color: fg, width: 2) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onTap(status),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpace.minTouch),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: large
                  ? Row(
                      children: [
                        number,
                        const SizedBox(width: 12),
                        Expanded(child: caption),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [number, const SizedBox(height: 2), caption],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

(String, StatusVariant) _statusOf(DayStatus s) => switch (s) {
  DayStatus.present => ('Hadir', StatusVariant.success),
  DayStatus.late => ('Terlambat', StatusVariant.late),
  DayStatus.absent => ('Tidak Hadir', StatusVariant.absent),
  DayStatus.pending => ('Menunggu', StatusVariant.pending),
  DayStatus.none => ('Belum absen', StatusVariant.neutral),
};

String _spokenDay(DayRecord d) {
  final date =
      '${IdFormat.dayName(d.date)} ${d.date.day} ${IdFormat.monthName(d.date.month)}';
  final (label, _) = _statusOf(d.status);
  final times = d.checkIn == null
      ? 'tidak ada catatan jam'
      : 'masuk ${d.checkIn}${d.checkOut == null ? '' : ', keluar ${d.checkOut}'}';
  return '${d.isToday ? 'Hari ini, ' : ''}$date, $label, $times. Ketuk untuk detail';
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.large, required this.onTap});

  final DayRecord day;
  final bool large;
  final ValueChanged<DayRecord> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (label, variant) = _statusOf(day.status);
    final times = day.checkIn == null
        ? '-'
        : day.checkOut == null
        ? '${day.checkIn}'
        : '${day.checkIn} - ${day.checkOut}';

    final date = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${day.date.day}',
          style: AppType.cardTitle.copyWith(color: c.textPrimary, fontSize: 16),
        ),
        Text(
          IdFormat.dayName(day.date).substring(0, 3),
          maxLines: 1,
          softWrap: false,
          style: AppType.micro.copyWith(color: c.textMuted),
        ),
      ],
    );
    final chip = Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        StatusChip(label: label, variant: variant),
        if (day.isToday)
          Text('Hari ini', style: AppType.micro.copyWith(color: c.textMuted)),
      ],
    );
    final timeText = Text(
      times,
      style: AppType.small.copyWith(
        color: c.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    return Semantics(
      button: true,
      label: _spokenDay(day),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onTap(day),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.rowDivider)),
          ),
          child: large
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 56),
                      child: date,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [chip, const SizedBox(height: 4), timeText],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(width: 44, child: date),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: chip,
                      ),
                    ),
                    const SizedBox(width: 8),
                    timeText,
                  ],
                ),
        ),
      ),
    );
  }
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({required this.day});

  final DayRecord day;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (label, variant) = _statusOf(day.status);
    final note = switch (day.status) {
      DayStatus.pending => 'Menunggu persetujuan atasan. Belum dihitung sebagai kehadiran sampai disetujui.',
      DayStatus.absent => 'Tidak ada punch tercatat pada hari ini.',
      DayStatus.late => 'Masuk setelah jam yang ditentukan.',
      DayStatus.none => 'Belum ada punch hari ini.',
      DayStatus.present => 'Kehadiran tercatat.',
    };
    Widget row(String name, String? value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AppType.small.copyWith(color: c.textMuted),
            ),
          ),
          Text(
            value ?? '-',
            style: AppType.bodyBold.copyWith(
              color: c.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            IdFormat.longDate(day.date),
            style: AppType.cardTitle.copyWith(color: c.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        StatusChip(label: label, variant: variant, large: true),
        const SizedBox(height: 8),
        row('Masuk', day.checkIn),
        row('Keluar', day.checkOut),
        const SizedBox(height: 4),
        Text(note, style: AppType.caption.copyWith(color: c.textSecondary)),
      ],
    );
  }
}
