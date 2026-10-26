import 'dart:async';

import 'package:flutter/material.dart';

import '../phosphor.dart';

import '../tokens.dart';

/// Toast singkat (2,6 dtk) di atas navigasi bawah.
abstract final class AppToast {
  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2600),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _timer?.cancel();
    _current?.remove();
    final entry = OverlayEntry(
      builder: (_) => _ToastView(message: message, duration: duration),
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(duration + const Duration(milliseconds: 400), () {
      if (_current == entry) {
        entry.remove();
        _current = null;
      }
    });
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.message, required this.duration});

  final String message;
  final Duration duration;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward());
    _hide = Timer(widget.duration, () {
      if (mounted) unawaited(_controller.reverse());
    });
  }

  @override
  void dispose() {
    _hide?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Positioned(
      left: 18,
      right: 18,
      bottom: MediaQuery.paddingOf(context).bottom + 96,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: curved,
          child: AnimatedBuilder(
            animation: curved,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, reduce ? 0 : 8 * (1 - curved.value)),
              child: child,
            ),
            child: Semantics(
              liveRegion: true,
              label: widget.message,
              excludeSemantics: true,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: c.toastBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: c.toastShadow,
                  ),
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsFill.checkCircle,
                        size: 20,
                        color: c.mint400,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: AppType.small.copyWith(
                            color: c.toastText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
