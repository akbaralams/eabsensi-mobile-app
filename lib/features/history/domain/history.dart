import 'package:flutter/foundation.dart';

import '../../punch/domain/punch.dart';

/// `none` hanya untuk hari ini bila belum ada punch.
enum DayStatus { present, late, absent, pending, none }

@immutable
class DayRecord {
  const DayRecord({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.isToday = false,
  });

  final DateTime date;
  final DayStatus status;

  /// "HH:mm"
  final String? checkIn;
  final String? checkOut;
  final bool isToday;
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

  MonthHistory withToday(DayRecord today) => MonthHistory(
    year: year,
    month: month,
    days: [today, ...days.where((d) => !d.isToday)],
  );
}

/// Baris hari ini dari punch server (kontrak: `GET /punches?date=`). `null`
/// bila belum ada punch di akhir pekan.
DayRecord? todayRecord(DateTime now, List<Punch> punches) {
  final date = DateTime(now.year, now.month, now.day);
  if (punches.isEmpty) {
    if (date.weekday > DateTime.friday) return null;
    return DayRecord(date: date, status: DayStatus.none, isToday: true);
  }
  String hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final pending = punches.any((p) => p.status == PunchStatus.pending);
  return DayRecord(
    date: date,
    status: pending ? DayStatus.pending : DayStatus.present,
    checkIn: hhmm(punches.first.punchedAt),
    checkOut: punches.length >= 2 ? hhmm(punches.last.punchedAt) : null,
    isToday: true,
  );
}

/// Bulan terawal yang bisa dibuka (12 bulan ke belakang).
DateTime earliestHistoryMonth(DateTime now) =>
    DateTime(now.year, now.month - 12);

/// Kontrak belum punya endpoint rekap bulanan (hanya `GET /punches?date=`) dan
/// klasifikasi terlambat/tidak hadir; lihat docs/design/DEVIATIONS.md.
abstract class HistoryRepository {
  /// `false` bila server tidak mengklasifikasikan Terlambat/Tidak Hadir:
  /// klien tidak boleh mengarangnya, jadi tile dan status itu disembunyikan.
  bool get supportsClassification;

  Future<MonthHistory> month(int year, int month);
}
