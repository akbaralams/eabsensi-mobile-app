import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../events/domain/event_item.dart';

/// Kartu event hari ini di beranda: nama, jadwal, jumlah event, dan syarat
/// check-in. [requiresPhoto] mengikuti flag `/me`; lokasi dikirim bila izin
/// diberikan, jadi hanya disebut "Lokasi", bukan "wajib".
class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    required this.total,
    required this.requiresPhoto,
    required this.onTap,
    super.key,
  });

  final EventItem event;

  /// Jumlah event hari ini (termasuk yang sudah check-in).
  final int total;
  final bool requiresPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final schedule =
        '${event.startsAt.replaceFirst(':', '.')} – '
        '${event.endsAt.replaceFirst(':', '.')}';
    final eyebrow = total > 1 ? '$total event hari ini' : 'Event hari ini';
    final radius = BorderRadius.circular(AppRadius.cardSecondary);
    return Semantics(
      button: true,
      label:
          '${event.name}, $schedule. $eyebrow. Check-in memakai '
          '${requiresPhoto ? 'foto dan lokasi' : 'lokasi'}. '
          'Buka daftar event hari ini',
      excludeSemantics: true,
      child: Pressable(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: AppSpace.minTouch),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: radius,
                boxShadow: c.tileShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: PhosphorDuotoneIcon(
                        PhosphorIconsDuotone.flag,
                        size: 28,
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
                          eyebrow,
                          style: AppType.microBold.copyWith(
                            color: c.accentText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.cardTitle.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIconsRegular.clock,
                              size: 14,
                              color: c.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              schedule,
                              style: AppType.small.copyWith(
                                color: c.textSecondary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (requiresPhoto)
                              const _Requirement(
                                icon: PhosphorIconsRegular.camera,
                                label: 'Foto wajib',
                              ),
                            const _Requirement(
                              icon: PhosphorIconsRegular.mapPin,
                              label: 'Lokasi',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: PhosphorIcon(
                      PhosphorIconsBold.caretRight,
                      size: 18,
                      color: c.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, size: 12, color: c.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppType.microBold.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
