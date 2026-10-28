import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_failure.dart';
import '../domain/history.dart';

/// Rekap bulanan dummy yang deterministik (hari kerja saja, sampai kemarin).
class MockHistoryRepository implements HistoryRepository {
  MockHistoryRepository(this._env);

  final MockEnv _env;

  @override
  bool get supportsClassification => true;

  @override
  Future<MonthHistory> month(int year, int month) async {
    await _env.network();
    final s = _env.scenario();
    if (s.offline) throw const OfflineFailure();
    if (s.tokenRevoked || await _env.tokens.read() == null) {
      throw const UnauthenticatedFailure();
    }
    final now = _env.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(year, month + 1, 0);
    final days = <DayRecord>[];
    for (var d = last.day; d >= 1; d--) {
      final date = DateTime(year, month, d);
      if (!date.isBefore(today)) continue;
      if (date.weekday > DateTime.friday) continue;
      final key = (year * 31 + month * 7 + d) % 13;
      if (key == 4 || key == 9) {
        days.add(DayRecord(date: date, status: DayStatus.absent));
      } else if (key == 1 || key == 6) {
        days.add(
          DayRecord(
            date: date,
            status: DayStatus.late,
            checkIn: '08:${10 + key}',
            checkOut: '16:2$key',
          ),
        );
      } else if (key == 11 &&
          date.isAfter(today.subtract(const Duration(days: 7)))) {
        days.add(
          DayRecord(
            date: date,
            status: DayStatus.pending,
            checkIn: '07:58',
            checkOut: '16:05',
          ),
        );
      } else {
        days.add(
          DayRecord(
            date: date,
            status: DayStatus.present,
            checkIn: '07:${40 + key}',
            checkOut: '16:${10 + key}',
          ),
        );
      }
    }
    return MonthHistory(year: year, month: month, days: days);
  }
}
