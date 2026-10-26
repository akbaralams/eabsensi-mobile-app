import 'package:eabsensi/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aplikasi kosong tampil', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EabsensiApp()));
    expect(find.text('eAbsensi'), findsOneWidget);
  });
}
