import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_failure.dart';
import '../domain/leave.dart';

class MockLeaveRepository implements LeaveRepository {
  MockLeaveRepository(this._env);

  final MockEnv _env;
  int _nextId = 50;

  static const types = [
    LeaveType(id: 1, code: 'C-TAHUNAN', name: 'Cuti Tahunan'),
    LeaveType(id: 2, code: 'C-MELAHIRKAN', name: 'Cuti Melahirkan'),
    LeaveType(id: 3, code: 'C-BESAR', name: 'Cuti Besar'),
    LeaveType(id: 4, code: 'I-SAKIT', name: 'Sakit'),
    LeaveType(id: 5, code: 'I-PRIBADI', name: 'Izin Keperluan Pribadi'),
    LeaveType(id: 6, code: 'D-DALAM', name: 'Dinas Luar Dalam Kota'),
    LeaveType(id: 7, code: 'D-LUAR', name: 'Dinas Luar Luar Kota'),
    LeaveType(id: 8, code: 'X-LAIN', name: 'Lainnya'),
  ];

  late final List<Leave> _leaves = _seed();

  List<Leave> _seed() {
    final t = _env.now();
    final today = DateTime(t.year, t.month, t.day);
    return [
      Leave(
        id: 31,
        type: 'Cuti Tahunan',
        attendanceStatusId: 1,
        startDate: today.add(const Duration(days: 14)),
        endDate: today.add(const Duration(days: 16)),
        reason: 'Acara keluarga',
        status: LeaveStatus.pending,
        statusLabel: 'Menunggu',
      ),
      Leave(
        id: 24,
        type: 'Sakit',
        attendanceStatusId: 4,
        startDate: today.subtract(const Duration(days: 20)),
        endDate: today.subtract(const Duration(days: 19)),
        reason: 'Demam',
        status: LeaveStatus.approved,
        statusLabel: 'Disetujui',
      ),
    ];
  }

  Future<void> _gate() async {
    await _env.network();
    final s = _env.scenario();
    if (s.offline) throw const OfflineFailure();
    if (s.tokenRevoked || await _env.tokens.read() == null) {
      throw const UnauthenticatedFailure();
    }
  }

  @override
  Future<LeaveOverview> load() async {
    await _gate();
    final sorted = [..._leaves]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return LeaveOverview(leaves: sorted, types: types);
  }

  @override
  Future<Leave> create(LeaveDraft draft) async {
    await _gate();
    final errors = <String, List<String>>{
      if (draft.attendanceStatusId == null ||
          !types.any((t) => t.id == draft.attendanceStatusId))
        'attendance_status_id': ['Jenis pengajuan wajib dipilih.'],
      if (draft.startDate == null) 'start_date': ['Tanggal mulai wajib diisi.'],
      if (draft.endDate == null) 'end_date': ['Tanggal selesai wajib diisi.'],
    };
    final start = draft.startDate;
    final end = draft.endDate;
    if (start != null && end != null && end.isBefore(start)) {
      errors['end_date'] = [
        'Tanggal selesai harus sama dengan atau setelah tanggal mulai.',
      ];
    }
    if (errors.isNotEmpty) {
      throw ValidationFailure('Data yang diberikan tidak valid.', errors);
    }
    final days = end!.difference(start!).inDays + 1;
    if (days > 62) {
      throw const RuleRejectedFailure('Rentang cuti maksimal 62 hari.');
    }
    final overlaps = _leaves.any(
      (l) =>
          (l.status == LeaveStatus.pending ||
              l.status == LeaveStatus.approved) &&
          !start.isAfter(l.endDate) &&
          !end.isBefore(l.startDate),
    );
    if (overlaps) {
      throw const RuleRejectedFailure(
        'Pegawai sudah punya pengajuan yang menunggu atau disetujui pada tanggal tersebut.',
      );
    }
    final type = types.firstWhere((t) => t.id == draft.attendanceStatusId);
    final leave = Leave(
      id: _nextId++,
      type: type.name,
      attendanceStatusId: type.id,
      startDate: start,
      endDate: end,
      reason: (draft.reason?.trim().isEmpty ?? true)
          ? null
          : draft.reason!.trim(),
      status: LeaveStatus.pending,
      statusLabel: 'Menunggu',
    );
    _leaves.add(leave);
    return leave;
  }
}
