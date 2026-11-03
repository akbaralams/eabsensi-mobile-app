import '../../punch/domain/punch.dart';
import '../domain/history.dart';

/// Riwayat dari kontrak saat ini (`GET /punches?date=` saja). Daftar bulan
/// tidak memanggil server per hari (30 request per buka layar): hari-hari
/// berstatus [DayStatus.unknown] dan dimuat satu per satu saat dibuka.
/// Terlambat/Tidak Hadir tidak dikarang. Ganti sumber bulan ke
/// `GET /api/v2/attendance/monthly` setelah endpoint itu ada di repo API.
class ApiHistoryRepository implements HistoryRepository {
  ApiHistoryRepository(this._punches, {required DateTime Function() now})
    : _now = now; // ignore: prefer_initializing_formals

  final PunchRepository _punches;
  final DateTime Function() _now;

  @override
  bool get supportsClassification => false;

  @override
  Future<MonthHistory> month(int year, int month) async {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(year, month + 1, 0);
    return MonthHistory(
      year: year,
      month: month,
      days: [
        for (var d = last.day; d >= 1; d--)
          if (DateTime(year, month, d).isBefore(today))
            DayRecord(
              date: DateTime(year, month, d),
              status: DayStatus.unknown,
            ),
      ],
    );
  }

  @override
  Future<DayRecord> day(DateTime date) async {
    final now = _now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    return dayFromPunches(date, await _punches.list(date), isToday: isToday);
  }
}
