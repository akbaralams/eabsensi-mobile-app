import 'package:flutter/foundation.dart';

import '../../../core/design/widgets/menu_tile.dart';

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.meta,
    required this.tone,
    required this.read,
  });

  final int id;
  final String title;
  final String meta;
  final MenuTone tone;
  final bool read;
}

@immutable
class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.kind,
    required this.requester,
    required this.detail,
    required this.whenLabel,
  });

  final int id;

  /// mis. "Absen di luar area", "Cuti Tahunan".
  final String kind;
  final String requester;
  final String detail;
  final String whenLabel;
}

/// Belum ada di kontrak API (Task 10 menunggu kontrak): hanya data contoh.
abstract class InboxRepository {
  Future<List<AppNotification>> notifications();

  Future<List<ApprovalRequest>> approvals();

  Future<void> decide(int approvalId, {required bool approve});
}
