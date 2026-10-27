import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../domain/camera.dart';
import 'punch_actions.dart';
import 'punch_providers.dart';

enum _CameraUi { opening, ready, denied, unavailable }

/// Langkah foto: kamera depan dengan bingkai oval. Izin kamera diminta saat
/// layar dibuka; ditolak atau gagal membuka -> pesan dan tombol "Coba lagi".
class PunchPhotoPage extends ConsumerStatefulWidget {
  const PunchPhotoPage({super.key});

  @override
  ConsumerState<PunchPhotoPage> createState() => _PunchPhotoPageState();
}

class _PunchPhotoPageState extends ConsumerState<PunchPhotoPage>
    with WidgetsBindingObserver {
  CameraSession? _session;
  _CameraUi _ui = _CameraUi.opening;
  String? _message;
  String? _captureError;
  bool _sending = false;
  bool _opening = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    final session = _session;
    _session = null;
    if (session != null) session.dispose();
    super.dispose();
  }

  /// Lepas kamera saat aplikasi ke latar belakang, buka lagi saat kembali
  /// (juga setelah pengguna mengubah izin di pengaturan).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_opening || _sending) return;
    if (state == AppLifecycleState.inactive && _session != null) {
      final session = _session;
      _session = null;
      session?.dispose();
      setState(() => _ui = _CameraUi.opening);
    } else if (state == AppLifecycleState.resumed && _session == null) {
      _open();
    }
  }

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    setState(() {
      _ui = _CameraUi.opening;
      _captureError = null;
    });
    final result = await ref.read(cameraServiceProvider).open();
    _opening = false;
    if (_disposed) {
      if (result is CameraReady) await result.session.dispose();
      return;
    }
    switch (result) {
      case CameraReady(:final session):
        setState(() {
          _session = session;
          _ui = _CameraUi.ready;
        });
      case CameraDenied():
        setState(() {
          _ui = _CameraUi.denied;
          _message =
              'Izin kamera diperlukan untuk foto absen. Aktifkan izin Kamera '
              'untuk eAbsensi di Pengaturan > Aplikasi > eAbsensi > Izin, lalu '
              'kembali ke sini.';
        });
      case CameraUnavailable(:final message):
        setState(() {
          _ui = _CameraUi.unavailable;
          _message = message;
        });
    }
  }

  Future<void> _shoot() async {
    final session = _session;
    if (session == null || _sending) return;
    setState(() {
      _sending = true;
      _captureError = null;
    });
    try {
      final path = await session.capture();
      ref.read(punchFlowProvider.notifier).setPhoto(path);
    } on Object {
      if (mounted) {
        setState(() {
          _sending = false;
          _captureError = 'Gagal mengambil foto. Coba lagi.';
        });
      }
      return;
    }
    if (!mounted) return;
    await submitAndShowOutcome(context, ref);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final canShoot = _ui == _CameraUi.ready && !_sending;
    return AppScaffold(
      body: Column(
        children: [
          const PageHeader(title: ''),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screenH,
                0,
                AppSpace.screenH,
                24,
              ),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Ambil foto',
                    style: AppType.title.copyWith(color: c.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Posisikan wajah di dalam bingkai, lalu ketuk tombol.',
                  style: AppType.small.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: 14),
                _PreviewBox(
                  ui: _ui,
                  session: _session,
                  message: _message,
                  sending: _sending,
                  onRetry: _open,
                ),
                if (_captureError != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _captureError!,
                      textAlign: TextAlign.center,
                      style: AppType.caption.copyWith(color: c.errorText),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: Semantics(
                    button: true,
                    enabled: canShoot,
                    label: _sending ? 'Mengirim foto' : 'Ambil foto',
                    excludeSemantics: true,
                    child: Opacity(
                      opacity: canShoot || _sending ? 1 : .4,
                      child: GestureDetector(
                        key: const Key('shutter'),
                        onTap: canShoot ? _shoot : null,
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF10B981), Color(0xFF0D9488)],
                            ),
                            border: Border.all(color: c.surface, width: 5),
                            boxShadow: c.buttonShadow,
                          ),
                          child: _sending
                              ? const Padding(
                                  padding: EdgeInsets.all(22),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
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

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({
    required this.ui,
    required this.session,
    required this.message,
    required this.sending,
    required this.onRetry,
  });

  final _CameraUi ui;
  final CameraSession? session;
  final String? message;
  final bool sending;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ready = ui == _CameraUi.ready && session != null;
    final chipText = sending
        ? 'Mengirim…'
        : ready
        ? 'Kamera siap'
        : 'Membuka kamera…';

    return Semantics(
      label: ready ? 'Pratinjau kamera depan' : 'Kamera belum siap',
      container: true,
      child: Container(
        height: 400,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: AppColors.cameraGradient,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (ready) session!.buildPreview(),
            if (ready || ui == _CameraUi.opening)
              CustomPaint(painter: _OvalMaskPainter()),
            if (ui == _CameraUi.opening)
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            if (ui == _CameraUi.denied || ui == _CameraUi.unavailable)
              _Problem(
                denied: ui == _CameraUi.denied,
                message: message ?? '',
                onRetry: onRetry,
              ),
            if (ready || ui == _CameraUi.opening)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          ready && !sending
                              ? PhosphorIconsFill.checkCircle
                              : PhosphorIconsRegular.circleNotch,
                          size: 16,
                          color: c.accentText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          chipText,
                          style: AppType.captionBold.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({
    required this.denied,
    required this.message,
    required this.onRetry,
  });

  final bool denied;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            denied ? PhosphorIconsFill.lock : PhosphorIconsFill.warning,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 14),
          Semantics(
            liveRegion: true,
            child: Text(
              denied ? 'Izin kamera ditolak' : 'Kamera tidak tersedia',
              textAlign: TextAlign.center,
              style: AppType.header.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            key: const Key('camera-message'),
            textAlign: TextAlign.center,
            style: AppType.small.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 180,
            child: OutlineButton(
              key: const Key('camera-retry'),
              label: 'Coba lagi',
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class _OvalMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final oval = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: 200,
      height: 260,
    );
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(oval);
    canvas
      ..drawPath(
        mask,
        Paint()..color = const Color(0xFF064E3B).withValues(alpha: .3),
      )
      ..drawOval(
        oval,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
