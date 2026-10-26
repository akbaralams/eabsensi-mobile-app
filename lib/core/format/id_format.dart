/// Format tanggal/waktu bahasa Indonesia tanpa bergantung pada data locale.
abstract final class IdFormat {
  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String dayName(DateTime d) => _days[d.weekday - 1];
  static String monthName(int month) => _months[month - 1];

  /// "Senin, 26 Oktober 2026"
  static String longDate(DateTime d) =>
      '${dayName(d)}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  /// "26 Okt 2026"
  static String shortDate(DateTime d) =>
      '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

  /// "Oktober 2026"
  static String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  /// "07:55"
  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// "07.30" (gaya penulisan Indonesia)
  static String timeDot(DateTime d) => time(d).replaceFirst(':', '.');

  /// "yyyy-MM-dd" untuk kontrak API.
  static String apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Salam per jam: < 11 pagi, < 15 siang, < 18 sore, selain itu malam.
  static String greeting(DateTime d) {
    if (d.hour < 11) return 'Selamat pagi,';
    if (d.hour < 15) return 'Selamat siang,';
    if (d.hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }
}
