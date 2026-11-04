import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Masuk layar: fade + naik 8px ([AppMotion.enter]). Patuh `disableAnimations`.
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
    duration: AppMotion.enter,
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
    final curve = CurvedAnimation(parent: _c, curve: AppMotion.easeOut);
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

/// Umpan balik tekan: anak mengecil ke [scale] selama jari menempel, lalu
/// kembali. Memakai [Listener], jadi tidak bersaing dengan InkWell/gesture
/// anak. Mati bila [enabled] false atau pengguna mengurangi animasi.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    this.enabled = true,
    this.scale = AppMotion.pressScale,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down && mounted) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final active =
        widget.enabled && _down && !MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: widget.enabled ? (_) => _set(true) : null,
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: active ? widget.scale : 1,
        duration: AppMotion.press,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Pergantian status atau konten: yang lama memudar, yang baru muncul dari
/// skala 0,96 ([AppMotion.state]). Ganti [id] untuk memicu animasi; data yang
/// sama tidak dianimasikan ulang. Tanpa animasi bila pengguna menguranginya.
class StateSwitcher extends StatelessWidget {
  const StateSwitcher({
    required this.id,
    required this.child,
    this.alignment = Alignment.centerLeft,
    super.key,
  });

  final Object id;
  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.state),
      switchInCurve: AppMotion.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) =>
          Stack(alignment: alignment, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .96, end: 1).animate(animation),
          alignment: alignment.resolve(Directionality.of(context)),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(id), child: child),
    );
  }
}
