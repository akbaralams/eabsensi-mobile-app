import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../domain/camera.dart';

/// Wajah kecil di tengah pratinjau: jatuh di dalam bingkai.
const fakeFaceCentered = [Rect.fromLTWH(.4, .45, .2, .12)];

/// Kamera palsu untuk test (dan perangkat tanpa kamera): pratinjau gradien,
/// wajah tetap, dan foto bernama `mock://selfie-....jpg`.
class FakeCameraService implements CameraService {
  const FakeCameraService({
    this.result,
    this.faces = fakeFaceCentered,
    this.canFlip = true,
    this.torchSupported = true,
  });

  /// `null` = kamera siap.
  final CameraOpenResult? result;

  /// Wajah yang dilaporkan sekali saat pratinjau dipasang.
  final List<Rect> faces;

  final bool canFlip;
  final bool torchSupported;

  @override
  Future<CameraOpenResult> open({CameraLens lens = CameraLens.front}) async =>
      result ??
      CameraReady(
        FakeCameraSession(
          lens: lens,
          faceBoxes: faces,
          canFlip: canFlip,
          torchSupported: torchSupported,
        ),
      );
}

class FakeCameraSession implements CameraSession {
  FakeCameraSession({
    this.lens = CameraLens.front,
    this.faceBoxes = fakeFaceCentered,
    this.canFlip = true,
    this.torchSupported = true,
  });

  @override
  final CameraLens lens;

  @override
  final bool canFlip;

  final List<Rect> faceBoxes;
  final bool torchSupported;

  @override
  Stream<List<Rect>> get faces => Stream.value(faceBoxes);

  @override
  ValueListenable<String>? get diagnostics => null;

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
  Future<bool> setTorch(bool on) async => torchSupported;

  @override
  Future<String> capture() async =>
      'mock://selfie-${DateTime.now().millisecondsSinceEpoch}.jpg';

  @override
  Future<void> dispose() async {}
}
