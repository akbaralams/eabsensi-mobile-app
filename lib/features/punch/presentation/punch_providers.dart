import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/clock/clock.dart';
import '../../../core/config/app_config.dart';
import '../../../core/geo/geo.dart';
import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_failure.dart';
import '../../auth/presentation/session_controller.dart';
import '../../events/domain/event_item.dart';
import '../../events/presentation/event_providers.dart';
import '../data/api_punch_repository.dart';
import '../data/fake_address_service.dart';
import '../data/fake_location_service.dart';
import '../data/geocoding_address_service.dart';
import '../data/geolocator_location_service.dart';
import '../data/platform_device_integrity_service.dart';
import '../data/real_camera_service.dart';
import '../data/mock_punch_repository.dart';
import '../domain/camera.dart';
import '../domain/location.dart';
import '../domain/punch.dart';

final punchRepositoryProvider = Provider<PunchRepository>((ref) {
  if (AppConfig.useMock) return MockPunchRepository(ref.watch(mockEnvProvider));
  return ApiPunchRepository(ref.watch(apiClientProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) {
  if (AppConfig.useMock) {
    return FakeLocationService(ref.watch(mockEnvProvider));
  }
  return const GeolocatorLocationService();
});

final addressServiceProvider = Provider<AddressService>((ref) {
  if (AppConfig.useMock) return FakeAddressService(ref.watch(mockEnvProvider));
  return const GeocodingAddressService();
});

/// Kamera perangkat sungguhan; test meng-override dengan `FakeCameraService`.
final cameraServiceProvider = Provider<CameraService>(
  (ref) => const RealCameraService(),
);

final deviceIntegrityProvider = Provider<DeviceIntegrityService>((ref) {
  if (AppConfig.useMock) return const FakeDeviceIntegrityService();
  return const PlatformDeviceIntegrityService();
});

/// Lokasi yang berlaku untuk alur yang sedang berjalan: lokasi event untuk
/// check-in event, selain itu lokasi kerja dari `/me`. `null` = tanpa radius.
final officeAreaProvider = Provider<OfficeArea?>((ref) {
  if (AppConfig.useMock) return FakeLocationService.office;
  final target = ref.watch(punchFlowProvider.select((flow) => flow.target));
  return switch (target) {
    PunchTarget() => ref.watch(
      sessionProvider.select((session) => session.value?.workLocation),
    ),
    EventTarget(:final event) => event.workLocation,
  };
});

/// Server mewajibkan lokasi bila ada lokasi yang berlaku. Data contoh tetap bisa
/// dilanjutkan tanpa lokasi.
final locationRequiredProvider = Provider<bool>(
  (ref) => !AppConfig.useMock && ref.watch(officeAreaProvider) != null,
);

/// Punch hari ini (tanggal zona bisnis) dari server, terlama dulu.
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

enum LocationPhase { locating, inside, outside, located, denied, unavailable }

class FlowResult {
  const FlowResult({
    required this.time,
    required this.status,
    this.locationFlags = const [],
  });

  /// Waktu dari respons server.
  final DateTime time;

  /// `null` untuk check-in event (kontrak tidak mengembalikan status).
  final PunchStatus? status;

  /// Tanda lokasi dari server untuk ditinjau.
  final List<String> locationFlags;
}

class PunchFlowState {
  const PunchFlowState({
    required this.target,
    this.locationRequired = false,
    this.phase = LocationPhase.locating,
    this.fix,
    this.address,
    this.addressPending = false,
    this.photoPath,
    this.submitting = false,
    this.result,
    this.failure,
  });

  final FlowTarget target;

  /// Ada lokasi yang berlaku, jadi absen tanpa lokasi sah akan ditolak server.
  final bool locationRequired;
  final LocationPhase phase;
  final LocationFix? fix;

  /// Nama jalan dari [fix] (hanya tampilan); `null` bila belum/tidak ada.
  final String? address;

  /// Nama jalan sedang dicari.
  final bool addressPending;
  final String? photoPath;
  final bool submitting;
  final FlowResult? result;
  final Object? failure;

  /// Alasan absen belum bisa dikirim saat lokasi wajib; `null` bila bisa.
  String? get blockReason {
    if (!locationRequired) return null;
    if (phase == LocationPhase.denied) {
      return 'Lokasi wajib untuk absen. Nyalakan GPS dan izinkan akses lokasi.';
    }
    if (phase == LocationPhase.unavailable) {
      return 'Lokasi belum didapat. Pindah ke area terbuka lalu coba lagi.';
    }
    if (fix?.isMocked ?? false) {
      return 'Lokasi palsu terdeteksi. Matikan aplikasi pengubah lokasi lalu coba lagi.';
    }
    if (fix?.isApproximate ?? false) {
      return 'Izinkan lokasi tepat, bukan lokasi perkiraan, agar absen bisa dicatat.';
    }
    return null;
  }

  bool get canConfirm =>
      phase != LocationPhase.locating && !submitting && blockReason == null;

  PunchFlowState copyWith({
    LocationPhase? phase,
    LocationFix? fix,
    String? address,
    bool? addressPending,
    String? photoPath,
    bool? submitting,
    FlowResult? result,
    Object? failure,
    bool clearFailure = false,
    bool clearPhoto = false,
  }) => PunchFlowState(
    target: target,
    locationRequired: locationRequired,
    phase: phase ?? this.phase,
    fix: fix ?? this.fix,
    address: address ?? this.address,
    addressPending: addressPending ?? this.addressPending,
    photoPath: clearPhoto ? null : photoPath ?? this.photoPath,
    submitting: submitting ?? this.submitting,
    result: result ?? this.result,
    failure: clearFailure ? null : failure ?? this.failure,
  );
}

/// Alur: mencari lokasi -> (foto) -> kirim -> hasil atau galat.
class PunchFlowController extends Notifier<PunchFlowState> {
  /// Lokasi lebih tua dari ini diambil ulang sebelum dikirim (langkah foto bisa
  /// memakan waktu, sedangkan server menolak data GPS yang kedaluwarsa).
  static const _maxReuseSeconds = 30;

  int _run = 0;

  @override
  PunchFlowState build() =>
      const PunchFlowState(target: PunchTarget(PunchKind.checkIn));

  Future<void> start(FlowTarget target) async {
    final run = ++_run;
    // Target dipasang dulu: lokasi yang berlaku bergantung pada target ini.
    state = PunchFlowState(target: target);
    state = PunchFlowState(
      target: target,
      locationRequired: ref.read(locationRequiredProvider),
    );
    final result = await ref.read(locationServiceProvider).current();
    if (run != _run) return;
    switch (result) {
      case LocationDenied():
        state = state.copyWith(phase: LocationPhase.denied);
      case LocationUnavailable():
        state = state.copyWith(phase: LocationPhase.unavailable);
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
        state = state.copyWith(phase: phase, fix: fix, addressPending: true);
        final address = await ref
            .read(addressServiceProvider)
            .lookup(fix.latitude, fix.longitude);
        if (run != _run) return;
        state = state.copyWith(address: address, addressPending: false);
    }
  }

  void setPhoto(String path) => state = state.copyWith(photoPath: path);

  /// Foto Ulang: buang foto sebelumnya (berkas sementaranya ikut dihapus).
  Future<void> discardPhoto() async {
    final path = state.photoPath;
    state = state.copyWith(clearPhoto: true);
    await _deletePhoto(path);
  }

  /// Lokasi untuk dikirim. Kiriman ulang selalu mengambil lokasi baru agar
  /// pegawai yang sudah memperbaiki GPS tidak ditolak karena data lama.
  Future<LocationFix?> _freshFix({required bool force}) async {
    final fix = state.fix;
    if (fix == null) return null;
    if (!force && fix.ageSeconds(DateTime.now()) <= _maxReuseSeconds) {
      return fix;
    }
    final result = await ref.read(locationServiceProvider).current();
    if (result case LocationFound(fix: final fresh)) {
      state = state.copyWith(fix: fresh);
      return fresh;
    }
    return fix;
  }

  Future<void> submit() async {
    if (state.submitting) return;
    final retrying = state.failure != null;
    state = state.copyWith(submitting: true, clearFailure: true);
    final fix = await _freshFix(force: retrying);
    final rooted = await ref.read(deviceIntegrityProvider).isRooted();
    final evidence = EvidenceSubmission(
      photoPath: state.photoPath,
      latitude: fix?.latitude,
      longitude: fix?.longitude,
      accuracy: fix?.accuracyMeters,
      isMocked: fix?.isMocked,
      locationAgeSeconds: fix?.ageSeconds(DateTime.now()),
      deviceRooted: rooted,
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
          result = FlowResult(
            time: punch.punchedAt,
            status: punch.status,
            locationFlags: punch.locationFlags,
          );
        case EventTarget(:final event):
          final checkIn = await withSession(
            ref.read,
            () => ref.read(eventRepositoryProvider).checkIn(event.id, evidence),
          );
          ref.invalidate(eventsTodayProvider);
          result = FlowResult(
            time: checkIn.checkedInAt,
            status: null,
            locationFlags: checkIn.locationFlags,
          );
      }
      await _deletePhoto(state.photoPath);
      state = state.copyWith(submitting: false, result: result);
    } on Object catch (e) {
      // Event dihapus/dinonaktifkan sejak daftar dimuat: muat ulang daftar.
      if (e is NotFoundFailure && state.target is EventTarget) {
        ref.invalidate(eventsTodayProvider);
      }
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
