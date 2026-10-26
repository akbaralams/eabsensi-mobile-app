import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/session_controller.dart';
import '../design/design.dart';
import 'mock_env.dart';

/// Panel skenario uji untuk data dummy: lokasi, offline, token dicabut,
/// `requires_photo`, `requires_approval`.
class ScenarioPage extends ConsumerWidget {
  const ScenarioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final s = ref.watch(mockScenarioProvider);
    final ctl = ref.read(mockScenarioProvider.notifier);

    Widget toggle(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> on,
    ) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppType.bodyBold.copyWith(color: c.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: AppType.caption.copyWith(color: c.textMuted),
      ),
      value: value,
      onChanged: on,
    );

    return AppScaffold(
      body: Column(
        children: [
          const PageHeader(title: 'Skenario Uji'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi',
                        style: AppType.cardTitle.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      PillSegmented<LocationScenario>(
                        value: s.location,
                        onChanged: (v) =>
                            ctl.update((x) => x.copyWith(location: v)),
                        items: const [
                          SegmentItem(
                            value: LocationScenario.inside,
                            label: 'Di area',
                          ),
                          SegmentItem(
                            value: LocationScenario.outside,
                            label: 'Di luar',
                          ),
                          SegmentItem(
                            value: LocationScenario.denied,
                            label: 'Ditolak',
                          ),
                          SegmentItem(
                            value: LocationScenario.searching,
                            label: 'Mencari',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.block),
                AppCard(
                  child: Column(
                    children: [
                      toggle(
                        'Offline',
                        'Semua permintaan gagal tanpa jaringan',
                        s.offline,
                        (v) => ctl.update((x) => x.copyWith(offline: v)),
                      ),
                      toggle(
                        'Token dicabut',
                        'Permintaan berikutnya 401, kembali ke login',
                        s.tokenRevoked,
                        (v) => ctl.update((x) => x.copyWith(tokenRevoked: v)),
                      ),
                      toggle(
                        'Foto wajib',
                        '`requires_photo` dari /me',
                        s.requiresPhoto,
                        (v) {
                          ctl.update((x) => x.copyWith(requiresPhoto: v));
                          ref.read(sessionProvider.notifier).refresh();
                        },
                      ),
                      toggle(
                        'Perlu persetujuan',
                        '`requires_approval` dari /me (status pending)',
                        s.requiresApproval,
                        (v) {
                          ctl.update((x) => x.copyWith(requiresApproval: v));
                          ref.read(sessionProvider.notifier).refresh();
                        },
                      ),
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
