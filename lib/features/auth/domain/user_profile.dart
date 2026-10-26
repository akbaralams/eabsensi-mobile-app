import 'package:flutter/foundation.dart';

@immutable
class EmployeeSummary {
  const EmployeeSummary({
    required this.id,
    required this.employeeNumber,
    required this.name,
    required this.department,
  });

  final int id;
  final String employeeNumber;
  final String name;
  final String? department;
}

/// Profil dari `/me`. Flag `requiresPhoto` dan `requiresApproval` diikuti apa
/// adanya, tidak di-hardcode.
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.employee,
    required this.timezone,
    required this.requiresPhoto,
    required this.requiresApproval,
    this.isSupervisor = false,
  });

  final int id;
  final String name;
  final String username;
  final EmployeeSummary? employee;
  final String timezone;
  final bool requiresPhoto;
  final bool requiresApproval;

  /// Belum ada di kontrak API. Selalu `false` pada implementasi nyata sampai
  /// kontrak menyediakan peran atasan; hanya mock yang mengisinya.
  final bool isSupervisor;
}
