import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import '../domain/camera.dart';

/// Kamera depan perangkat lewat paket `camera`. Izin kamera diminta oleh
/// plugin saat `initialize()` pertama kali.
class RealCameraService implements CameraService {
  const RealCameraService();

  @override
  Future<CameraOpenResult> open() async {
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return const CameraUnavailable('Perangkat ini tidak memiliki kamera.');
      }
      final description = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      return CameraReady(_RealCameraSession(controller));
    } on CameraException catch (e) {
      await controller?.dispose();
      return cameraFailureFor(e.code, e.description);
    } on Object {
      await controller?.dispose();
      return const CameraUnavailable('Kamera tidak dapat dibuka.');
    }
  }
}

class _RealCameraSession implements CameraSession {
  _RealCameraSession(this._controller);

  final CameraController _controller;

  @override
  Widget buildPreview() {
    final size = _controller.value.previewSize;
    if (size == null) return const SizedBox.shrink();
    // Layar dikunci potret: sisi pendek = lebar pratinjau.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.shortestSide,
          height: size.longestSide,
          child: CameraPreview(_controller),
        ),
      ),
    );
  }

  @override
  Future<String> capture() async => (await _controller.takePicture()).path;

  @override
  Future<void> dispose() => _controller.dispose();
}
