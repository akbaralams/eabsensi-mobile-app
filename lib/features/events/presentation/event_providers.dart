import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_env.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/mock_event_repository.dart';
import '../domain/event_item.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  if (AppConfig.useMock) return MockEventRepository(ref.watch(mockEnvProvider));
  throw UnimplementedError('Client API nyata belum tersedia (Task 3).');
});

final eventsTodayProvider = FutureProvider.autoDispose<List<EventItem>>(
  (ref) => withSession(
    ref.read,
    () => ref.watch(eventRepositoryProvider).listToday(),
  ),
);
