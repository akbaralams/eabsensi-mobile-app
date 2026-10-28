import 'package:eabsensi/features/punch/data/fake_camera_service.dart';
import 'package:eabsensi/features/punch/domain/camera.dart';
import 'package:eabsensi/features/punch/presentation/punch_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// Hasil `open()` berurutan; yang terakhir diulang.
class _ScriptedCamera implements CameraService {
  _ScriptedCamera(this._results);

  final List<CameraOpenResult> _results;
  int opens = 0;

  @override
  Future<CameraOpenResult> open() async {
    final i = opens < _results.length ? opens : _results.length - 1;
    opens++;
    return _results[i];
  }
}

class _BrokenShutterSession implements CameraSession {
  @override
  Widget buildPreview() => const ColoredBox(color: Colors.black);

  @override
  Future<String> capture() async => throw StateError('shutter rusak');

  @override
  Future<void> dispose() async {}
}

Future<void> _toPhotoPage(WidgetTester tester) async {
  await tester.tap(find.text('Check In').first);
  await settle(tester);
  await tester.tap(find.text('Konfirmasi Check In'));
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

  testWidgets('kamera siap: foto diambil dan path diteruskan ke alur', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    await _toPhotoPage(tester);
    expect(find.text('Kamera siap'), findsOneWidget);
    expect(find.textContaining('Wajah terdeteksi'), findsNothing);

    await tester.tap(find.byKey(const Key('shutter')));
    await settle(tester);
    expect(find.byKey(const Key('result-time')), findsOneWidget);
    expect(
      container.read(punchFlowProvider).photoPath,
      startsWith('mock://selfie-'),
    );
  });

  testWidgets(
    'izin ditolak: pesan jelas, shutter nonaktif, coba lagi berhasil',
    (tester) async {
      final camera = _ScriptedCamera([
        const CameraDenied(),
        CameraReady(
          await const FakeCameraService().open().then(
            (r) => (r as CameraReady).session,
          ),
        ),
      ]);
      await pumpApp(tester, camera: camera);
      await _toPhotoPage(tester);

      expect(find.text('Izin kamera ditolak'), findsOneWidget);
      expect(
        find.textContaining('Pengaturan > Aplikasi > eAbsensi'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('shutter')), warnIfMissed: false);
      await settle(tester);
      expect(find.text('Ambil foto'), findsWidgets); // masih di layar foto

      await tester.tap(find.byKey(const Key('camera-retry')));
      await settle(tester);
      expect(camera.opens, 2);
      expect(find.text('Kamera siap'), findsOneWidget);
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

  testWidgets('gagal mengambil foto: pesan di layar, bisa coba lagi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      camera: FakeCameraService(result: CameraReady(_BrokenShutterSession())),
    );
    await _toPhotoPage(tester);
    await tester.tap(find.byKey(const Key('shutter')));
    await settle(tester);
    expect(find.text('Gagal mengambil foto. Coba lagi.'), findsOneWidget);
    expect(find.byKey(const Key('result-time')), findsNothing);
  });
}
