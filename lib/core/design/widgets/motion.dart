import 'dart:async';

import 'package:flutter/material.dart';

/// Masuk layar: fade + naik 8px, 300ms. Patuh `disableAnimations`.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (widget.delay == Duration.zero) {
      unawaited(_c.forward());
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) unawaited(_c.forward());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return FadeTransition(
      opacity: curve,
      child: AnimatedBuilder(
        animation: curve,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 8 * (1 - curve.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Melayang naik-turun terus-menerus (badge jam, orb hasil, logo).
class Floating extends StatefulWidget {
  const Floating({
    required this.child,
    this.distance = 6,
    this.period = const Duration(seconds: 5),
    super.key,
  });

  final Widget child;
  final double distance;
  final Duration period;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _c.stop();
      _started = false;
    } else if (!_started) {
      _started = true;
      unawaited(_c.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curve,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -widget.distance * curve.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}
