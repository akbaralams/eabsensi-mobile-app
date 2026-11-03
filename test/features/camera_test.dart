import 'package:eabsensi/features/punch/data/fake_camera_service.dart';
import 'package:eabsensi/features/punch/domain/camera.dart';
import 'package:eabsensi/features/punch/presentation/punch_photo_page.dart';
import 'package:eabsensi/features/punch/presentation/punch_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// Hasil `open()` berurutan (yang terakhir diulang); lensa yang diminta
/// dicatat.
class _ScriptedCamera implements CameraService {
  _ScriptedCamera(this._results);

  final List<CameraOpenResult Function(CameraLens)> _results;
  final lenses = <CameraLens>[];

  int get opens => lenses.length;

  @override
  Future<CameraOpenResult> open({CameraLens lens = CameraLens.front}) async {
    final i = opens < _results.length ? opens : _results.length - 1;
    lenses.add(lens);
    return _results[i](lens);
  }
}

CameraOpenResult _ready(CameraLens lens) =>
    CameraReady(FakeCameraSession(lens: lens));

class _BrokenShutterSession extends FakeCameraSession {
  @override
  Future<String> capture() async => throw StateError('shutter rusak');
}

Future<void> _toPhotoPage(WidgetTester tester) async {
  await tester.tap(find.text('Check In').first);
  await settle(tester);
  await tester.tap(find.text('Konfirmasi Check In'));
  await settle(tester);
}

Future<void> _shootManually(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('shutter')));
  await settle(tester);
}

