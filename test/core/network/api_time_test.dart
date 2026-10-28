import 'package:eabsensi/core/network/api_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('jam dinding zona bisnis dipertahankan, offset tidak dikonversi', () {
    final t = parseBusinessDateTime('2026-10-25T07:58:12+07:00');
    expect(t, DateTime(2026, 10, 25, 7, 58, 12));
    expect(t.isUtc, isFalse);
  });

  test('offset lain tidak menggeser jam dinding', () {
    expect(
      parseBusinessDateTime('2026-10-25T07:58:12+09:00'),
      DateTime(2026, 10, 25, 7, 58, 12),
    );
    expect(
      parseBusinessDateTime('2026-10-25T07:58:12Z'),
      DateTime(2026, 10, 25, 7, 58, 12),
    );
  });

  test('tanggal saja menjadi tengah malam', () {
    expect(parseApiDate('2026-10-25'), DateTime(2026, 10, 25));
    expect(parseApiDate('2026-10-25T23:59:00+07:00'), DateTime(2026, 10, 25));
  });

  test('format tidak dikenal melempar FormatException', () {
    expect(() => parseApiDate('25/10/2026'), throwsFormatException);
    expect(() => parseBusinessDateTime(''), throwsFormatException);
  });
}
