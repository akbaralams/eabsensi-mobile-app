import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/design/design.dart';
import '../domain/location.dart';
import 'punch_providers.dart';

/// Tile peta dimuat dari OpenStreetMap; test mematikannya (tanpa jaringan).
final mapTilesEnabledProvider = Provider<bool>((ref) => true);

/// Peta dengan lingkaran geofence kantor dan titik posisi pengguna.
class LocationMap extends ConsumerStatefulWidget {
  const LocationMap({
    required this.phase,
    required this.fix,
    required this.office,
    super.key,
  });

  final LocationPhase phase;
  final LocationFix? fix;
  final OfficeArea? office;

  @override
  ConsumerState<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends ConsumerState<LocationMap>
    with SingleTickerProviderStateMixin {
  final _controller = MapController();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _pulsing = false;

  static const _fallback = LatLng(-6.2, 106.8166);

  LatLng get _center {
    final fix = widget.fix;
    if (fix != null) return LatLng(fix.latitude, fix.longitude);
    final o = widget.office;
    return o == null ? _fallback : LatLng(o.latitude, o.longitude);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (!reduce && !_pulsing) {
      _pulsing = true;
      _pulse.repeat();
    } else if (reduce && _pulsing) {
      _pulsing = false;
      _pulse.stop();
    }
  }

  @override
  void didUpdateWidget(LocationMap old) {
    super.didUpdateWidget(old);
    if (old.fix != widget.fix && widget.fix != null) {
      _controller.move(_center, 17);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tiles = ref.watch(mapTilesEnabledProvider);
    final office = widget.office;
    final fix = widget.fix;
    final outside = widget.phase == LocationPhase.outside;
    final userColor = outside ? c.amber : c.primary;

    return Semantics(
      label: 'Peta lokasi',
      container: true,
      child: SizedBox(
        height: 230,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 17,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                    ),
                    backgroundColor: c.surfaceAlt,
                  ),
                  children: [
                    if (tiles)
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'id.eabsensi.app',
                      ),
                    if (office != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(office.latitude, office.longitude),
                            radius: office.radiusMeters,
                            useRadiusInMeter: true,
                            color: c.primary.withValues(alpha: .16),
                            borderColor: c.primary.withValues(alpha: .4),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (office != null)
                          Marker(
                            point: LatLng(office.latitude, office.longitude),
                            width: 120,
                            height: 56,
                            child: _OfficeLabel(name: office.name),
                          ),
                        if (fix != null)
                          Marker(
                            point: LatLng(fix.latitude, fix.longitude),
                            width: 60,
                            height: 60,
                            child: _UserDot(color: userColor, pulse: _pulse),
                          ),
                      ],
                    ),
                    if (tiles)
                      const SimpleAttributionWidget(
                        source: Text('© OpenStreetMap'),
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Semantics(
                  button: true,
                  label: 'Pusatkan ke lokasi saya',
                  child: Material(
                    color: c.surface,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _controller.move(_center, 17),
                      child: SizedBox(
                        width: AppSpace.minTouch,
                        height: AppSpace.minTouch,
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIconsRegular.crosshair,
                            size: 22,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficeLabel extends StatelessWidget {
  const _OfficeLabel({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: c.softShadow,
          ),
          child: Text(
            name,
            style: AppType.microBold.copyWith(color: c.textPrimary),
          ),
        ),
        PhosphorIcon(PhosphorIconsFill.mapPin, size: 22, color: c.teal),
      ],
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot({required this.color, required this.pulse});

  final Color color;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, _) {
            final t = pulse.value;
            return Opacity(
              opacity: (1 - t).clamp(0, 1) * .5,
              child: Container(
                width: 20 * (.6 + 2 * t),
                height: 20 * (.6 + 2 * t),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .5),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}
