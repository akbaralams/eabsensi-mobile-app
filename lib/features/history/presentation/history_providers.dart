import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock/clock.dart';
import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_env.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/mock_history_repository.dart';
import '../domain/history.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  if (AppConfig.useMock) {
    return MockHistoryRepository(ref.watch(mockEnvProvider));
  }
  throw UnimplementedError('Client API nyata belum tersedia (Task 3).');
});

/// Bulan yang sedang dilihat (hari pertama bulan).
class HistoryMonthController extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month);
  }

  void set(DateTime month) => state = DateTime(month.year, month.month);
}

final historyMonthProvider = NotifierProvider<HistoryMonthController, DateTime>(
  HistoryMonthController.new,
);

final monthHistoryProvider = FutureProvider.autoDispose<MonthHistory>((ref) {
  final month = ref.watch(historyMonthProvider);
  return withSession(
    ref.read,
    () => ref.watch(historyRepositoryProvider).month(month.year, month.month),
  );
});
