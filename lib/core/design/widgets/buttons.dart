import 'package:flutter/material.dart';

import '../phosphor.dart';

import '../tokens.dart';

/// Tombol utama: gradien, radius 16, tinggi 54. `onPressed == null` = nonaktif.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.height = AppSpace.buttonHeight,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final double height;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.loading ? '${widget.label}, memproses' : widget.label,
      excludeSemantics: true,
      child: Opacity(
        opacity: widget.onPressed == null ? .5 : 1,
        child: AnimatedScale(
          scale: _pressed && !reduce ? .98 : 1,
          duration: const Duration(milliseconds: 90),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: c.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: widget.onPressed == null ? null : c.buttonShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.button),
                onTap: _enabled ? widget.onPressed : null,
                onHighlightChanged: (v) => setState(() => _pressed = v),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: widget.height,
                    minWidth: double.infinity,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.loading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: c.onGradient,
                            ),
                          )
                        else ...[
                          Flexible(
                            child: Text(
                              widget.label,
                              textAlign: TextAlign.center,
                              style: AppType.button.copyWith(
                                color: c.onGradient,
                              ),
                            ),
                          ),
                          if (widget.icon != null) ...[
                            const SizedBox(width: 8),
                            PhosphorIcon(
                              widget.icon!,
                              size: 18,
                              color: c.onGradient,
                            ),
                          ],
                        ],
                      ],
                    ),
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

/// Tombol outline: surface, border 1, radius 16, tinggi minimal 50.
class OutlineButton extends StatelessWidget {
  const OutlineButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 50,
    this.tone,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  /// Warna teks/ikon; default `textPrimary`.
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = tone ?? c.textPrimary;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: onPressed == null ? .5 : 1,
        child: Material(
          color: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: BorderSide(color: c.border),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height < AppSpace.minTouch
                    ? AppSpace.minTouch
                    : height,
                minWidth: double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      PhosphorIcon(icon!, size: 20, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppType.bodyBold.copyWith(color: fg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
