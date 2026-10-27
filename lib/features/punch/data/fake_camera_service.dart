import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../domain/camera.dart';

/// Kamera palsu untuk test (dan perangkat tanpa kamera): pratinjau gradien dan
/// foto bernama `mock://selfie-....jpg`.
class FakeCameraService implements CameraService {
  const FakeCameraService({this.result});

  /// `null` = kamera siap.
  final CameraOpenResult? result;

  @override
  Future<CameraOpenResult> open() async =>
      result ?? CameraReady(_FakeCameraSession());
}

class _FakeCameraSession implements CameraSession {
  @override
  Widget buildPreview() => DecoratedBox(
    decoration: const BoxDecoration(gradient: AppColors.cameraGradient),
    child: Center(
      child: PhosphorIcon(
        PhosphorIconsFill.user,
        size: 96,
        color: Colors.white.withValues(alpha: .25),
      ),
    ),
  );

  @override
  Future<String> capture() async =>
      'mock://selfie-${DateTime.now().millisecondsSinceEpoch}.jpg';

  @override
  Future<void> dispose() async {}
}
