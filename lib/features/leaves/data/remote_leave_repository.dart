import '../../../core/format/id_format.dart';
import '../../../core/network/api_error_mapper.dart';
import '../../../core/network/api_failure.dart';
import '../../../core/network/api_time.dart';
import '../../../core/network/generated/export.dart' as api;
import '../domain/leave.dart';

/// Client nyata: `GET /leaves` dan `POST /leaves`. Aturan (rentang maksimal,
/// tumpang tindih, urutan tanggal) diputuskan server.
class RemoteLeaveRepository implements LeaveRepository {
  RemoteLeaveRepository(this._api);

  final api.CutiApi _api;

  @override
  Future<LeaveOverview> load() => apiCall(() async {
    final res = await _api.listLeaves();
    return LeaveOverview(
      leaves: res.data.map(leaveFromApi).toList(growable: false),
      types: res.types
          .map((o) => LeaveType(id: o.id, code: o.code, name: o.name))
          .toList(growable: false),
    );
  });

  @override
  Future<Leave> create(LeaveDraft draft) {
    final typeId = draft.attendanceStatusId;
    final start = draft.startDate;
    final end = draft.endDate;
    // Field wajib yang belum diisi tidak bisa dikirim; pesannya per field,
    // sama bentuknya dengan galat validasi server.
    final missing = <String, List<String>>{
      if (typeId == null)
        'attendance_status_id': ['Jenis pengajuan wajib dipilih.'],
      if (start == null) 'start_date': ['Tanggal mulai wajib diisi.'],
      if (end == null) 'end_date': ['Tanggal selesai wajib diisi.'],
    };
    if (missing.isNotEmpty) {
      return Future.error(
        ValidationFailure('Data yang diberikan tidak valid.', missing),
      );
    }
    final reason = draft.reason?.trim();
    return apiCall(() async {
      final res = await _api.createLeave(
        body: api.LeaveRequest(
          attendanceStatusId: typeId!,
          startDate: IdFormat.apiDate(start!),
          endDate: IdFormat.apiDate(end!),
          reason: reason == null || reason.isEmpty ? null : reason,
        ),
      );
      return leaveFromApi(res.data);
    });
  }
}

Leave leaveFromApi(api.Leave l) => Leave(
  id: l.id,
  type: l.type,
  attendanceStatusId: l.attendanceStatusId,
  startDate: parseApiDate(l.startDate),
  endDate: parseApiDate(l.endDate),
  reason: l.reason,
  status: switch (l.status) {
    api.LeaveStatus.approved => LeaveStatus.approved,
    api.LeaveStatus.rejected => LeaveStatus.rejected,
    api.LeaveStatus.cancelled => LeaveStatus.cancelled,
    _ => LeaveStatus.pending,
  },
  statusLabel: l.statusLabel,
);
