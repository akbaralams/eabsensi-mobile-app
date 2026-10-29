import 'dart:io';

/// Base URL backend uji, mis. `http://127.0.0.1:8081/api`. Kosong: uji live
/// dilewati.
const liveApi = String.fromEnvironment('LIVE_API');

/// Sandi akun `kontrak*` dari fixture repo API (data uji, bukan rahasia).
const livePassword = String.fromEnvironment(
  'LIVE_PASSWORD',
  defaultValue: 'kontrak-uji-2026',
);

const _slow = bool.fromEnvironment('LIVE_SLOW');

String? get liveSkip => liveApi.isEmpty ? 'set --dart-define=LIVE_API' : null;
String? get liveSlowSkip => _slow ? null : 'set --dart-define=LIVE_SLOW=true';

/// `device_name` khusus uji agar tidak mencabut token perangkat sungguhan.
String liveDevice(String tag) =>
    'uji-aplikasi-$tag-${DateTime.now().microsecondsSinceEpoch}';

/// Binding test Flutter memalsukan HttpClient (semua request 400); uji live
/// butuh jaringan sungguhan.
void enableRealHttp() => HttpOverrides.global = null;
