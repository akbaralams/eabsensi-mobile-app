import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'punch_providers.dart';

/// Kirim bukti lalu arahkan ke layar hasil atau galat.
Future<void> submitAndShowOutcome(BuildContext context, WidgetRef ref) async {
  await ref.read(punchFlowProvider.notifier).submit();
  if (!context.mounted) return;
  final state = ref.read(punchFlowProvider);
  // Hasil menumpuk di atas Beranda: Back sistem (termasuk predictive back)
  // kembali ke Beranda secara wajar, tanpa PopScope yang menahan gestur.
  final router = GoRouter.of(context);
  router.go('/home');
  await router.push<void>(
    state.result != null ? '/punch/result' : '/punch/error',
  );
}
