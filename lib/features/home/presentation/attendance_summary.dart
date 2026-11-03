import 'package:flutter/foundation.dart';

import '../../punch/domain/punch.dart';

enum DayPhase { none, checkedIn, pending, checkedOut }

/// Klasifikasi kehadiran dari server. Kontrak belum menyediakannya (tidak ada
/// jadwal di `/me`), jadi klien tidak boleh menentukannya sendiri; tampilannya
/// sudah siap dan hanya menyala bila nilai ini diisi dari server.
enum AttendanceFlag { late, absent }

/// Status gabungan yang ditampilkan di kartu Status Kehadiran.
enum AttendanceState { notYet, checkedIn, checkedOut, pending, late, absent }

/// Ringkasan absen hari ini yang diturunkan dari punch server: punch pertama =
/// masuk, punch terakhir (bila ada dua atau lebih) = keluar.
@immutable
class AttendanceSummary {
  const AttendanceSummary({
    required this.phase,
    this.checkIn,
    this.checkOut,
    this.hasPending = false,
    this.count = 0,
    this.flag,
  });

  factory AttendanceSummary.from(List<Punch> punches, {AttendanceFlag? flag}) {
    if (punches.isEmpty) {
      return AttendanceSummary(phase: DayPhase.none, flag: flag);
    }
    final first = punches.first;
    final last = punches.length >= 2 ? punches.last : null;
    final hasPending = punches.any((p) => p.status == PunchStatus.pending);
    final tail = last ?? first;
    final phase = tail.status == PunchStatus.pending
        ? DayPhase.pending
        : last == null
        ? DayPhase.checkedIn
        : DayPhase.checkedOut;
    return AttendanceSummary(
      phase: phase,
      checkIn: first.punchedAt,
      checkOut: last?.punchedAt,
      hasPending: hasPending,
      count: punches.length,
      flag: flag,
    );
  }

  final DayPhase phase;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final bool hasPending;
  final int count;
  final AttendanceFlag? flag;

  /// Klasifikasi server menang atas fase punch.
  AttendanceState get state => switch ((flag, phase)) {
    (AttendanceFlag.absent, _) => AttendanceState.absent,
    (AttendanceFlag.late, _) => AttendanceState.late,
    (_, DayPhase.none) => AttendanceState.notYet,
    (_, DayPhase.checkedIn) when hasPending => AttendanceState.pending,
    (_, DayPhase.checkedOut) when hasPending => AttendanceState.pending,
    (_, DayPhase.pending) => AttendanceState.pending,
    (_, DayPhase.checkedIn) => AttendanceState.checkedIn,
    (_, DayPhase.checkedOut) => AttendanceState.checkedOut,
  };

  /// Check Out menjadi aksi utama setelah ada punch masuk.
  bool get nextIsCheckOut => count >= 1;

  /// Durasi tampilan: masuk sampai keluar (atau sampai [now] bila belum keluar).
  Duration workDuration(DateTime now) {
    final start = checkIn;
    if (start == null) return Duration.zero;
    final end = checkOut ?? now;
    return end.isBefore(start) ? Duration.zero : end.difference(start);
  }
}
