import 'package:eabsensi/core/design/design.dart';
import 'package:eabsensi/features/events/domain/event_item.dart';
import 'package:eabsensi/features/home/presentation/approval_card.dart';
import 'package:eabsensi/features/home/presentation/attendance_summary.dart';
import 'package:eabsensi/features/home/presentation/event_card.dart';
import 'package:eabsensi/features/home/presentation/status_card.dart';
import 'package:eabsensi/features/inbox/domain/inbox.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double scale = 1, ThemeMode? mode}) => MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: mode ?? ThemeMode.light,
  builder: (context, c) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: c!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: child,
    ),
  ),
);

final _in = DateTime(2026, 10, 26, 7, 58);
final _out = DateTime(2026, 10, 26, 16, 5);
final _now = DateTime(2026, 10, 26, 10, 12);

Punch _p(DateTime t, PunchStatus s) => Punch(
  id: t.hour,
  punchedAt: t,
  source: 'mobile',
  status: s,
  statusLabel: s.name,
  hasPhoto: true,
);

void main() {
  group('AttendanceSummary.state', () {
    test('menurunkan lima status dari punch server', () {
      expect(AttendanceSummary.from(const []).state, AttendanceState.notYet);
      expect(
        AttendanceSummary.from([_p(_in, PunchStatus.approved)]).state,
        AttendanceState.checkedIn,
      );
      expect(
        AttendanceSummary.from([
          _p(_in, PunchStatus.approved),
          _p(_out, PunchStatus.approved),
        ]).state,
        AttendanceState.checkedOut,
      );
      expect(
        AttendanceSummary.from([_p(_in, PunchStatus.pending)]).state,
        AttendanceState.pending,
      );
    });

    test('Terlambat dan Tidak Hadir hanya dari klasifikasi server', () {
      final punches = [_p(_in, PunchStatus.approved)];
      // Tanpa flag, jam masuk berapa pun tidak pernah menjadi Terlambat.
      expect(
        AttendanceSummary.from([
          _p(DateTime(2026, 10, 26, 11), PunchStatus.approved),
        ]).state,
        AttendanceState.checkedIn,
      );
      expect(
        AttendanceSummary.from(punches, flag: AttendanceFlag.late).state,
        AttendanceState.late,
      );
      expect(
        AttendanceSummary.from(const [], flag: AttendanceFlag.absent).state,
        AttendanceState.absent,
      );
    });
  });

  group('kartu Status Kehadiran', () {
    Future<void> pumpStatus(
      WidgetTester t,
      AttendanceSummary s, {
      String? location,
      double scale = 1,
    }) async {
      t.view
        ..physicalSize = const Size(390, 900)
        ..devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        _host(
          AttendanceStatusCard(summary: s, now: _now, locationName: location),
          scale: scale,
        ),
      );
    }

    testWidgets('belum absen: tiga sel kosong dan lokasi bila ada', (t) async {
      await pumpStatus(
        t,
        const AttendanceSummary(phase: DayPhase.none),
        location: 'Kantor Pusat',
      );
      expect(find.text('Belum Absen'), findsOneWidget);
      expect(find.text('-'), findsNWidgets(3));
      expect(find.text('Kantor Pusat'), findsOneWidget);
    });

    testWidgets('tanpa data lokasi: tidak ada tanda strip palsu', (t) async {
      await pumpStatus(t, const AttendanceSummary(phase: DayPhase.none));
      expect(find.text('Lokasi'), findsNothing);
      expect(find.byIcon(PhosphorIconsRegular.mapPin), findsNothing);
    });

    testWidgets('sudah check in: jam masuk dan durasi berjalan', (t) async {
      await pumpStatus(
        t,
        AttendanceSummary(phase: DayPhase.checkedIn, checkIn: _in, count: 1),
      );
      expect(find.text('Sudah Check In'), findsOneWidget);
      expect(find.text('07:58'), findsOneWidget);
      expect(find.text('2j 14m'), findsOneWidget);
    });

    testWidgets('sudah check out: durasi tetap, tidak ikut jam sekarang', (
      t,
    ) async {
      await pumpStatus(
        t,
        AttendanceSummary(
          phase: DayPhase.checkedOut,
          checkIn: _in,
          checkOut: _out,
          count: 2,
        ),
      );
      expect(find.text('Sudah Check Out'), findsOneWidget);
      expect(find.text('16:05'), findsOneWidget);
      expect(find.text('8j 7m'), findsOneWidget);
    });

    testWidgets('terlambat dan tidak hadir tampil dengan ikon dan teks', (
      t,
    ) async {
      await pumpStatus(
        t,
        AttendanceSummary(
          phase: DayPhase.checkedIn,
          checkIn: _in,
          count: 1,
          flag: AttendanceFlag.late,
        ),
      );
      expect(find.text('Terlambat'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsFill.clockCountdown), findsOneWidget);

      await pumpStatus(
        t,
        const AttendanceSummary(
          phase: DayPhase.none,
          flag: AttendanceFlag.absent,
        ),
      );
      await t.pump();
      expect(find.text('Tidak Hadir'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsFill.xCircle), findsOneWidget);
    });

    testWidgets('dibaca per sel oleh screen reader', (t) async {
      final handle = t.ensureSemantics();
      await pumpStatus(
        t,
        AttendanceSummary(phase: DayPhase.checkedIn, checkIn: _in, count: 1),
        location: 'Kantor Pusat',
      );
      expect(find.bySemanticsLabel('Masuk 07:58'), findsOneWidget);
      expect(find.bySemanticsLabel('Keluar belum ada'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Durasi kerja 2 jam 14 menit, masih berjalan'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Lokasi Kantor Pusat'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('teks besar: tidak overflow', (t) async {
      await pumpStatus(
        t,
        AttendanceSummary(
          phase: DayPhase.checkedOut,
          checkIn: _in,
          checkOut: _out,
          count: 2,
        ),
        location: 'Kantor Pusat Dinas Komunikasi dan Informatika',
        scale: 2,
      );
      expect(t.takeException(), isNull);
    });
  });

  group('kartu event', () {
    final event = EventItem(
      id: 1,
      name: 'Apel Kontrak',
      eventDate: DateTime(2026, 10, 26),
      startsAt: '07:00',
      endsAt: '09:00',
      checkedIn: false,
    );

    testWidgets('nama, jadwal, jumlah event, syarat, dan aksi buka', (t) async {
      var opened = 0;
      await t.pumpWidget(
        _host(
          EventCard(
            event: event,
            total: 3,
            requiresPhoto: true,
            onTap: () => opened++,
          ),
        ),
      );
      expect(find.text('Apel Kontrak'), findsOneWidget);
      expect(find.text('07.00 – 09.00'), findsOneWidget);
      expect(find.text('3 event hari ini'), findsOneWidget);
      expect(find.text('Foto wajib'), findsOneWidget);
      expect(find.text('Lokasi'), findsOneWidget);
      await t.tap(find.text('Apel Kontrak'));
      expect(opened, 1);
    });

    testWidgets('syarat foto mengikuti requires_photo, tidak di-hardcode', (
      t,
    ) async {
      await t.pumpWidget(
        _host(
          EventCard(event: event, total: 1, requiresPhoto: false, onTap: () {}),
        ),
      );
      expect(find.text('Foto wajib'), findsNothing);
      expect(find.text('Event hari ini'), findsOneWidget);
    });
  });

  group('kartu persetujuan', () {
    ApprovalRequest req(int id, ApprovalCategory c) => ApprovalRequest(
      id: id,
      kind: 'x',
      category: c,
      requester: 'a',
      detail: 'b',
      whenLabel: 'c',
    );

    testWidgets('lencana jumlah dan rincian per kategori', (t) async {
      var opened = 0;
      await t.pumpWidget(
        _host(
          ApprovalCard(
            approvals: [
              req(1, ApprovalCategory.outOfArea),
              req(2, ApprovalCategory.teamLeave),
              req(3, ApprovalCategory.teamLeave),
            ],
            onTap: () => opened++,
          ),
        ),
      );
      expect(find.text('Menunggu Persetujuan'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Absensi di luar area · 1'), findsOneWidget);
      expect(find.text('Cuti tim · 2'), findsOneWidget);
      expect(find.text('Tinjau'), findsOneWidget);
      await t.tap(find.text('Tinjau'));
      expect(opened, 1);
    });

    testWidgets('kategori tanpa item tidak ditampilkan', (t) async {
      await t.pumpWidget(
        _host(
          ApprovalCard(
            approvals: [req(1, ApprovalCategory.outOfArea)],
            onTap: () {},
          ),
        ),
      );
      expect(find.textContaining('Cuti tim'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('kosong: tenang, tanpa lencana, tetap bisa dibuka', (t) async {
      var opened = 0;
      await t.pumpWidget(
        _host(ApprovalCard(approvals: const [], onTap: () => opened++)),
      );
      expect(find.text('Tidak ada persetujuan tertunda'), findsOneWidget);
      expect(find.text('Menunggu Persetujuan'), findsNothing);
      await t.tap(find.text('Tidak ada persetujuan tertunda'));
      expect(opened, 1);
    });

    testWidgets('dibaca satu kalimat oleh screen reader', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(
        _host(
          ApprovalCard(
            approvals: [
              req(1, ApprovalCategory.outOfArea),
              req(2, ApprovalCategory.teamLeave),
            ],
            onTap: () {},
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(
          '2 menunggu persetujuanmu: 1 Absensi di luar area, 1 Cuti tim. '
          'Tinjau persetujuan tim',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('menu layanan', () {
    testWidgets('ikon semua tile sejajar walau label satu atau dua baris', (
      t,
    ) async {
      t.view
        ..physicalSize = const Size(300, 400)
        ..devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        _host(
          Builder(
            builder: (context) => GridView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpace.grid,
                crossAxisSpacing: AppSpace.grid,
                mainAxisExtent: menuTileExtent(context),
              ),
              children: [
                MenuTile(
                  key: const Key('satu'),
                  icon: PhosphorIconsRegular.hand,
                  label: 'Izin',
                  tone: MenuTone.mint,
                  onTap: () {},
                ),
                MenuTile(
                  key: const Key('dua'),
                  icon: PhosphorIconsRegular.graduationCap,
                  label: 'Tugas Belajar Panjang',
                  tone: MenuTone.mint,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      final a = t.getTopLeft(
        find.descendant(
          of: find.byKey(const Key('satu')),
          matching: find.byIcon(PhosphorIconsRegular.hand),
        ),
      );
      final b = t.getTopLeft(
        find.descendant(
          of: find.byKey(const Key('dua')),
          matching: find.byIcon(PhosphorIconsRegular.graduationCap),
        ),
      );
      expect(a.dy, b.dy);
      expect(t.takeException(), isNull);
    });

    testWidgets('gembok ada di dalam tile, di sudut kotak ikon', (t) async {
      await t.pumpWidget(
        _host(
          const SizedBox(
            width: 90,
            height: 110,
            child: MenuTile(
              key: Key('tile'),
              icon: PhosphorIconsRegular.moonStars,
              label: 'Lembur',
              tone: MenuTone.amber,
              enabled: false,
              onTap: null,
            ),
          ),
        ),
      );
      final tile = t.getRect(find.byKey(const Key('tile')));
      final lock = t.getRect(find.byIcon(PhosphorIconsFill.lock));
      expect(tile.contains(lock.topLeft), isTrue);
      expect(tile.contains(lock.bottomRight), isTrue);
    });
  });
}
