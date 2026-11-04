import 'package:eabsensi/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {bool reduce = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduce),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);

/// Anak yang bisa disentuh, seperti Material/InkWell di aplikasi.
const _box = ColoredBox(
  color: Color(0xFF000000),
  child: SizedBox(width: 80, height: 80),
);

double _scale(WidgetTester t) =>
    t.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

void main() {
  group('Pressable', () {
    testWidgets('mengecil selama ditekan, kembali saat dilepas', (t) async {
      await t.pumpWidget(_host(const Pressable(child: _box)));
      expect(_scale(t), 1);

      final g = await t.startGesture(t.getCenter(find.byType(Pressable)));
      await t.pump();
      expect(_scale(t), AppMotion.pressScale);

      await g.up();
      await t.pump();
      expect(_scale(t), 1);
    });

    testWidgets('diam bila pengguna mengurangi animasi', (t) async {
      await t.pumpWidget(_host(const Pressable(child: _box), reduce: true));
      final g = await t.startGesture(t.getCenter(find.byType(Pressable)));
      await t.pump();
      expect(_scale(t), 1);
      await g.up();
    });

    testWidgets('nonaktif: tidak bereaksi', (t) async {
      await t.pumpWidget(_host(const Pressable(enabled: false, child: _box)));
      final g = await t.startGesture(t.getCenter(find.byType(Pressable)));
      await t.pump();
      expect(_scale(t), 1);
      await g.up();
    });
  });

  group('StateSwitcher', () {
    Widget switcher(String id, {bool reduce = false}) => _host(
      StateSwitcher(id: id, child: Text(id)),
      reduce: reduce,
    );

    testWidgets('id berganti: yang lama memudar selama durasi status', (
      t,
    ) async {
      await t.pumpWidget(switcher('Belum Check In'));
      await t.pumpWidget(switcher('Sudah Check In'));
      await t.pump(AppMotion.state ~/ 2);
      expect(find.text('Belum Check In'), findsOneWidget);
      expect(find.text('Sudah Check In'), findsOneWidget);

      await t.pumpAndSettle();
      expect(find.text('Belum Check In'), findsNothing);
      expect(find.text('Sudah Check In'), findsOneWidget);
    });

    testWidgets('kurangi animasi: langsung berganti', (t) async {
      await t.pumpWidget(switcher('Belum Check In', reduce: true));
      await t.pumpWidget(switcher('Sudah Check In', reduce: true));
      await t.pump();
      expect(find.text('Belum Check In'), findsNothing);
      expect(find.text('Sudah Check In'), findsOneWidget);
    });
  });
}
