import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock/clock.dart';
import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_env.dart';
import '../../auth/presentation/session_controller.dart';
import '../../punch/presentation/punch_providers.dart';
import '../data/mock_history_repository.dart';
import '../domain/history.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  if (AppConfig.useMock) {
    return MockHistoryRepository(ref.watch(mockEnvProvider));
  }
  throw UnimplementedError('Client API nyata belum tersedia (Task 3).');
});

/// Bulan yang sedang dilihat (hari pertama bulan), dibatasi 12 bulan ke belakang.
class HistoryMonthController extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month);
  }

  void set(DateTime month) {
    final now = ref.read(clockProvider)();
    final earliest = earliestHistoryMonth(now);
    final target = DateTime(month.year, month.month);
    final latest = DateTime(now.year, now.month);
    if (target.isBefore(earliest) || target.isAfter(latest)) return;
    state = target;
  }
}

final historyMonthProvider = NotifierProvider<HistoryMonthController, DateTime>(
  HistoryMonthController.new,
);

/// Rekap bulan terpilih. Untuk bulan berjalan, baris hari ini dibangun dari
/// punch server sehingga Check In langsung terlihat di Riwayat.
final monthHistoryProvider = FutureProvider.autoDispose<MonthHistory>((
  ref,
) async {
  final month = ref.watch(historyMonthProvider);
  final now = ref.watch(clockProvider)();
  final history = await withSession(
    ref.read,
    () => ref.watch(historyRepositoryProvider).month(month.year, month.month),
  );
  if (month.year != now.year || month.month != now.month) return history;
  final punches = await ref.watch(todayPunchesProvider.future);
  final today = todayRecord(now, punches);
  return today == null ? history : history.withToday(today);
});
