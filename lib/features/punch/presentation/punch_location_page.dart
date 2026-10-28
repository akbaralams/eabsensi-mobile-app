import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/clock/clock.dart';
import '../../../core/design/design.dart';
import '../../../core/format/id_format.dart';
import '../../auth/presentation/session_controller.dart';
import 'location_map.dart';
import 'punch_actions.dart';
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
    final now = ref.watch(clockProvider)();
    final device = ref.watch(deviceNameProvider).value ?? '-';
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
                      _InfoRow(
                        icon: PhosphorIconsRegular.calendarBlank,
                        label: 'Tanggal',
                        value: IdFormat.longDate(now),
                      ),
                      const _InfoRow(
                        icon: PhosphorIconsRegular.clock,
                        label: 'Waktu',
                        value: 'Dicatat oleh server',
                      ),
                      _InfoRow(
                        icon: PhosphorIconsRegular.mapPin,
                        label: 'Lokasi',
                        value: office?.name ?? 'Lokasi perangkat',
                      ),
                      _InfoRow(
                        icon: PhosphorIconsRegular.deviceMobile,
                        label: 'Perangkat',
                        value: device,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
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
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppType.smallBold.copyWith(color: c.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
