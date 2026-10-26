import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/design/design.dart';
import '../../../core/network/api_failure.dart';
import '../data/mock_auth_repository.dart';
import 'session_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _loading = false;
  String? _loginError;
  String? _passwordError;
  String? _ruleMessage;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loginError = _login.text.trim().isEmpty
          ? 'NIP atau username wajib diisi.'
          : null;
      _passwordError = _password.text.isEmpty ? 'Password wajib diisi.' : null;
      _ruleMessage = null;
    });
    if (_loginError != null || _passwordError != null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(sessionProvider.notifier)
          .login(_login.text, _password.text);
    } on ValidationFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loginError = e.first('login');
        _passwordError = e.first('password');
        _ruleMessage = _loginError == null && _passwordError == null
            ? e.message
            : null;
      });
    } on ApiFailure catch (e) {
      if (!mounted) return;
      // 403/422 (aturan)/429/offline: pesan ditampilkan apa adanya.
      setState(() => _ruleMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 36),
                  child: Column(
                    children: [
                      const LogoMark(size: 40, animate: true),
                      const SizedBox(height: 24),
                      Text(
                        'eAbsensi',
                        style: AppType.brand.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kehadiran lebih mudah,\nsetiap hari.',
                        textAlign: TextAlign.center,
                        style: AppType.body.copyWith(color: c.textMuted),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _Sheet(
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          fieldKey: const Key('login-field'),
                          controller: _login,
                          hint: 'NIP / Username',
                          icon: PhosphorIconsRegular.user,
                          errorText: _loginError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                        ),
                        const SizedBox(height: AppSpace.block),
                        _PasswordField(
                          controller: _password,
                          focusNode: _passwordFocus,
                          errorText: _passwordError,
                          onSubmitted: _submit,
                        ),
                        if (_ruleMessage != null) ...[
                          const SizedBox(height: AppSpace.block),
                          _RuleMessage(message: _ruleMessage!),
                        ],
                        const SizedBox(height: AppSpace.block),
                        PrimaryButton(
                          label: 'Masuk',
                          icon: PhosphorIconsBold.arrowRight,
                          loading: _loading,
                          onPressed: _submit,
                        ),
                        if (AppConfig.useMock) ...[
                          const SizedBox(height: AppSpace.block),
                          Text(
                            'Mode contoh (data dummy). Akun: kontrak / $mockPassword',
                            textAlign: TextAlign.center,
                            style: AppType.caption.copyWith(color: c.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      fieldKey: const Key('password-field'),
      controller: controller,
      focusNode: focusNode,
      hint: 'Password',
      icon: PhosphorIconsRegular.lock,
      obscure: true,
      errorText: errorText,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onSubmitted: (_) => onSubmitted(),
    );
  }
}

class _RuleMessage extends StatelessWidget {
  const _RuleMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.amberTint,
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhosphorIcon(
              PhosphorIconsFill.warning,
              size: 18,
              color: c.amberIcon,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppType.caption.copyWith(
                  color: c.amberText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const radius = BorderRadius.vertical(
      top: Radius.circular(AppRadius.sheetTop),
    );
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: c.navShadow),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            color: c.surface.withValues(alpha: .88),
            padding: EdgeInsets.fromLTRB(
              22,
              20,
              22,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
