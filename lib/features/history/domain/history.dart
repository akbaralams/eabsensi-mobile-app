import 'package:flutter/foundation.dart';

enum DayStatus { present, late, absent, pending }

@immutable
class DayRecord {
  const DayRecord({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
  });

  final DateTime date;
  final DayStatus status;

  /// "HH:mm"
  final String? checkIn;
  final String? checkOut;
}

@immutable
class MonthHistory {
  const MonthHistory({
    required this.year,
    required this.month,
    required this.days,
  });

  final int year;
  final int month;

  /// Terbaru dulu.
  final List<DayRecord> days;

  int count(DayStatus s) => days.where((d) => d.status == s).length;
}

/// Kontrak belum punya endpoint rekap bulanan (hanya `GET /punches?date=`) dan
/// klasifikasi terlambat/tidak hadir; lihat docs/design/DEVIATIONS.md.
abstract class HistoryRepository {
  Future<MonthHistory> month(int year, int month);
}
