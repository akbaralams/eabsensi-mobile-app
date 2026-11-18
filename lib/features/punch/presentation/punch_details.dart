import '../../../core/clock/business_time.dart';
import '../../../core/format/id_format.dart';
import '../domain/location.dart';
import 'punch_providers.dart';

/// Teks lokasi dan waktu di layar Check In dan konfirmasi, supaya pegawai
/// melihat jelas apa yang akan dikirim: nama jalan dari koordinat, koordinat
/// itu sendiri, dan jam saat ini. Jam resmi tetap dicatat server.
abstract final class PunchDetails {
  /// Nama jalan, atau keadaan pencariannya.
  static String place(PunchFlowState flow) {
    if (flow.phase == LocationPhase.denied ||
        flow.phase == LocationPhase.unavailable) {
      return 'Tanpa lokasi';
    }
    if (flow.fix == null) return 'Menunggu GPS…';
    if (flow.address case final address?) return address;
    if (flow.addressPending) return 'Mencari nama jalan…';
    return 'Nama jalan tidak tersedia';
  }

  /// "-6.20012, 106.81655" (5 desimal, sekitar 1 meter); `null` tanpa lokasi.
  static String? coordinates(PunchFlowState flow) {
    final fix = flow.fix;
    if (fix == null) return null;
    return '${fix.latitude.toStringAsFixed(5)}, '
        '${fix.longitude.toStringAsFixed(5)}';
  }

  /// "20:09:41 WIB" (zona bisnis dari `/me`).
  static String time(DateTime now, String? zone) {
    final abbr = zoneAbbreviation(zone);
    final t = IdFormat.timeSeconds(now);
    return abbr == null ? t : '$t $abbr';
  }

  static const serverTimeNote = 'Jam resmi dicatat server saat dikirim';

  /// Keterangan lokasi di bawah status, sesuai keadaan alur.
  static String locationNote(PunchFlowState flow, OfficeArea? office) {
    if (flow.blockReason case final reason?) return reason;
    final fix = flow.fix;
    return switch (flow.phase) {
      LocationPhase.denied => 'Izin lokasi tidak diberikan. Absen tetap bisa dilanjutkan tanpa lokasi.',
      LocationPhase.unavailable =>
        'Lokasi belum didapat. Absen tetap bisa dilanjutkan tanpa lokasi.',
      LocationPhase.outside when office != null && fix != null =>
        'Akurasi lokasi: ${fix.accuracyMeters} meter. Anda di luar radius '
            '${office.name}; absen tetap tercatat dan ditandai untuk ditinjau.',
      _ when fix == null => 'Akurasi lokasi: menunggu…',
      _ => 'Akurasi lokasi: ${fix.accuracyMeters} meter',
    };
  }

  /// Teks tanda lokasi dari server; tanda baru tetap tampil sebagai "Perlu ditinjau".
  static String flagLabel(String flag) => switch (flag) {
    'outside_radius' => 'Di luar radius',
    'impossible_travel' => 'Perpindahan tidak wajar',
    'rooted_device' => 'Perangkat di-root',
    'mock_location' => 'Lokasi palsu',
    _ => 'Perlu ditinjau',
  };
}
