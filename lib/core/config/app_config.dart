/// Konfigurasi build. Semua nilai datang dari `--dart-define`.
library;

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  /// URL dasar API mobile (mis. `http://10.0.2.2:8000/api`).
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  /// Data dummy (default, tanpa backend). `--dart-define=USE_MOCK=false` memakai
  /// server di [baseUrl]; inbox dan menu tetap statis karena belum ada di kontrak.
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  /// Alat uji (galeri komponen, panel skenario): hanya di build debug, atau bila
  /// diminta lewat `--dart-define=DEBUG_TOOLS=true` (mis. APK uji data dummy).
  static const debugTools = bool.fromEnvironment(
    'DEBUG_TOOLS',
    defaultValue: kDebugMode,
  );
}
