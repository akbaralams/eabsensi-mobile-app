import 'package:flutter/widgets.dart';

/// Sesi kamera yang sudah terbuka: pratinjau langsung dan pengambilan foto.
abstract class CameraSession {
  /// Pratinjau yang mengisi penuh area induknya (mode cover).
  Widget buildPreview();

  /// Mengambil foto dan mengembalikan path berkas JPG.
  Future<String> capture();

  Future<void> dispose();
}

sealed class CameraOpenResult {
  const CameraOpenResult();
}

final class CameraReady extends CameraOpenResult {
  const CameraReady(this.session);

  final CameraSession session;
}

/// Izin kamera ditolak pengguna (atau dibatasi perangkat).
final class CameraDenied extends CameraOpenResult {
  const CameraDenied();
}

/// Kamera tidak ada atau gagal dibuka.
final class CameraUnavailable extends CameraOpenResult {
  const CameraUnavailable(this.message);

  final String message;
}

abstract class CameraService {
  /// Meminta izin (bila perlu) dan membuka kamera depan.
  Future<CameraOpenResult> open();
}

/// Memetakan kode galat plugin kamera: `CameraAccess*` berarti izin ditolak.
CameraOpenResult cameraFailureFor(String code, String? description) {
  if (code.startsWith('CameraAccess')) return const CameraDenied();
  return CameraUnavailable(
    description == null || description.isEmpty
        ? 'Kamera tidak dapat dibuka.'
        : description,
  );
}
