/// Waktu di kontrak adalah teks ISO 8601 di zona waktu bisnis. Aplikasi
/// menampilkan jam dinding zona itu apa adanya, jadi offset (`+07:00`) tidak
/// dikonversi ke zona perangkat. Hasilnya `DateTime` tanpa zona (jam dinding).
library;

final _iso = RegExp(
  r'^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2}))?)?',
);

DateTime _parse(String text) {
  final m = _iso.firstMatch(text);
  if (m == null) throw FormatException('Format waktu tidak dikenal', text);
  int g(int i) => int.parse(m.group(i) ?? '0');
  return DateTime(g(1), g(2), g(3), g(4), g(5), g(6));
}

/// `2026-10-25T07:58:12+07:00` -> 25 Okt 2026 07:58:12 (jam dinding bisnis).
DateTime parseBusinessDateTime(String text) => _parse(text);

/// `2026-10-25` -> tengah malam tanggal itu.
DateTime parseApiDate(String text) {
  final d = _parse(text);
  return DateTime(d.year, d.month, d.day);
}
