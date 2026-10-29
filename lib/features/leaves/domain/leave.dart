import 'package:flutter/foundation.dart';

enum LeaveStatus { pending, approved, rejected, cancelled }

/// Pengelompokan tampilan jenis cuti. Kontrak belum punya field kategori di
/// `types[]` (diusulkan ke repo API), jadi kode jenis bawaan dipetakan di satu
/// tempat ini: `CUTI` -> Cuti, `IZIN` dan `SAKIT` -> Izin, `DINAS` -> Dinas
/// Luar, kode lain -> Lainnya (lihat docs/design/DEVIATIONS.md).
enum LeaveCategory {
  cuti('Cuti'),
  izin('Izin'),
  dinas('Dinas Luar'),
  lainnya('Lainnya');

  const LeaveCategory(this.label);

  final String label;

  static const _byCode = {
    'CUTI': cuti,
    'IZIN': izin,
    'SAKIT': izin,
    'DINAS': dinas,
  };

  static LeaveCategory forCode(String code) =>
      _byCode[code.trim().toUpperCase()] ?? lainnya;

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
