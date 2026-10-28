import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock/clock.dart';
import '../../../core/config/app_config.dart';
import '../../../core/geo/geo.dart';
import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_providers.dart';
import '../../auth/presentation/session_controller.dart';
import '../../events/domain/event_item.dart';
import '../../events/presentation/event_providers.dart';
import '../data/fake_location_service.dart';
import '../data/real_camera_service.dart';
import '../data/geolocator_location_service.dart';
import '../data/mock_punch_repository.dart';
import '../data/remote_punch_repository.dart';
import '../domain/camera.dart';
import '../domain/location.dart';
import '../domain/punch.dart';

final punchRepositoryProvider = Provider<PunchRepository>((ref) {
  if (AppConfig.useMock) return MockPunchRepository(ref.watch(mockEnvProvider));
  return RemotePunchRepository(ref.watch(mobileApiClientProvider).punch);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  if (AppConfig.useMock) {
    return FakeLocationService(ref.watch(mockEnvProvider));
  }
  return const GeolocatorLocationService();
});

/// Kamera perangkat sungguhan; test meng-override dengan `FakeCameraService`.
final cameraServiceProvider = Provider<CameraService>(
  (ref) => const RealCameraService(),
);

/// Area kantor untuk tampilan peta; `null` bila kontrak belum menyediakannya.
final officeAreaProvider = Provider<OfficeArea?>(
  (ref) => AppConfig.useMock ? FakeLocationService.office : null,
);

/// Punch hari ini dari server (terlama dulu).
final todayPunchesProvider = FutureProvider.autoDispose<List<Punch>>((ref) {
  final today = ref.watch(clockProvider)();
  return withSession(
    ref.read,
    () => ref.watch(punchRepositoryProvider).list(today),
  );
});

enum PunchKind { checkIn, checkOut }

/// Tujuan alur bukti: punch biasa atau check-in event.
sealed class FlowTarget {
  const FlowTarget();

  String get title;
}

final class PunchTarget extends FlowTarget {
  const PunchTarget(this.kind);

  final PunchKind kind;

  @override
  String get title => kind == PunchKind.checkIn ? 'Check In' : 'Check Out';
}

final class EventTarget extends FlowTarget {
  const EventTarget(this.event);

  final EventItem event;

  @override
  String get title => 'Check-in ${event.name}';
}

enum LocationPhase { locating, inside, outside, located, denied }

class FlowResult {
  const FlowResult({required this.time, required this.status});

  /// Waktu dari respons server.
  final DateTime time;

  /// `null` untuk check-in event (kontrak tidak mengembalikan status).
  final PunchStatus? status;
}

class PunchFlowState {
  const PunchFlowState({
    required this.target,
    this.phase = LocationPhase.locating,
    this.fix,
    this.photoPath,
    this.submitting = false,
    this.result,
    this.failure,
  });

  final FlowTarget target;
  final LocationPhase phase;
  final LocationFix? fix;
  final String? photoPath;
  final bool submitting;
  final FlowResult? result;
  final Object? failure;

  bool get canConfirm => phase != LocationPhase.locating && !submitting;

  PunchFlowState copyWith({
    LocationPhase? phase,
    LocationFix? fix,
    String? photoPath,
    bool? submitting,
    FlowResult? result,
    Object? failure,
    bool clearFailure = false,
  }) => PunchFlowState(
    target: target,
    phase: phase ?? this.phase,
    fix: fix ?? this.fix,
    photoPath: photoPath ?? this.photoPath,
    submitting: submitting ?? this.submitting,
    result: result ?? this.result,
    failure: clearFailure ? null : failure ?? this.failure,
  );
}

/// Alur: mencari lokasi -> (foto) -> kirim -> hasil atau galat.
class PunchFlowController extends Notifier<PunchFlowState> {
  int _run = 0;

  @override
  PunchFlowState build() =>
      const PunchFlowState(target: PunchTarget(PunchKind.checkIn));

  Future<void> start(FlowTarget target) async {
    final run = ++_run;
    state = PunchFlowState(target: target);
    final result = await ref.read(locationServiceProvider).current();
    if (run != _run) return;
    switch (result) {
      case LocationDenied():
        state = state.copyWith(phase: LocationPhase.denied);
      case LocationFound(:final fix):
        final office = ref.read(officeAreaProvider);
        final phase = office == null
            ? LocationPhase.located
            : distanceMeters(
                    fix.latitude,
                    fix.longitude,
                    office.latitude,
                    office.longitude,
                  ) <=
                  office.radiusMeters
            ? LocationPhase.inside
            : LocationPhase.outside;
        state = state.copyWith(phase: phase, fix: fix);
    }
  }

  void setPhoto(String path) => state = state.copyWith(photoPath: path);

  Future<void> submit() async {
    if (state.submitting) return;
    state = state.copyWith(submitting: true, clearFailure: true);
    final fix = state.fix;
    final evidence = EvidenceSubmission(
      photoPath: state.photoPath,
      latitude: fix?.latitude,
      longitude: fix?.longitude,
      accuracy: fix?.accuracyMeters,
    );
    try {
      final target = state.target;
      final FlowResult result;
      switch (target) {
        case PunchTarget():
          final punch = await withSession(
            ref.read,
            () => ref.read(punchRepositoryProvider).create(evidence),
          );
          ref.invalidate(todayPunchesProvider);
          result = FlowResult(time: punch.punchedAt, status: punch.status);
        case EventTarget(:final event):
          final checkIn = await withSession(
            ref.read,
            () => ref.read(eventRepositoryProvider).checkIn(event.id, evidence),
          );
          ref.invalidate(eventsTodayProvider);
          result = FlowResult(time: checkIn.checkedInAt, status: null);
      }
      await _deletePhoto(state.photoPath);
      state = state.copyWith(submitting: false, result: result);
    } on Object catch (e) {
      state = state.copyWith(submitting: false, failure: e);
    }
  }
}

/// Foto sementara dihapus setelah berhasil terkirim (jangan menimbun selfie).
Future<void> _deletePhoto(String? path) async {
  if (path == null || path.startsWith('mock://')) return;
  try {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  } on Object {
    // Gagal menghapus berkas sementara tidak boleh menggagalkan alur.
  }
}

final punchFlowProvider = NotifierProvider<PunchFlowController, PunchFlowState>(
  PunchFlowController.new,
);
