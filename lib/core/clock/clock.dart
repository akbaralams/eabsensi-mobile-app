import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sumber waktu perangkat. Hanya untuk tampilan (jam di beranda, salam);
/// waktu punch selalu dari server. Di-override di test.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

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
