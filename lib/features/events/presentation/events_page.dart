import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/network/api_failure.dart';
import '../domain/event_item.dart';
import 'event_providers.dart';

/// Event hari ini. Check-in mengikuti kontrak (foto/lokasi); kontrak belum
/// mendukung QR, jadi layar pindai tidak dibuat.
class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final events = ref.watch(eventsTodayProvider);
    return AppScaffold(
      body: Column(
        children: [
          const PageHeader(title: 'Event Hari Ini'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(eventsTodayProvider);
                await ref
                    .read(eventsTodayProvider.future)
                    .catchError((_) => <EventItem>[]);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.screenH,
                  8,
                  AppSpace.screenH,
                  24,
                ),
                children: [
                  events.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => AppCard(
                      child: Column(
                        children: [
                          Text(
                            e is ApiFailure ? e.message : 'Terjadi kesalahan.',
                            textAlign: TextAlign.center,
                            style: AppType.body.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlineButton(
                            label: 'Coba lagi',
                            onPressed: () =>
                                ref.invalidate(eventsTodayProvider),
                          ),
                        ],
                      ),
                    ),
                    data: (list) => list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Tidak ada event hari ini.',
                              textAlign: TextAlign.center,
                              style: AppType.body.copyWith(color: c.textMuted),
                            ),
                          )
                        : Column(
                            children: [
                              for (final e in list) ...[
                                _EventCard(event: e),
                                const SizedBox(height: AppSpace.block),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hours =
        '${event.startsAt.replaceFirst(':', '.')} - ${event.endsAt.replaceFirst(':', '.')}';
    return AppCard(
      key: Key('event-${event.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.name,
                  style: AppType.cardTitle.copyWith(color: c.textPrimary),
                ),
              ),
              StatusChip(
                label: event.checkedIn ? 'Sudah check-in' : 'Belum check-in',
                variant: event.checkedIn
                    ? StatusVariant.success
                    : StatusVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Hari ini · $hours',
            style: AppType.caption.copyWith(color: c.textMuted),
          ),
          if (!event.checkedIn) ...[
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Check-in',
              icon: PhosphorIconsBold.arrowRight,
              onPressed: () => context.push('/punch/event', extra: event),
            ),
          ],
        ],
      ),
    );
  }
}
