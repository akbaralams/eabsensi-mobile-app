import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/camera.dart';

/// Kamera perangkat lewat paket `camera`, dengan deteksi wajah ML Kit di
/// perangkat (tidak ada data wajah yang dikirim ke mana pun). Izin kamera
/// diminta oleh plugin saat `initialize()` pertama kali.
class RealCameraService implements CameraService {
  const RealCameraService();

  @override
  Future<CameraOpenResult> open({CameraLens lens = CameraLens.front}) async {
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return const CameraUnavailable('Perangkat ini tidak memiliki kamera.');
      }
      final wanted = lens == CameraLens.front
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final description = cameras.firstWhere(
        (c) => c.lensDirection == wanted,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      final session = _RealCameraSession(
        controller,
        lens: description.lensDirection == CameraLensDirection.front
            ? CameraLens.front
            : CameraLens.back,
        canFlip: cameras.length > 1,
      );
      await session.startDetection();
      return CameraReady(session);
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
  _RealCameraSession(
    this._controller, {
    required this.lens,
    required this.canFlip,
  });

  final CameraController _controller;
  final _detector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
  final _faces = StreamController<List<Rect>>.broadcast();

  @override
  final CameraLens lens;

  @override
  final bool canFlip;

  /// Ukuran kotak pratinjau terakhir (dari [buildPreview]).
  Size _box = Size.zero;
  bool _streaming = false;
  bool _busy = false;
  bool _closed = false;

  @override
  Stream<List<Rect>> get faces => _faces.stream;

  Future<void> startDetection() async {
    if (_streaming || _closed) return;
    await _controller.startImageStream(_onFrame);
    _streaming = true;
  }

  Future<void> _stopDetection() async {
    if (!_streaming) return;
    _streaming = false;
    try {
      await _controller.stopImageStream();
    } on Object {
      // Stream sudah berhenti.
    }
  }

  /// Satu frame diproses sekaligus; frame lain dibuang selama sibuk.
  Future<void> _onFrame(CameraImage image) async {
    if (_busy || _closed || _box.isEmpty) return;
    _busy = true;
    try {
      final rotation = _rotation();
      final input = _inputImage(image, rotation);
      if (input == null) return;
      final found = await _detector.processImage(input);
      if (_closed) return;
      final turned =
          rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg;
      final upright = turned
          ? Size(image.height.toDouble(), image.width.toDouble())
          : Size(image.width.toDouble(), image.height.toDouble());
      final mirror = lens == CameraLens.front;
      _faces.add([
        for (final face in found)
          coverMap(
            _normalize(face.boundingBox, upright, mirror: mirror),
            _portraitPreview ?? upright,
            _box,
          ),
      ]);
    } on Object {
      // Frame gagal dianalisis: lewati, frame berikutnya dicoba lagi.
    } finally {
      _busy = false;
    }
  }

  Size? get _portraitPreview {
    final size = _controller.value.previewSize;
    if (size == null) return null;
    return Size(size.shortestSide, size.longestSide);
  }

  static Rect _normalize(Rect r, Size image, {required bool mirror}) {
    final left = r.left / image.width;
    final right = r.right / image.width;
    return Rect.fromLTRB(
      mirror ? 1 - right : left,
      r.top / image.height,
      mirror ? 1 - left : right,
      r.bottom / image.height,
    );
  }

  /// Rotasi gambar kamera terhadap layar (rumus contoh resmi ML Kit).
  InputImageRotation _rotation() {
    const degrees = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };
    final sensor = _controller.description.sensorOrientation;
    final device = degrees[_controller.value.deviceOrientation] ?? 0;
    final value = lens == CameraLens.front
        ? (sensor + device) % 360
        : (sensor - device + 360) % 360;
    return InputImageRotationValue.fromRawValue(value) ??
        InputImageRotation.rotation0deg;
  }

  static InputImage? _inputImage(CameraImage image, InputImageRotation r) {
    if (image.planes.isEmpty) return null;
    final android = defaultTargetPlatform == TargetPlatform.android;
    // Android: CameraX mengirim NV21 dalam satu plane (format diminta nv21).
    if (android && image.planes.length != 1) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: r,
        format: android ? InputImageFormat.nv21 : InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Widget buildPreview() {
    final size = _portraitPreview;
    if (size == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        _box = constraints.biggest;
        return ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0x1F000000),
                    BlendMode.darken,
                  ),
                  child: CameraPreview(_controller),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Future<bool> setTorch(bool on) async {
    try {
      await _controller.setFlashMode(on ? FlashMode.torch : FlashMode.off);
      return true;
    } on Object {
      return false;
    }
  }

  static const _maxShortSide = 480;

  @override
  Future<String> capture() async {
    await _stopDetection();
    try {
      final raw = (await _controller.takePicture()).path;
      return await _compress(raw);
    } on Object {
      if (!_closed) await startDetection();
      rethrow;
    }
  }

  /// Satu-satunya kompresi sebelum unggah: JPEG kualitas 80, sisi pendek
  /// paling banyak [_maxShortSide] px (pratinjau `medium` ≈ 480x720 potret,
  /// jadi sisi terpanjang ±720 px). Target ±50-100 KB, jauh di bawah batas
  /// 4 MB kontrak; ukuran yang terkirim tercatat di log debug.
  static Future<String> _compress(String raw) async {
    final dot = raw.lastIndexOf('.');
    final target = '${dot < 0 ? raw : raw.substring(0, dot)}_c.jpg';
    try {
      final out = await FlutterImageCompress.compressAndGetFile(
        raw,
        target,
        quality: 80,
        // Plugin memperkecil hingga kedua sisi >= nilai ini (rasio tetap):
        // sisi pendek jadi 480 bila kamera memberi gambar lebih besar.
        minWidth: _maxShortSide,
        minHeight: _maxShortSide,
      );
      if (out == null) return raw;
      try {
        await File(raw).delete();
      } on Object {
        // Berkas mentah tertinggal di folder sementara; tidak fatal.
      }
      return out.path;
    } on Object {
      return raw;
    }
  }

  @override
  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    await _stopDetection();
    await _controller.dispose();
    await _detector.close();
    await _faces.close();
  }
}