void main() {
  group('pemetaan galat plugin', () {
    test('kode CameraAccess* berarti izin ditolak', () {
      expect(cameraFailureFor('CameraAccessDenied', null), isA<CameraDenied>());
      expect(
        cameraFailureFor('CameraAccessDeniedWithoutPrompt', 'x'),
        isA<CameraDenied>(),
      );
      expect(
        cameraFailureFor('CameraAccessRestricted', null),
        isA<CameraDenied>(),
      );
    });

    test('galat lain: kamera tidak tersedia dengan pesan', () {
      final r = cameraFailureFor(
        'cameraInUse',
        'Kamera dipakai aplikasi lain.',
      );
      expect(r, isA<CameraUnavailable>());
      expect((r as CameraUnavailable).message, 'Kamera dipakai aplikasi lain.');
      expect(
        (cameraFailureFor('x', null) as CameraUnavailable).message,
        'Kamera tidak dapat dibuka.',
      );
    });
  });

  group('wajah terhadap bingkai', () {
    const guide = Rect.fromLTWH(.2, .3, .6, .4);

    test('tanpa wajah: none', () {
      expect(faceStatusFor(const [], guide), FaceStatus.none);
    });

    test('wajah utuh di dalam bingkai: inside', () {
      expect(
        faceStatusFor(const [Rect.fromLTWH(.4, .4, .2, .15)], guide),
        FaceStatus.inside,
      );
    });

    test('titik tengah di luar bingkai: outside', () {
      expect(
        faceStatusFor(const [Rect.fromLTWH(0, 0, .2, .15)], guide),
        FaceStatus.outside,
      );
    });

    test('tengah di dalam tapi tumpang tindih < 60%: outside', () {
      // Wajah besar melebihi bingkai: hanya sebagian kecil yang di dalam.
      expect(
        faceStatusFor(const [Rect.fromLTWH(-.2, .1, 1.4, .8)], guide),
        FaceStatus.outside,
      );
    });

    test('salah satu dari beberapa wajah di dalam: inside', () {
      expect(
        faceStatusFor(const [
          Rect.fromLTWH(0, 0, .1, .1),
          Rect.fromLTWH(.45, .45, .1, .1),
        ], guide),
        FaceStatus.inside,
      );
    });

    test('coverMap: sisi yang terpotong keluar dari 0..1', () {
      // Gambar 3:4 ditampilkan cover di kotak 1:2 -> lebar terpotong.
      final r = coverMap(
        const Rect.fromLTRB(0, 0, 1, 1),
        const Size(300, 400),
        const Size(100, 200),
      );
      expect(r.top, closeTo(0, 1e-9));
      expect(r.bottom, closeTo(1, 1e-9));
      expect(r.left, lessThan(0));
      expect(r.right, greaterThan(1));
      expect(r.center.dx, closeTo(.5, 1e-9));
    });
  });

  testWidgets(
    'wajah di bingkai: jepret manual -> konfirmasi -> kirim -> hasil',
    (tester) async {
      final container = await pumpApp(tester);
      await _toPhotoPage(tester);
      expect(find.text('LANGKAH 2 DARI 3'), findsOneWidget);
      expect(find.text('WAJAH TERDETEKSI'), findsOneWidget);

      await _shootManually(tester);
      expect(find.text('LANGKAH 3 DARI 3'), findsOneWidget);
      expect(find.text('Konfirmasi Check In'), findsOneWidget);
      expect(find.text('Dicatat oleh server saat dikirim'), findsOneWidget);
      expect(
        container.read(punchFlowProvider).photoPath,
        startsWith('mock://selfie-'),
      );

      await tester.tap(find.byKey(const Key('submit-photo')));
      await settle(tester);
      expect(find.byKey(const Key('result-time')), findsOneWidget);
    },
  );

  testWidgets('jepret otomatis setelah wajah stabil di bingkai', (
    tester,
  ) async {
    await pumpApp(tester);
    await _toPhotoPage(tester);
    expect(find.byKey(const Key('submit-photo')), findsNothing);

    await tester.pump(autoCaptureDelay);
    await settle(tester);
    expect(find.byKey(const Key('submit-photo')), findsOneWidget);
  });

  testWidgets('tanpa wajah: tombol nonaktif dan tidak jepret otomatis', (
    tester,
  ) async {
    await pumpApp(tester, camera: const FakeCameraService(faces: []));
    await _toPhotoPage(tester);
    expect(find.text('WAJAH TIDAK TERDETEKSI'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shutter')), warnIfMissed: false);
    await tester.pump(autoCaptureDelay * 2);
    await settle(tester);
    expect(find.byKey(const Key('submit-photo')), findsNothing);
    expect(find.text('LANGKAH 2 DARI 3'), findsOneWidget);
  });

  testWidgets('wajah di luar bingkai: minta disejajarkan', (tester) async {
    await pumpApp(
      tester,
      camera: const FakeCameraService(faces: [Rect.fromLTWH(0, 0, .12, .08)]),
    );
    await _toPhotoPage(tester);
    expect(find.text('SEJAJARKAN WAJAH KE BINGKAI'), findsOneWidget);
    await tester.tap(find.byKey(const Key('shutter')), warnIfMissed: false);
    await settle(tester);
    expect(find.byKey(const Key('submit-photo')), findsNothing);
  });

  testWidgets('Foto Ulang: foto dibuang dan kamera dibuka lagi', (
    tester,
  ) async {
    final camera = _ScriptedCamera([_ready]);
    final container = await pumpApp(tester, camera: camera);
    await _toPhotoPage(tester);
    await _shootManually(tester);
    expect(container.read(punchFlowProvider).photoPath, isNotNull);

    await tester.tap(find.byKey(const Key('retake')));
    await settle(tester);
    expect(find.text('LANGKAH 2 DARI 3'), findsOneWidget);
    expect(container.read(punchFlowProvider).photoPath, isNull);
    expect(camera.opens, 2);
  });

  testWidgets('Balik kamera membuka lensa belakang', (tester) async {
    final camera = _ScriptedCamera([_ready]);
    await pumpApp(tester, camera: camera);
    await _toPhotoPage(tester);
    await tester.tap(find.byKey(const Key('flip')));
    await settle(tester);
    expect(camera.lenses, [CameraLens.front, CameraLens.back]);
  });

  testWidgets('lampu senter tidak didukung: pesan singkat', (tester) async {
    await pumpApp(
      tester,
      camera: const FakeCameraService(torchSupported: false),
    );
    await _toPhotoPage(tester);
    await tester.tap(find.byKey(const Key('torch')));
    await settle(tester);
    expect(
      find.text('Lampu senter tidak tersedia di kamera ini.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'izin ditolak: pesan jelas, shutter nonaktif, coba lagi berhasil',
    (tester) async {
      final camera = _ScriptedCamera([(_) => const CameraDenied(), _ready]);
      await pumpApp(tester, camera: camera);
      await _toPhotoPage(tester);

      expect(find.text('Izin kamera ditolak'), findsOneWidget);
      expect(
        find.textContaining('Pengaturan > Aplikasi > eAbsensi'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('shutter')), warnIfMissed: false);
      await settle(tester);
      expect(find.text('LANGKAH 2 DARI 3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('camera-retry')));
      await settle(tester);
      expect(camera.opens, 2);
      expect(find.text('WAJAH TERDETEKSI'), findsOneWidget);
    },
  );

  testWidgets('kamera tidak tersedia: pesan apa adanya', (tester) async {
    await pumpApp(
      tester,
      camera: const FakeCameraService(
        result: CameraUnavailable('Perangkat ini tidak memiliki kamera.'),
      ),
    );
    await _toPhotoPage(tester);
    expect(find.text('Kamera tidak tersedia'), findsOneWidget);
    expect(find.text('Perangkat ini tidak memiliki kamera.'), findsOneWidget);
  });

  testWidgets('gagal mengambil foto: pesan di layar, tetap di kamera', (
    tester,
  ) async {
    await pumpApp(
      tester,
      camera: FakeCameraService(result: CameraReady(_BrokenShutterSession())),
    );
    await _toPhotoPage(tester);
    await _shootManually(tester);
    expect(find.text('Gagal mengambil foto. Coba lagi.'), findsOneWidget);
    expect(find.byKey(const Key('submit-photo')), findsNothing);
  });

  testWidgets('layar kecil dengan teks besar: tidak overflow', (tester) async {
    await pumpApp(tester);
    await _toPhotoPage(tester);
    tester.view.physicalSize = const Size(360, 640) * 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('shutter')), findsOneWidget);
    await _shootManually(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('LANGKAH 3 DARI 3'), findsOneWidget);
  });
}
