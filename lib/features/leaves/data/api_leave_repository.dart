import 'package:eabsensi_api/eabsensi_api.dart' as api;

import '../../../core/api/api_client.dart';
import '../../../core/api/mappers.dart';
import '../../../core/network/api_failure.dart';
import '../domain/leave.dart';

/// `GET /leaves` (`data` + `types`) dan `POST /leaves` (JSON).
class ApiLeaveRepository implements LeaveRepository {
  ApiLeaveRepository(this._api);

  final ApiClient _api;

  @override
  Future<LeaveOverview> load() =>
      _api.send(() => _api.leaves.listLeaves(), (r) {
        if (r is! api.ListLeavesResponse200) return null;
        // Kontrak: tanggal mulai terbaru dulu; diurutkan lagi agar pasti.
        final leaves = r.body.data.map(leaveFromApi).toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate));
        return LeaveOverview(
          leaves: List.unmodifiable(leaves),
          types: List.unmodifiable(r.body.types.map(leaveTypeFromApi)),
        );
      });

  /// Field wajib yang kosong diperiksa server (422 `errors` per field); yang
  /// dicek di sini hanya agar request bisa dibentuk.
  @override
  Future<Leave> create(LeaveDraft draft) {
    final type = draft.attendanceStatusId;
    final start = draft.startDate;
    final end = draft.endDate;
    if (type == null || start == null || end == null) {
      return Future.error(
        ValidationFailure('Data yang diberikan tidak valid.', {
          if (type == null)
            'attendance_status_id': ['Jenis pengajuan wajib dipilih.'],
          if (start == null) 'start_date': ['Tanggal mulai wajib diisi.'],
          if (end == null) 'end_date': ['Tanggal selesai wajib diisi.'],
        }),
      );
    }
    final reason = draft.reason?.trim();
    return _api.send(
      () => _api.leaves.createLeave(
        body: api.LeaveRequest(
          attendanceStatusId: type,
          startDate: dateToApi(start),
          endDate: dateToApi(end),
          reason: reason == null || reason.isEmpty ? null : reason,
        ),
      ),
      (r) => r is api.CreateLeaveResponse201 ? leaveFromApi(r.body.data) : null,
    );
  }
}
