import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_providers.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/mock_leave_repository.dart';
import '../data/remote_leave_repository.dart';
import '../domain/leave.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  if (AppConfig.useMock) return MockLeaveRepository(ref.watch(mockEnvProvider));
  return RemoteLeaveRepository(ref.watch(mobileApiClientProvider).cuti);
});

final leaveOverviewProvider = FutureProvider.autoDispose<LeaveOverview>(
  (ref) =>
      withSession(ref.read, () => ref.watch(leaveRepositoryProvider).load()),
);
