import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_failure.dart';
import '../../punch/domain/punch.dart';
import '../domain/event_item.dart';

/// Tiga event contoh: satu bisa langsung check-in, satu sudah check-in, satu
/// hanya dibuka 15.30-16.30 (menampilkan pesan aturan dari kontrak).
class MockEventRepository implements EventRepository {
  MockEventRepository(this._env);

  final MockEnv _env;
  late final List<EventItem> _events = _seed();

  List<EventItem> _seed() {
    final today = _env.now();
    final date = DateTime(today.year, today.month, today.day);
    return [
      EventItem(
        id: 1,
        name: 'Apel Kontrak',
        eventDate: date,
        startsAt: '00:00',
        endsAt: '23:59',
        checkedIn: false,
      ),
      EventItem(
        id: 2,
        name: 'Upacara Bendera',
        eventDate: date,
        startsAt: '07:00',
        endsAt: '09:00',
        checkedIn: true,
      ),
      EventItem(
        id: 3,
        name: 'Apel Sore',
        eventDate: date,
        startsAt: '15:30',
        endsAt: '16:30',
        checkedIn: false,
      ),
    ];
  }

  Future<void> _gate() async {
    await _env.network();
    final s = _env.scenario();
    if (s.offline) throw const OfflineFailure();
    if (s.tokenRevoked || await _env.tokens.read() == null) {
      throw const UnauthenticatedFailure();
    }
  }

  @override
  Future<List<EventItem>> listToday() async {
    await _gate();
    return List.unmodifiable(_events);
  }

  @override
  Future<EventCheckIn> checkIn(int eventId, EvidenceSubmission evidence) async {
    await _gate();
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index < 0) throw const UnknownFailure('Data tidak ditemukan.');
    final event = _events[index];
    final s = _env.scenario();
    if (s.requiresPhoto && evidence.photoPath == null) {
      throw const ValidationFailure('Data yang diberikan tidak valid.', {
        'photo': ['Foto wajib diunggah.'],
      });
    }
    final now = _env.now();
    final minutes = now.hour * 60 + now.minute;
    int toMinutes(String hhmm) {
      final p = hhmm.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    if (minutes < toMinutes(event.startsAt) ||
        minutes > toMinutes(event.endsAt)) {
      throw RuleRejectedFailure(
        'Check-in dibuka pukul ${event.startsAt} sampai ${event.endsAt}.',
      );
    }
    if (event.checkedIn) {
      throw const RuleRejectedFailure('Anda sudah check-in di event ini.');
    }
    _events[index] = event.copyWith(checkedIn: true);
    return EventCheckIn(eventId: eventId, checkedInAt: now);
  }
}
