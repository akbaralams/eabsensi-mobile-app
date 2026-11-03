/// Pemetaan model hasil generator (`package:eabsensi_api`) ke model domain.
/// Hanya lapisan data yang mengimpor file ini; UI memakai model domain.
library;

import 'package:eabsensi_api/eabsensi_api.dart' as api;
import 'package:tonik_util/tonik_util.dart' show Date;

import '../../features/auth/domain/user_profile.dart';
import '../../features/events/domain/event_item.dart';
import '../../features/leaves/domain/leave.dart';
import '../../features/punch/domain/punch.dart';
import '../clock/business_time.dart';

UserProfile profileFromApi(api.Me me) {
  final employee = switch (me.employee) {
    api.$RawMeEmployeeOneOfModelEmployeeSummary(:final value) =>
      EmployeeSummary(
        id: value.id,
        employeeNumber: value.employeeNumber,
        name: value.name,
        department: value.department,
      ),
    null => null,
  };
  final username = me.username?.trim();
  return UserProfile(
    id: me.id,
    name: me.name,
    // `username` null untuk akun lama yang masuk dengan email; kontrak tidak
    // mengirim email, jadi cadangannya nama.
    username: username == null || username.isEmpty ? me.name : username,
    employee: employee,
    timezone: me.timezone,
    requiresPhoto: me.requiresPhoto,
    requiresApproval: me.requiresApproval,
  );
}

Punch punchFromApi(api.Punch p) => Punch(
  id: p.id,
  punchedAt: serverWallClock(p.punchedAt),
  source: p.source.toJson(),
  status: switch (p.status) {
    api.PunchStatusModel.pending => PunchStatus.pending,
    api.PunchStatusModel.approved => PunchStatus.approved,
    api.PunchStatusModel.rejected => PunchStatus.rejected,
  },
  statusLabel: p.statusLabel,
  hasPhoto: p.hasPhoto,
);

EventItem eventFromApi(api.Event e) => EventItem(
  id: e.id,
  name: e.name,
  eventDate: dateFromApi(e.eventDate),
  startsAt: e.startsAt,
  endsAt: e.endsAt,
  checkedIn: e.checkedIn,
);

EventCheckIn checkInFromApi(api.EventCheckIn c) => EventCheckIn(
  eventId: c.eventId,
  checkedInAt: serverWallClock(c.checkedInAt),
);

Leave leaveFromApi(api.Leave l) => Leave(
  id: l.id,
  type: l.$type,
  attendanceStatusId: l.attendanceStatusId,
  startDate: dateFromApi(l.startDate),
  endDate: dateFromApi(l.endDate),
  reason: l.reason,
  status: switch (l.status) {
    api.LeaveStatusModel.pending => LeaveStatus.pending,
    api.LeaveStatusModel.approved => LeaveStatus.approved,
    api.LeaveStatusModel.rejected => LeaveStatus.rejected,
    api.LeaveStatusModel.cancelled => LeaveStatus.cancelled,
  },
  statusLabel: l.statusLabel,
);

LeaveType leaveTypeFromApi(api.Option o) =>
    LeaveType(id: o.id, code: o.code, name: o.name);

DateTime dateFromApi(Date d) => DateTime(d.year, d.month, d.day);

Date dateToApi(DateTime d) => Date(d.year, d.month, d.day);
