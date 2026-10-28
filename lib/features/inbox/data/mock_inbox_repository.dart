import '../../../core/design/widgets/menu_tile.dart';
import '../../../core/mock/mock_env.dart';
import '../domain/inbox.dart';

class MockInboxRepository implements InboxRepository {
  MockInboxRepository(this._env);

  final MockEnv _env;

  final List<ApprovalRequest> _approvals = [
    const ApprovalRequest(
      id: 1,
      kind: 'Absen di luar area',
      requester: 'Rina Maharani',
      detail: 'Check In 08:02 · Lokasi 420 m dari kantor',
      whenLabel: '10 menit lalu',
    ),
    const ApprovalRequest(
      id: 2,
      kind: 'Cuti Tahunan',
      requester: 'Budi Santoso',
      detail: '3 hari · 9-11 November 2026',
      whenLabel: '1 jam lalu',
    ),
    const ApprovalRequest(
      id: 3,
      kind: 'Izin Keperluan Pribadi',
      requester: 'Dewi Lestari',
      detail: '1 hari · 28 Oktober 2026',
      whenLabel: 'Kemarin',
    ),
  ];

  @override
  Future<List<AppNotification>> notifications() async {
    await _env.network();
    return const [
      AppNotification(
        id: 1,
        title: 'Check In kamu menunggu persetujuan atasan',
        meta: 'Hari ini · 07:55',
        tone: MenuTone.amber,
        read: false,
      ),
      AppNotification(
        id: 2,
        title: 'Pengajuan Cuti Tahunan disetujui',
        meta: 'Kemarin · 15:20',
        tone: MenuTone.mint,
        read: false,
      ),
      AppNotification(
        id: 3,
        title: 'Pengingat: Apel Kontrak hari ini',
        meta: '2 hari lalu',
        tone: MenuTone.teal,
        read: true,
      ),
    ];
  }

  @override
  Future<List<ApprovalRequest>> approvals() async {
    await _env.network();
    return List.unmodifiable(_approvals);
  }

  @override
  Future<void> decide(int approvalId, {required bool approve}) async {
    await _env.network();
    _approvals.removeWhere((a) => a.id == approvalId);
  }
}
