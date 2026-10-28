import 'dart:math' as math;

import '../../punch/domain/punch.dart';
import '../domain/history.dart';

/// Riwayat bulanan dari `GET /punches?date=` per hari, karena kontrak belum
/// punya rekap bulanan (lihat docs/usulan-kontrak-api.md). Klasifikasi
/// Terlambat/Tidak Hadir tidak ada di server, jadi tidak dikarang: hanya hari
/// yang punya punch yang muncul.
///
/// Satu bulan = sampai 31 permintaan, sedangkan batas laju 120/menit per token
/// dipakai bersama punch. Karena itu permintaan dibatasi paralel dan hasil
/// bulan disimpan [cacheFor] untuk menghindari 429 saat pengguna berpindah bulan.
class PunchHistoryRepository implements HistoryRepository {
  PunchHistoryRepository(
    this._punches, {
    required this._now,
    this.concurrency = 4,
    this.cacheFor = const Duration(minutes: 1),
  });

  final PunchRepository _punches;
  final DateTime Function() _now;
  final int concurrency;
  final Duration cacheFor;
  final Map<(int, int), (DateTime, MonthHistory)> _cache = {};

  @override
  bool get supportsClassification => false;

  @override
  Future<MonthHistory> month(int year, int month) async {
    final now = _now();
    final cached = _cache[(year, month)];
    if (cached != null && now.difference(cached.$1) < cacheFor) {
      return cached.$2;
    }

    // Hari ini dibangun dari punch hari ini oleh provider (data lebih segar).
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(year, month + 1, 0).day;
    final dates = [
      for (var d = lastDay; d >= 1; d--)
        if (DateTime(year, month, d).isBefore(today)) DateTime(year, month, d),
    ];

    final days = <DayRecord>[];
    for (var i = 0; i < dates.length; i += concurrency) {
      final chunk = dates.sublist(i, math.min(i + concurrency, dates.length));
      final lists = await Future.wait(chunk.map(_punches.list));
      for (var j = 0; j < chunk.length; j++) {
        final record = _record(chunk[j], lists[j]);
        if (record != null) days.add(record);
      }
    }
    final result = MonthHistory(year: year, month: month, days: days);
    _cache[(year, month)] = (now, result);
    return result;
  }

  DayRecord? _record(DateTime date, List<Punch> punches) {
    final usable = punches
        .where((p) => p.status != PunchStatus.rejected)
        .toList(growable: false);
    if (usable.isEmpty) return null;
    String hhmm(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final pending = usable.any((p) => p.status == PunchStatus.pending);
    return DayRecord(
      date: date,
      status: pending ? DayStatus.pending : DayStatus.present,
      checkIn: hhmm(usable.first.punchedAt),
      checkOut: usable.length >= 2 ? hhmm(usable.last.punchedAt) : null,
    );
  }
}
