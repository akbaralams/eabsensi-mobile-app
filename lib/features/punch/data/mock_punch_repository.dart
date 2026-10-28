import '../../../core/format/id_format.dart';
import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_failure.dart';
import '../domain/punch.dart';

/// Aturan sesuai kontrak: interval minimal 60 detik, foto wajib bila
/// `requires_photo`, `latitude`/`longitude` berpasangan.
class MockPunchRepository implements PunchRepository {
  MockPunchRepository(this._env);

  final MockEnv _env;
  final Map<String, List<Punch>> _byDate = {};
  int _nextId = 100;

  static const minIntervalSeconds = 60;

  Future<void> _gate() async {
    await _env.network();
    final s = _env.scenario();
    if (s.offline) throw const OfflineFailure();
    if (s.tokenRevoked || await _env.tokens.read() == null) {
      throw const UnauthenticatedFailure();
    }
  }

  @override
  Future<List<Punch>> list(DateTime date) async {
    await _gate();
    return List.unmodifiable(_byDate[IdFormat.apiDate(date)] ?? const []);
  }

  @override
  Future<Punch> create(EvidenceSubmission evidence) async {
    await _gate();
    final s = _env.scenario();
    final errors = <String, List<String>>{};
    if (s.requiresPhoto && evidence.photoPath == null) {
      errors['photo'] = ['Foto wajib diunggah.'];
    }
    if ((evidence.latitude == null) != (evidence.longitude == null)) {
      errors[evidence.latitude == null ? 'latitude' : 'longitude'] = [
        'Latitude dan longitude harus berpasangan.',
      ];
    }
    if (errors.isNotEmpty) {
      throw ValidationFailure('Data yang diberikan tidak valid.', errors);
    }

    final now = _env.now();
    final list = _byDate.putIfAbsent(IdFormat.apiDate(now), () => []);
    if (list.isNotEmpty &&
        now.difference(list.last.punchedAt).inSeconds < minIntervalSeconds) {
      throw const RuleRejectedFailure(
        'Tunggu $minIntervalSeconds detik sebelum melakukan punch lagi.',
      );
    }
    final pending = s.requiresApproval;
    final punch = Punch(
      id: _nextId++,
      punchedAt: now,
      source: 'mobile',
      status: pending ? PunchStatus.pending : PunchStatus.approved,
      statusLabel: pending ? 'Menunggu persetujuan' : 'Disetujui',
      hasPhoto: evidence.photoPath != null,
    );
    list.add(punch);
    return punch;
  }
}
