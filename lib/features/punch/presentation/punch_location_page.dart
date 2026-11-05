import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/clock/clock.dart';
import '../../../core/design/design.dart';
import '../../../core/device/device_label.dart';
import '../../../core/format/id_format.dart';
import '../../auth/presentation/session_controller.dart';
import 'location_map.dart';
import 'punch_actions.dart';
import 'punch_details.dart';
import 'punch_providers.dart';

/// Layar lokasi untuk Check In / Check Out / check-in event.
class PunchLocationPage extends ConsumerStatefulWidget {
  const PunchLocationPage({required this.target, super.key});

  final FlowTarget target;

  @override
  ConsumerState<PunchLocationPage> createState() => _PunchLocationPageState();
}

class _PunchLocationPageState extends ConsumerState<PunchLocationPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(punchFlowProvider.notifier).start(widget.target),
    );
  }

  Future<void> _confirm() async {
    final requiresPhoto =
        ref.read(sessionProvider).value?.requiresPhoto ?? true;
    if (requiresPhoto) {
      await context.push('/punch/photo');
    } else {
      await submitAndShowOutcome(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final flow = ref.watch(punchFlowProvider);
    final office = ref.watch(officeAreaProvider);
    final device = ref.watch(deviceNameProvider).value ?? '-';
    final deviceLabel = ref.watch(deviceLabelProvider).value;
    final title = widget.target.title;

    final (statusText, statusColor, iconBg, icon) = switch (flow.phase) {
      LocationPhase.locating => (
        'Mencari lokasi…',
        c.textMuted,
        c.rowDivider,
        PhosphorIconsRegular.circleNotch,
      ),
      LocationPhase.inside => (
        'Di dalam area kantor',
        c.successText,
        c.successTint,
        PhosphorIconsBold.check,
      ),
      LocationPhase.outside => (
        'Di luar area kantor',
        c.amberText,
        c.amberTint,
        PhosphorIconsFill.warning,
      ),
      LocationPhase.located => (
        'Lokasi ditemukan',
        c.successText,
        c.successTint,
        PhosphorIconsBold.check,
      ),
      LocationPhase.denied => (
        'Lokasi tidak tersedia',
        c.amberText,
        c.amberTint,
        PhosphorIconsFill.warning,
      ),
    };

    return AppScaffold(
      body: Column(
        children: [
          PageHeader(title: title),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screenH,
                8,
                AppSpace.screenH,
                24,
              ),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      LocationMap(
                        phase: flow.phase,
                        fix: flow.fix,
                        office: office,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        child: Column(
                          children: [
                            Semantics(
                              liveRegion: true,
                              label: 'Lokasi Anda: $statusText',
                              excludeSemantics: true,
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: iconBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: PhosphorIcon(
                                        icon,
                                        size: 20,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lokasi Anda',
                                          style: AppType.small.copyWith(
                                            color: c.textMuted,
                                          ),
                                        ),
                                        Text(
                                          statusText,
                                          style: AppType.cardTitle.copyWith(
                                            color: statusColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: c.surfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  PhosphorIcon(
                                    PhosphorIconsRegular.navigationArrow,
                                    size: 16,
                                    color: c.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      flow.phase == LocationPhase.denied
                                          ? 'Izin lokasi tidak diberikan. Absen tetap bisa dilanjutkan tanpa lokasi.'
                                          : flow.fix == null
                                          ? 'Akurasi lokasi: menunggu…'
                                          : 'Akurasi lokasi: ${flow.fix!.accuracyMeters} meter',
                                      style: AppType.caption.copyWith(
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.block),
                AppCard(
                  secondary: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Informasi $title',
                          style: AppType.cardTitle.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const _LiveDateTimeRows(),
                      _InfoRow(
                        icon: PhosphorIconsRegular.mapPin,
                        label: 'Lokasi',
                        value: PunchDetails.place(flow),
                        note: [
                          ?office?.name,
                          ?PunchDetails.coordinates(flow),
                        ].join(' · '),
                      ),
                      _InfoRow(
                        icon: PhosphorIconsRegular.deviceMobile,
                        label: 'Perangkat',
                        value: deviceLabel ?? device,
                        note: deviceLabel == null ? null : device,
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: flow.canConfirm
                      ? 'Konfirmasi $title'
                      : 'Menunggu lokasi…',
                  onPressed: flow.canConfirm ? _confirm : null,
                ),
                const SizedBox(height: 10),
                OutlineButton(label: 'Batal', onPressed: () => context.pop()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tanggal dan jam yang berdetak tiap detik (zona bisnis). Dipisah agar
/// detik berjalan tidak membangun ulang peta.
class _LiveDateTimeRows extends ConsumerWidget {
  const _LiveDateTimeRows();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now =
        ref.watch(tickingClockProvider).value ?? ref.watch(clockProvider)();
    final zone = ref.watch(businessTimezoneProvider);
    return Column(
      children: [
        _InfoRow(
          icon: PhosphorIconsRegular.calendarBlank,
          label: 'Tanggal',
          value: IdFormat.longDate(now),
        ),
        _InfoRow(
          icon: PhosphorIconsRegular.clock,
          label: 'Waktu',
          value: PunchDetails.time(now, zone),
          note: PunchDetails.serverTimeNote,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.note,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Keterangan kecil di bawah nilai (mis. koordinat); kosong = tidak ada.
  final String? note;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final note = this.note;
    final hasNote = note != null && note.isNotEmpty;
    return Semantics(
      label: hasNote ? '$label: $value. $note' : '$label: $value',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: hasNote ? const EdgeInsets.symmetric(vertical: 8) : null,
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: c.rowDivider)),
        ),
        child: Row(
          children: [
            PhosphorIcon(icon, size: 18, color: c.textMuted),
            const SizedBox(width: 10),
            Text(label, style: AppType.small.copyWith(color: c.textMuted)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppType.smallBold.copyWith(color: c.textPrimary),
                  ),
                  if (hasNote) ...[
                    const SizedBox(height: 2),
                    Text(
                      note,
                      textAlign: TextAlign.right,
                      style: AppType.caption.copyWith(color: c.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
