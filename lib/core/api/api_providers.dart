import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/token_store.dart';
import '../config/app_config.dart';
import 'api_client.dart';

/// Client API nyata (base URL dari `--dart-define=API_BASE_URL`). Test
/// meng-override dengan client ber-adapter palsu.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    baseUrl: AppConfig.baseUrl,
    tokens: ref.watch(tokenStoreProvider),
  );
  ref.onDispose(client.close);
  return client;
});
