import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum CameraLens { front, back }

/// Sesi kamera yang sudah terbuka: pratinjau langsung, deteksi wajah, dan
/// pengambilan foto.
abstract class CameraSession {
  CameraLens get lens;

  /// `true` bila perangkat punya lebih dari satu kamera.
  bool get canFlip;

  /// Pratinjau yang mengisi penuh area induknya (mode cover).
  Widget buildPreview();

  /// Kotak wajah yang terlihat, ternormalisasi 0..1 terhadap kotak pratinjau
  /// ([buildPreview]) dan sudah dicerminkan seperti pratinjau kamera depan.
  Stream<List<Rect>> get faces;

  /// Menyalakan/mematikan lampu senter. `false` bila kamera ini tidak punya.
  Future<bool> setTorch(bool on);

  /// Mengambil foto dan mengembalikan path berkas JPG (sudah dikompres).
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
  /// Meminta izin (bila perlu) dan membuka kamera [lens] (bila tidak ada,
  /// kamera pertama).
  Future<CameraOpenResult> open({CameraLens lens = CameraLens.front});
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

enum FaceStatus {
  /// Tidak ada wajah terlihat.
  none,

  /// Ada wajah, tapi belum di dalam bingkai.
  outside,

  /// Wajah di dalam bingkai: boleh memotret.
  inside,
}

/// Memetakan kotak ternormalisasi pada gambar tegak berukuran [image] ke
/// kotak ternormalisasi pada [box] yang menampilkan gambar itu dengan
/// `BoxFit.cover` (bagian yang terpotong keluar dari 0..1).
Rect coverMap(Rect normalized, Size image, Size box) {
  if (image.isEmpty || box.isEmpty) return normalized;
  final scale = math.max(box.width / image.width, box.height / image.height);
  final shown = Size(image.width * scale, image.height * scale);
  final dx = (box.width - shown.width) / 2;
  final dy = (box.height - shown.height) / 2;
  return Rect.fromLTRB(
    (dx + normalized.left * shown.width) / box.width,
    (dy + normalized.top * shown.height) / box.height,
    (dx + normalized.right * shown.width) / box.width,
    (dy + normalized.bottom * shown.height) / box.height,
  );
}

/// Status wajah terhadap bingkai [guide] (koordinat sama dengan [faces]).
/// Wajah dianggap di dalam bila titik tengahnya di dalam bingkai dan
/// sedikitnya 60% luasnya tumpang tindih dengan bingkai.
FaceStatus faceStatusFor(List<Rect> faces, Rect guide) {
  if (faces.isEmpty) return FaceStatus.none;
  for (final face in faces) {
    final area = face.width * face.height;
    if (area <= 0 || !guide.contains(face.center)) continue;
    final overlap = face.intersect(guide);
    final overlapArea = overlap.width <= 0 || overlap.height <= 0
        ? 0.0
        : overlap.width * overlap.height;
    if (overlapArea / area >= .6) return FaceStatus.inside;
  }
  return FaceStatus.outside;
}
