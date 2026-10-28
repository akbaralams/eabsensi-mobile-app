import 'package:flutter/foundation.dart';

import '../../punch/domain/punch.dart';

enum DayPhase { none, checkedIn, pending, checkedOut }

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
  });

  factory AttendanceSummary.from(List<Punch> punches) {
    if (punches.isEmpty) return const AttendanceSummary(phase: DayPhase.none);
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
    );
  }

  final DayPhase phase;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final bool hasPending;
  final int count;

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
