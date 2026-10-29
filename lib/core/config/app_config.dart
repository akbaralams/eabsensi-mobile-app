/// Konfigurasi build. Semua nilai datang dari `--dart-define`.
library;

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  /// URL dasar API mobile: Rust `http://10.0.2.2:8080/api` (emulator) atau
  /// Laravel `:8000`; staging/produksi wajib HTTPS.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  /// Data dummy hanya di build debug (default) atau bila diminta lewat
  /// `--dart-define=USE_MOCK=true`. Build rilis/profil memakai API sungguhan.
  /// Debug terhadap backend: `--dart-define=USE_MOCK=false`.
  static const useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: kDebugMode,
  );

  /// Alat uji (galeri komponen, panel skenario): hanya di build debug, atau bila
  /// diminta lewat `--dart-define=DEBUG_TOOLS=true` (mis. APK uji data dummy).
  static const debugTools = bool.fromEnvironment(
    'DEBUG_TOOLS',
    defaultValue: kDebugMode,
  );
}
