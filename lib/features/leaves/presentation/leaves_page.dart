import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock/clock.dart';
import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../../../core/network/api_failure.dart';
import '../../auth/presentation/session_controller.dart';
import '../domain/leave.dart';
import 'leave_providers.dart';

/// Form Cuti / Izin / Dinas Luar + daftar "Pengajuan terakhir".
class LeavesPage extends ConsumerStatefulWidget {
  const LeavesPage({this.category, this.typeCode, super.key});

  /// Kategori awal (`LeaveCategory.name`) dan kode jenis awal, dari menu beranda.
  final String? category;
  final String? typeCode;

  @override
  ConsumerState<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends ConsumerState<LeavesPage> {
  final _reason = TextEditingController();
  final _typeText = TextEditingController();
  final _startText = TextEditingController();
  final _endText = TextEditingController();
  late LeaveCategory _category = LeaveCategory.byName(widget.category);
  String? _pendingTypeCode;
  int? _typeId;
  DateTime? _start;
  DateTime? _end;

  bool _submitting = false;
  String? _typeError;
  String? _startError;
  String? _endError;
  String? _reasonError;
  String? _ruleMessage;

  @override
  void initState() {
    super.initState();
    _pendingTypeCode = widget.typeCode;
  }

  @override
  void didUpdateWidget(LeavesPage old) {
    super.didUpdateWidget(old);
    if (old.category != widget.category || old.typeCode != widget.typeCode) {
      setState(() {
        _category = LeaveCategory.byName(widget.category);
        _pendingTypeCode = widget.typeCode;
        _typeId = null;
        _typeError = null;
      });
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    _typeText.dispose();
    _startText.dispose();
    _endText.dispose();
    super.dispose();
  }

  int? get _days {
    final s = _start;
    final e = _end;
    if (s == null || e == null || e.isBefore(s)) return null;
    return e.difference(s).inDays + 1;
  }

  Future<void> _pickDate({required bool start}) async {
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final initial = (start ? _start : _end) ?? _start ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 2, 12, 31),
      helpText: start ? 'Tanggal mulai' : 'Tanggal selesai',
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
        _startError = null;
        if (_end != null && _end!.isBefore(picked)) _end = null;
      } else {
        _end = picked;
        _endError = null;
      }
      _ruleMessage = null;
    });
  }

  Future<void> _pickType(List<LeaveType> options) async {
    final c = context.colors;
    final picked = await showModalBottomSheet<LeaveType>(
      context: context,
      backgroundColor: c.surface,
      showDragHandle: true,
      isScrollControlled: true,
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
                  'Jenis ${_category.label}',
                  style: AppType.cardTitle.copyWith(color: c.textPrimary),
                ),
              ),
              for (final t in options)
                ListTile(
                  minTileHeight: AppSpace.minTouch,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    t.name,
                    style: AppType.bodyBold.copyWith(color: c.textPrimary),
                  ),
                  trailing: t.id == _typeId
                      ? PhosphorIcon(
                          PhosphorIconsFill.checkCircle,
                          color: c.accent,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, t),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _typeId = picked.id;
        _typeError = null;
        _ruleMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _typeError = _typeId == null ? 'Jenis pengajuan wajib dipilih.' : null;
      _startError = _start == null ? 'Tanggal mulai wajib diisi.' : null;
      _endError = _end == null
          ? 'Tanggal selesai wajib diisi.'
          : (_start != null && _end!.isBefore(_start!)
                ? 'Tanggal selesai tidak boleh sebelum tanggal mulai.'
                : null);
      _reasonError = null;
      _ruleMessage = null;
    });
    if (_typeError != null || _startError != null || _endError != null) return;

    setState(() => _submitting = true);
    try {
      await withSession(
        ref.read,
        () => ref
            .read(leaveRepositoryProvider)
            .create(
              LeaveDraft(
                attendanceStatusId: _typeId,
                startDate: _start,
                endDate: _end,
                reason: _reason.text,
              ),
            ),
      );
      ref.invalidate(leaveOverviewProvider);
      if (!mounted) return;
      AppToast.show(context, 'Pengajuan terkirim, menunggu atasan');
      setState(() {
        _typeId = null;
        _start = null;
        _end = null;
        _reason.clear();
      });
    } on ValidationFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _typeError = e.first('attendance_status_id');
        _startError = e.first('start_date');
        _endError = e.first('end_date');
        _reasonError = e.first('reason');
        if (_typeError == null &&
            _startError == null &&
            _endError == null &&
            _reasonError == null) {
          _ruleMessage = e.message;
        }
      });
    } on UnauthenticatedFailure {
      // Sesi dicabut oleh withSession; router membawa ke login.
    } on ApiFailure catch (e) {
      if (!mounted) return;
      // 422 aturan (62 hari, tumpang tindih), 403, 429, offline: apa adanya.
      setState(() => _ruleMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final overview = ref.watch(leaveOverviewProvider);
    final types = overview.value?.types ?? const <LeaveType>[];

    if (_pendingTypeCode != null && types.isNotEmpty) {
      final match = types.where((t) => t.code == _pendingTypeCode).firstOrNull;
      if (match != null) {
        _typeId = match.id;
        _category = match.category;
      }
      _pendingTypeCode = null;
    }
    final options = types.where((t) => t.category == _category).toList();
    final selected = options.where((t) => t.id == _typeId).firstOrNull;
    final days = _days;
    _typeText.text = selected?.name ?? '';
    _startText.text = _start == null ? '' : IdFormat.longDate(_start!);
    _endText.text = _end == null ? '' : IdFormat.longDate(_end!);

    return Column(
      children: [
        const PageHeader(title: 'Ajukan Cuti / Izin', showBack: false),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.screenH,
              8,
              AppSpace.screenH,
              AppSpace.contentBottom,
            ),
            children: [
              PillSegmented<LeaveCategory>(
                gradient: true,
                value: _category,
                onChanged: (v) => setState(() {
                  _category = v;
                  if (selected == null || selected.category != v) {
                    _typeId = null;
                  }
                  _typeError = null;
                  _ruleMessage = null;
                }),
                items: [
                  for (final cat in LeaveCategory.values)
                    SegmentItem(value: cat, label: cat.label),
                ],
              ),
              const SizedBox(height: AppSpace.block),
              AppTextField(
                fieldKey: const Key('leave-type'),
                label: 'Jenis ${_category.label}',
                hint: overview.isLoading
                    ? 'Memuat jenis…'
                    : 'Pilih jenis ${_category.label.toLowerCase()}',
                icon: PhosphorIconsRegular.umbrella,
                readOnly: true,
                errorText: _typeError,
                controller: _typeText,
                trailing: PhosphorIcon(
                  PhosphorIconsRegular.caretDown,
                  size: 16,
                  color: c.textMuted,
                ),
                onTap: options.isEmpty ? null : () => _pickType(options),
              ),
              if (overview.hasError) ...[
                const SizedBox(height: 8),
                _InlineRetry(
                  message: _failureText(overview.error),
                  onRetry: () => ref.invalidate(leaveOverviewProvider),
                ),
              ],
              const SizedBox(height: AppSpace.block),
              AppTextField(
                fieldKey: const Key('leave-start'),
                label: 'Tanggal Mulai',
                hint: 'Pilih tanggal',
                icon: PhosphorIconsRegular.calendarBlank,
                readOnly: true,
                errorText: _startError,
                controller: _startText,
                onTap: () => _pickDate(start: true),
              ),
              const SizedBox(height: AppSpace.block),
              AppTextField(
                fieldKey: const Key('leave-end'),
                label: 'Tanggal Selesai',
                hint: 'Pilih tanggal',
                icon: PhosphorIconsRegular.calendarBlank,
                readOnly: true,
                errorText: _endError,
                controller: _endText,
                onTap: () => _pickDate(start: false),
              ),
              const SizedBox(height: AppSpace.block),
              AppTextField(
                fieldKey: const Key('leave-reason'),
                label: 'Alasan (opsional)',
                hint: 'Tulis alasan pengajuan',
                controller: _reason,
                maxLines: 4,
                minLines: 3,
                errorText: _reasonError,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 10),
              Text(
                days == null
                    ? 'Batas satu pengajuan 62 hari'
                    : '$days hari · batas satu pengajuan 62 hari',
                style: AppType.caption.copyWith(color: c.textMuted),
              ),
              if (_ruleMessage != null) ...[
                const SizedBox(height: AppSpace.block),
                _RuleBox(message: _ruleMessage!),
              ],
              const SizedBox(height: AppSpace.block),
              PrimaryButton(
                label: 'Ajukan ${_category.label}',
                loading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 22),
              Semantics(
                header: true,
                child: Text(
                  'Pengajuan terakhir',
                  style: AppType.cardTitle.copyWith(color: c.textPrimary),
                ),
              ),
              const SizedBox(height: 10),
              ..._recent(overview),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _recent(AsyncValue<LeaveOverview> overview) {
    final c = context.colors;
    if (overview.isLoading && !overview.hasValue) {
      return const [
        Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final leaves = overview.value?.leaves ?? const <Leave>[];
    if (leaves.isEmpty) {
      return [
        Text(
          'Belum ada pengajuan.',
          style: AppType.body.copyWith(color: c.textMuted),
        ),
      ];
    }
    return [
      for (final l in leaves.take(5)) ...[
        _LeaveCard(leave: l),
        const SizedBox(height: 10),
      ],
    ];
  }

  static String _failureText(Object? e) =>
      e is ApiFailure ? e.message : 'Terjadi kesalahan. Coba lagi.';
}

class _InlineRetry extends StatelessWidget {
  const _InlineRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: AppType.caption.copyWith(color: c.errorText),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            minimumSize: const Size(AppSpace.minTouch, AppSpace.minTouch),
          ),
          child: const Text('Coba lagi'),
        ),
      ],
    );
  }
}

class _RuleBox extends StatelessWidget {
  const _RuleBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('rule-box'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.amberTint,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhosphorIcon(
              PhosphorIconsRegular.prohibit,
              size: 18,
              color: c.amberIcon,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppType.caption.copyWith(
                  color: c.amberText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave});

  final Leave leave;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (variant, label) = switch (leave.status) {
      LeaveStatus.pending => (StatusVariant.pending, leave.statusLabel),
      LeaveStatus.approved => (StatusVariant.success, leave.statusLabel),
      LeaveStatus.rejected => (StatusVariant.absent, leave.statusLabel),
      LeaveStatus.cancelled => (StatusVariant.neutral, leave.statusLabel),
    };
    final same = leave.startDate == leave.endDate;
    final range = same
        ? IdFormat.shortDate(leave.startDate)
        : '${IdFormat.shortDate(leave.startDate)} - ${IdFormat.shortDate(leave.endDate)}';
    return AppCard(
      secondary: true,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leave.type,
                  style: AppType.bodyBold.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  range,
                  style: AppType.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
          StatusChip(label: label, variant: variant),
        ],
      ),
    );
  }
}
