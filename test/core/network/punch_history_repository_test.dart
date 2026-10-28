import 'package:eabsensi/features/history/data/punch_history_repository.dart';
import 'package:eabsensi/features/history/domain/history.dart';
import 'package:eabsensi/features/punch/domain/punch.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePunches implements PunchRepository {
  _FakePunches(this.byDay);

  final Map<int, List<Punch>> byDay;
  final List<DateTime> calls = [];
  int inFlight = 0;
  int maxInFlight = 0;

  @override
  Future<List<Punch>> list(DateTime date) async {
    calls.add(date);
    inFlight++;
    maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
    await Future<void>.delayed(const Duration(milliseconds: 1));
    inFlight--;
    return byDay[date.day] ?? const [];
  }

  @override
  Future<Punch> create(EvidenceSubmission evidence) =>
      throw UnimplementedError();
}

Punch _punch(int day, int hour, int minute, PunchStatus status) => Punch(
  id: day * 100 + hour,
  punchedAt: DateTime(2026, 10, day, hour, minute),
  source: 'mobile',
  status: status,
  statusLabel: status.name,
  hasPhoto: false,
);

void main() {
  final now = DateTime(2026, 10, 28, 9);

  test(
    'hanya hari yang punya punch, tanpa hari ini, tanpa klasifikasi',
    () async {
      final fake = _FakePunches({
        5: [
          _punch(5, 7, 50, PunchStatus.approved),
          _punch(5, 16, 5, PunchStatus.approved),
        ],
        6: [_punch(6, 8, 1, PunchStatus.pending)],
        7: [_punch(7, 8, 0, PunchStatus.rejected)],
        28: [_punch(28, 7, 0, PunchStatus.approved)],
      });
      final repo = PunchHistoryRepository(fake, now: () => now);

      final month = await repo.month(2026, 10);

      expect(repo.supportsClassification, isFalse);
      expect(fake.calls.map((d) => d.day), isNot(contains(28)));
      expect(fake.calls.length, 27);
      expect(month.days.map((d) => d.date.day), [6, 5]);
      final d5 = month.days.last;
      expect(d5.status, DayStatus.present);
      expect(d5.checkIn, '07:50');
      expect(d5.checkOut, '16:05');
      expect(month.days.first.status, DayStatus.pending);
      expect(month.days.first.checkOut, isNull);
    },
  );

  test('permintaan dibatasi paralel', () async {
    final fake = _FakePunches({});
    await PunchHistoryRepository(fake, now: () => now).month(2026, 9);
    expect(fake.calls.length, 30);
    expect(fake.maxInFlight, lessThanOrEqualTo(4));
  });

  test('hasil bulan di-cache sebentar untuk menghindari 429', () async {
    final fake = _FakePunches({});
    var clock = now;
    final repo = PunchHistoryRepository(fake, now: () => clock);
    await repo.month(2026, 9);
    final first = fake.calls.length;

    clock = clock.add(const Duration(seconds: 30));
    await repo.month(2026, 9);
    expect(fake.calls.length, first);

    clock = clock.add(const Duration(minutes: 2));
    await repo.month(2026, 9);
    expect(fake.calls.length, first * 2);
  });

  test('bulan depan tidak meminta apa pun', () async {
    final fake = _FakePunches({});
    final month = await PunchHistoryRepository(
      fake,
      now: () => now,
    ).month(2026, 11);
    expect(fake.calls, isEmpty);
    expect(month.days, isEmpty);
  });
}
