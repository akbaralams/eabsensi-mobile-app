import 'package:flutter/foundation.dart';

import '../../punch/domain/punch.dart';

/// `none`: tidak ada punch (hari ini: belum absen). `unknown`: hari belum
/// dimuat dari server (kontrak tanpa rekap bulanan; dimuat saat dibuka).
enum DayStatus { present, late, absent, pending, none, unknown }

@immutable
class DayRecord {
  const DayRecord({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.isToday = false,
    this.punches = const [],
  });

  final DateTime date;
  final DayStatus status;

  /// "HH:mm"
  final String? checkIn;
  final String? checkOut;
  final bool isToday;

  /// Punch hari itu dari server bila sudah dimuat (detail hari).
  final List<Punch> punches;
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

  MonthHistory mapDays(DayRecord Function(DayRecord day) f) => MonthHistory(
    year: year,
    month: month,
    days: [for (final d in days) f(d)],
  );

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
  if (punches.isEmpty && date.weekday > DateTime.friday) return null;
  return dayFromPunches(date, punches, isToday: true);
}

/// Satu hari dari punch server, tanpa klasifikasi buatan klien: ada punch
/// menunggu -> Menunggu, ada punch disetujui -> Hadir, selain itu tidak ada
/// punch. Punch ditolak tidak dihitung (tetap tampil di detail hari).
DayRecord dayFromPunches(
  DateTime date,
  List<Punch> punches, {
  bool isToday = false,
}) {
  final day = DateTime(date.year, date.month, date.day);
  final counted = [
    for (final p in punches)
      if (p.status != PunchStatus.rejected) p,
  ];
  if (counted.isEmpty) {
    return DayRecord(
      date: day,
      status: DayStatus.none,
      isToday: isToday,
      punches: punches,
    );
  }
  String hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final pending = counted.any((p) => p.status == PunchStatus.pending);
  return DayRecord(
    date: day,
    status: pending ? DayStatus.pending : DayStatus.present,
    checkIn: hhmm(counted.first.punchedAt),
    checkOut: counted.length >= 2 ? hhmm(counted.last.punchedAt) : null,
    isToday: isToday,
    punches: punches,
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

  /// Hari-hari bulan itu. Tanpa rekap bulanan, hari yang belum dimuat berstatus
  /// [DayStatus.unknown] (tanpa memanggil server per hari).
  Future<MonthHistory> month(int year, int month);

  /// Detail satu hari, dimuat saat dibuka.
  Future<DayRecord> day(DateTime date);
}
