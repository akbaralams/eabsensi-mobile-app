import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/session_controller.dart';
import 'business_time.dart';

/// Zona bisnis dari `/me` (`timezone`), `null` sebelum masuk.
final businessTimezoneProvider = Provider<String?>(
  (ref) => ref.watch(sessionProvider.select((s) => s.value?.timezone)),
);

/// Jam dinding **zona bisnis** (bukan zona perangkat): menentukan "hari ini"
/// untuk `GET /punches?date=`, jam di beranda, dan salam. Waktu punch tetap
/// dari server. Di-override di test.
final clockProvider = Provider<DateTime Function()>((ref) {
  final zone = ref.watch(businessTimezoneProvider);
  if (zone == null) return DateTime.now;
  return () => wallClockIn(zone, DateTime.now());
});

/// Jam yang berdetak tiap detik, untuk kartu absen di beranda.
final tickingClockProvider = StreamProvider<DateTime>((ref) {
  final now = ref.watch(clockProvider);
  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => now(),
  ).startWith(now());
});

extension<T> on Stream<T> {
  Stream<T> startWith(T first) async* {
    yield first;
    yield* this;
  }
}
