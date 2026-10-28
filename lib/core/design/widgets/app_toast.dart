import 'package:flutter/material.dart';

import '../phosphor.dart';
import '../tokens.dart';

/// Umpan balik singkat lewat Snackbar Material: mengambang di atas navigasi
/// bawah, bisa ditutup, dan bisa memuat satu aksi (mis. "Urungkan").
abstract final class AppToast {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return null;
    final c = context.colors;
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          AppSpace.screenH,
          0,
          AppSpace.screenH,
          8,
        ),
        duration: duration,
        persist: false,
        backgroundColor: c.toastBackground,
        showCloseIcon: actionLabel == null,
        closeIconColor: c.toastText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            PhosphorIcon(
              PhosphorIconsFill.checkCircle,
              size: 20,
              color: c.mint400,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppType.small.copyWith(
                  color: c.toastText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: c.mint400,
                onPressed: onAction ?? () {},
              ),
      ),
    );
  }
}
