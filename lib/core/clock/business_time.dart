import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:tonik_util/tonik_util.dart' show OffsetDateTime;

/// Waktu di aplikasi ditampilkan menurut **zona bisnis** (`timezone` di `/me`,
/// default `Asia/Jakarta`), bukan zona perangkat: pegawai di WITA/WIT tetap
/// melihat jam punch dan "hari ini" kantor. Model domain menyimpan jam dinding
/// zona bisnis sebagai `DateTime` tanpa zona (field `hour`, `day`, dst.).

bool _tzReady = false;

/// Jam dinding [instant] di zona IANA [zone]. Zona tidak dikenal: jam perangkat.
DateTime wallClockIn(String zone, DateTime instant) {
  try {
    if (!_tzReady) {
      tzdata.initializeTimeZones();
      _tzReady = true;
    }
    return _naive(tz.TZDateTime.from(instant, tz.getLocation(zone)));
  } on Object {
    return instant.toLocal();
  }
}

/// Jam dinding dari waktu server (ISO 8601 dengan offset zona bisnis). Hasil
/// decode generator (`OffsetDateTime`) menyimpan offset dari string, jadi
/// field-nya sudah jam bisnis; tidak pernah lewat `toLocal()`.
DateTime serverWallClock(DateTime t, {String? zone}) {
  if (t is OffsetDateTime) return _naive(t);
  if (zone != null) return wallClockIn(zone, t);
  return t.isUtc ? t.toLocal() : t;
}

DateTime _naive(DateTime t) =>
    DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second, t.millisecond);
