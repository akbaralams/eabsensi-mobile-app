import 'package:eabsensi/core/device/device_label.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('deviceLabel', () {
    test('nama dari Setelan diutamakan', () {
      expect(
        deviceLabel(
          name: 'Galaxy A54 5G',
          manufacturer: 'samsung',
          model: 'SM-A546E',
        ),
        'Galaxy A54 5G',
      );
    });

    test('tanpa nama: merek + model, merek tidak diulang', () {
      expect(
        deviceLabel(name: '', manufacturer: 'samsung', model: 'SM-A546E'),
        'Samsung SM-A546E',
      );
      expect(
        deviceLabel(manufacturer: 'Xiaomi', model: 'Xiaomi 13T'),
        'Xiaomi 13T',
      );
      expect(deviceLabel(model: 'Pixel 8'), 'Pixel 8');
      expect(deviceLabel(name: ' ', manufacturer: '', model: ''), isNull);
    });
  });

  testWidgets('baris Perangkat: nama HP, ID instalasi sebagai keterangan', (
    tester,
  ) async {
    await pumpApp(
      tester,
      overrides: [
        deviceLabelProvider.overrideWith((ref) async => 'Galaxy A54 5G'),
      ],
    );
    await tester.tap(find.text('Check In').first);
    await settle(tester);

    expect(find.text('Galaxy A54 5G'), findsOneWidget);
    expect(find.textContaining('eabsensi-android-'), findsOneWidget);
  });

  testWidgets('nama HP tidak tersedia: ID instalasi saja', (tester) async {
    await pumpApp(
      tester,
      overrides: [deviceLabelProvider.overrideWith((ref) async => null)],
    );
    await tester.tap(find.text('Check In').first);
    await settle(tester);

    expect(find.textContaining('eabsensi-android-'), findsOneWidget);
  });
}
