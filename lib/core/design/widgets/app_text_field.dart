import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../phosphor.dart';

import '../tokens.dart';

/// Field teks: tinggi 50, radius 14, ikon kiri, label terlihat opsional,
/// pesan galat dengan ikon (status tidak hanya lewat warna).
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.hint,
    this.label,
    this.icon,
    this.controller,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.trailing,
    this.autofillHints,
    this.inputFormatters,
    this.fieldKey,
    this.focusNode,
    super.key,
  });

  final String hint;
  final String? label;
  final IconData? icon;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final Widget? trailing;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final Key? fieldKey;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = widget.errorText != null;
    final multiline = widget.maxLines > 1;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: color, width: width),
        );

    final Widget? suffix = widget.obscure
        ? IconButton(
            tooltip: _hidden ? 'Tampilkan password' : 'Sembunyikan password',
            constraints: const BoxConstraints(
              minWidth: AppSpace.minTouch,
              minHeight: AppSpace.minTouch,
            ),
            onPressed: () => setState(() => _hidden = !_hidden),
            icon: PhosphorIcon(
              _hidden
                  ? PhosphorIconsRegular.eye
                  : PhosphorIconsRegular.eyeSlash,
              size: 20,
              color: c.textMuted,
            ),
          )
        : widget.trailing;

    final field = TextField(
      key: widget.fieldKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      minLines: widget.minLines,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      style: AppType.body.copyWith(color: c.textPrimary),
      cursorColor: c.accentText,
      decoration: InputDecoration(
        isDense: false,
        filled: true,
        fillColor: c.surface,
        hintText: widget.hint,
        hintStyle: AppType.body.copyWith(color: c.textMuted),
        prefixIcon: widget.icon == null
            ? null
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: PhosphorIcon(widget.icon!, size: 18, color: c.textMuted),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.icon == null ? 14 : 0,
          vertical: multiline ? 14 : 15,
        ),
        constraints: multiline
            ? null
            : const BoxConstraints(minHeight: AppSpace.inputHeight),
        enabledBorder: border(hasError ? c.errorBorder : c.border),
        focusedBorder: border(hasError ? c.errorBorder : c.accent, 2),
        border: border(c.border),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppType.smallBold.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: 6),
        ],
        Semantics(
          label: widget.label ?? widget.hint,
          textField: true,
          child: field,
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhosphorIcon(
                  PhosphorIconsFill.warningCircle,
                  size: 14,
                  color: c.errorText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: AppType.caption.copyWith(color: c.errorText),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
