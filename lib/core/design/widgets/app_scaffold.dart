import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// Latar gradien layar (blob mint di kanan atas, blob teal di kiri).
class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, .6],
          colors: [c.backgroundTop, c.backgroundBottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(.9, -1),
                    radius: .9,
                    colors: [c.blobMint, c.blobMint.withValues(alpha: 0)],
                    stops: const [0, .7],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-.9, -.9),
                    radius: .8,
                    colors: [c.blobTeal, c.blobTeal.withValues(alpha: 0)],
                    stops: const [0, .7],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Kerangka layar: latar gradien, status bar menyesuaikan tema, area aman atas.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.bottomNavigationBar,
    this.safeTop = true,
    this.resizeToAvoidBottomInset = true,
    this.constrainBody = true,
    super.key,
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final bool safeTop;
  final bool resizeToAvoidBottomInset;

  /// Batasi lebar konten (tablet): konten ponsel tidak melar.
  final bool constrainBody;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final overlay = c.isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          extendBody: true,
          bottomNavigationBar: bottomNavigationBar,
          body: SafeArea(
            bottom: false,
            top: safeTop,
            child: constrainBody ? ContentWidth(child: body) : body,
          ),
        ),
      ),
    );
  }
}

/// Lebar konten maksimum di layar lebar; di ponsel tidak berpengaruh.
class ContentWidth extends StatelessWidget {
  const ContentWidth({required this.child, this.maxWidth = 640, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
