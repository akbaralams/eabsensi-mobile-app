import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_env.dart';
import '../data/mock_inbox_repository.dart';
import '../domain/inbox.dart';

/// Kontrak API belum punya endpoint notifikasi/persetujuan (Task 10): selalu
/// data contoh sampai kontrak tersedia.
final inboxRepositoryProvider = Provider<InboxRepository>(
  (ref) => MockInboxRepository(ref.watch(mockEnvProvider)),
);

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => ref.watch(inboxRepositoryProvider).notifications(),
);

final approvalsProvider = FutureProvider.autoDispose<List<ApprovalRequest>>(
  (ref) => ref.watch(inboxRepositoryProvider).approvals(),
);
