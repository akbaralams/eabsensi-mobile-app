import 'package:flutter/foundation.dart';

enum LeaveStatus { pending, approved, rejected, cancelled }

/// Pengelompokan tampilan jenis cuti. Kontrak belum punya field kategori, jadi
/// pengelompokan memakai awalan `code` (lihat docs/design/DEVIATIONS.md).
enum LeaveCategory {
  cuti('Cuti', 'C-'),
  izin('Izin', 'I-'),
  dinas('Dinas Luar', 'D-'),
  lainnya('Lainnya', '');

  const LeaveCategory(this.label, this.codePrefix);

  final String label;
  final String codePrefix;

  static LeaveCategory forCode(String code) {
    for (final c in values) {
      if (c.codePrefix.isNotEmpty && code.startsWith(c.codePrefix)) return c;
    }
    return lainnya;
  }

  static LeaveCategory byName(String? name) =>
      values.firstWhere((c) => c.name == name, orElse: () => cuti);
}

@immutable
class LeaveType {
  const LeaveType({required this.id, required this.code, required this.name});

  final int id;
  final String code;
  final String name;

  LeaveCategory get category => LeaveCategory.forCode(code);
}

@immutable
class Leave {
  const Leave({
    required this.id,
    required this.type,
    required this.attendanceStatusId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.statusLabel,
  });

  final int id;
  final String type;
  final int attendanceStatusId;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final LeaveStatus status;
  final String statusLabel;
}

@immutable
class LeaveOverview {
  const LeaveOverview({required this.leaves, required this.types});

  final List<Leave> leaves;
  final List<LeaveType> types;
}

@immutable
class LeaveDraft {
  const LeaveDraft({
    required this.attendanceStatusId,
    required this.startDate,
    required this.endDate,
    this.reason,
  });

  final int? attendanceStatusId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reason;
}

abstract class LeaveRepository {
  Future<LeaveOverview> load();

  /// 201 -> `Leave` berstatus pending. 422 aturan -> `RuleRejectedFailure`,
  /// 422 validasi -> `ValidationFailure`.
  Future<Leave> create(LeaveDraft draft);
}
