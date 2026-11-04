import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/design/design.dart';
import '../domain/camera.dart';
import 'punch_actions.dart';
import 'punch_providers.dart';

enum _CameraUi { opening, ready, denied, unavailable }

enum _Step { camera, confirm }

/// Lama wajah harus diam di dalam bingkai sebelum foto diambil otomatis.
const autoCaptureDelay = Duration(seconds: 1);

/// Langkah foto (2 dari 3) dan konfirmasi (3 dari 3), mengikuti wizard
/// absensi absenq: kamera layar penuh dengan bingkai wajah, deteksi wajah di
/// perangkat, jepret otomatis saat wajah stabil, lalu pratinjau sebelum kirim.
class PunchPhotoPage extends ConsumerStatefulWidget {
  const PunchPhotoPage({super.key});

  @override
  ConsumerState<PunchPhotoPage> createState() => _PunchPhotoPageState();
}

class _PunchPhotoPageState extends ConsumerState<PunchPhotoPage>
    with WidgetsBindingObserver {
  final _previewKey = GlobalKey();
  final _guideKey = GlobalKey();

  CameraSession? _session;
  StreamSubscription<List<Rect>>? _faceSub;
  List<Rect> _faces = const [];
  FaceStatus _face = FaceStatus.none;
  Timer? _autoTimer;
  CameraLens _lens = CameraLens.front;

  _Step _step = _Step.camera;
  _CameraUi _ui = _CameraUi.opening;
  String? _message;
  String? _captureError;
  bool _capturing = false;
  bool _sending = false;
  bool _opening = false;
  bool _torch = false;
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
    _closeSession();
    super.dispose();
  }

  /// Lepas kamera saat aplikasi ke latar belakang, buka lagi saat kembali
  /// (juga setelah pengguna mengubah izin di pengaturan).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_step != _Step.camera || _opening || _capturing) return;
    if (state == AppLifecycleState.inactive && _session != null) {
      _closeSession();
      setState(() {
        _ui = _CameraUi.opening;
        _torch = false;
      });
    } else if (state == AppLifecycleState.resumed && _session == null) {
      _open();
    }
  }

  void _closeSession() {
    _autoTimer?.cancel();
    _autoTimer = null;
    _faceSub?.cancel();
    _faceSub = null;
    _faces = const [];
    _face = FaceStatus.none;
    final session = _session;
    _session = null;
    if (session != null) session.dispose();
  }

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    setState(() {
      _ui = _CameraUi.opening;
      _captureError = null;
    });
    final result = await ref.read(cameraServiceProvider).open(lens: _lens);
    _opening = false;
    if (_disposed || _step != _Step.camera) {
      if (result is CameraReady) await result.session.dispose();
      return;
    }
    switch (result) {
      case CameraReady(:final session):
        _faceSub = session.faces.listen(_onFaces);
        setState(() {
          _session = session;
          _lens = session.lens;
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

  void _onFaces(List<Rect> faces) {
    _faces = faces;
    if (!_evaluateFace()) {
      // Bingkai belum tergambar: nilai lagi setelah frame berikutnya.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _evaluateFace();
      });
    }
  }

  /// Menghitung status wajah terhadap bingkai. `false` bila tata letak belum
  /// siap.
  bool _evaluateFace() {
    final preview = _previewKey.currentContext?.findRenderObject();
    final guide = _guideKey.currentContext?.findRenderObject();
    if (preview is! RenderBox ||
        guide is! RenderBox ||
        !preview.hasSize ||
        !guide.hasSize ||
        preview.size.isEmpty) {
      return false;
    }
    final topLeft = guide.localToGlobal(Offset.zero, ancestor: preview);
    final box = preview.size;
    final guideRect = Rect.fromLTWH(
      topLeft.dx / box.width,
      topLeft.dy / box.height,
      guide.size.width / box.width,
      guide.size.height / box.height,
    );
    final status = faceStatusFor(_faces, guideRect);
    if (status != _face) setState(() => _face = status);
    _armAutoCapture();
    return true;
  }

  bool get _canShoot =>
      _step == _Step.camera &&
      _ui == _CameraUi.ready &&
      _session != null &&
      !_capturing &&
      _face == FaceStatus.inside;

  /// Wajah di dalam bingkai terus-menerus selama [autoCaptureDelay] -> jepret.
  void _armAutoCapture() {
    if (!_canShoot) {
      _autoTimer?.cancel();
      _autoTimer = null;
      return;
    }
    _autoTimer ??= Timer(autoCaptureDelay, () {
      _autoTimer = null;
      if (mounted && _canShoot) _shoot();
    });
  }

  Future<void> _shoot() async {
    final session = _session;
    if (session == null || !_canShoot) return;
    _autoTimer?.cancel();
    _autoTimer = null;
    setState(() {
      _capturing = true;
      _captureError = null;
    });
    final String path;
    try {
      path = await session.capture();
    } on Object {
      if (mounted) {
        setState(() {
          _capturing = false;
          _captureError = 'Gagal mengambil foto. Coba lagi.';
        });
      }
      return;
    }
    if (!mounted) return;
    ref.read(punchFlowProvider.notifier).setPhoto(path);
    _closeSession();
    setState(() {
      _capturing = false;
      _torch = false;
      _step = _Step.confirm;
    });
  }

  Future<void> _flip() async {
    final session = _session;
    if (session == null || !session.canFlip || _capturing) return;
    _lens = _lens == CameraLens.front ? CameraLens.back : CameraLens.front;
    _closeSession();
    setState(() => _torch = false);
    await _open();
  }

  Future<void> _toggleTorch() async {
    final session = _session;
    if (session == null) return;
    final ok = await session.setTorch(!_torch);
    if (!mounted) return;
    if (ok) {
      setState(() => _torch = !_torch);
    } else {
      AppToast.show(
        context,
        'Lampu senter tidak tersedia di kamera ini.',
        kind: ToastKind.info,
      );
    }
  }

  Future<void> _retake() async {
    if (_sending) return;
    await ref.read(punchFlowProvider.notifier).discardPhoto();
    if (!mounted) return;
    setState(() => _step = _Step.camera);
    await _open();
  }

  Future<void> _submit() async {
    if (_sending) return;
    setState(() => _sending = true);
    await submitAndShowOutcome(context, ref);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _Step.camera,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _retake();
      },
      child: _step == _Step.camera ? _buildCamera(context) : _buildConfirm(),
    );
  }

  Widget _buildCamera(BuildContext context) {
    final c = context.colors;
    final ready = _ui == _CameraUi.ready && _session != null;
    final problem = _ui == _CameraUi.denied || _ui == _CameraUi.unavailable;
    final tall = MediaQuery.sizeOf(context).height >= 700;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.cameraBackground,
        body: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox.expand(
                key: _previewKey,
                child: Semantics(
                  label: ready
                      ? 'Pratinjau kamera ${_lens == CameraLens.front ? 'depan' : 'belakang'}'
                      : 'Kamera belum siap',
                  child: ready
                      ? _session!.buildPreview()
                      : const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.cameraGradient,
                          ),
                        ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, .25, .75, 1],
                    colors: [
                      AppColors.cameraScrimTop,
                      Color(0x00000000),
                      Color(0x00000000),
                      AppColors.cameraScrimBottom,
                    ],
                  ),
                ),
              ),
              if (AppConfig.debugTools &&
                  ready &&
                  _session?.diagnostics != null)
                _FaceDiagnostics(diagnostics: _session!.diagnostics!),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, tall ? 16 : 8, 24, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _GlassIconButton(
                            icon: PhosphorIconsBold.x,
                            label: 'Tutup kamera',
                            onTap: () => context.pop(),
                          ),
                          const Expanded(
                            child: Center(child: _StepPill(current: 2)),
                          ),
                          _GlassIconButton(
                            key: const Key('torch'),
                            icon: _torch
                                ? PhosphorIconsFill.flashlight
                                : PhosphorIconsRegular.flashlight,
                            label: _torch
                                ? 'Matikan lampu senter'
                                : 'Nyalakan lampu senter',
                            onTap: ready ? _toggleTorch : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _StepProgress(current: 2, dark: true),
                      SizedBox(height: tall ? 32 : 16),
                      _Headline(showNote: tall),
                      Expanded(
                        child: problem
                            ? _Problem(
                                denied: _ui == _CameraUi.denied,
                                message: _message ?? '',
                                onRetry: _open,
                              )
                            : _GuideArea(
                                guideKey: _guideKey,
                                status: ready ? _face : null,
                                opening: _ui == _CameraUi.opening,
                              ),
                      ),
                      if (_captureError != null) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _captureError!,
                            textAlign: TextAlign.center,
                            style: AppType.smallBold.copyWith(
                              color: c.errorBorder,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 64),
                          _Shutter(
                            enabled: _canShoot,
                            capturing: _capturing,
                            onTap: _shoot,
                          ),
                          SizedBox(
                            width: 64,
                            child: _FlipControl(
                              onTap: ready && (_session?.canFlip ?? false)
                                  ? _flip
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: tall ? 20 : 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PhosphorIcon(
                            PhosphorIconsRegular.info,
                            size: 14,
                            color: Colors.white.withValues(alpha: .7),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Foto diambil otomatis saat wajah stabil di bingkai.',
                              textAlign: TextAlign.center,
                              style: AppType.caption.copyWith(
                                color: Colors.white.withValues(alpha: .7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirm() {
    final c = context.colors;
    final flow = ref.watch(punchFlowProvider);
    final title = flow.target.title;
    final accuracy = flow.fix == null
        ? ''
        : ' · akurasi ${flow.fix!.accuracyMeters} m';
    final location = switch (flow.phase) {
      LocationPhase.locating => 'Mencari lokasi…',
      LocationPhase.inside => 'Di dalam area kantor$accuracy',
      LocationPhase.outside => 'Di luar area kantor$accuracy',
      LocationPhase.located => 'Lokasi ditemukan$accuracy',
      LocationPhase.denied => 'Lokasi tidak tersedia',
    };

    return AppScaffold(
      body: Column(
        children: [
          PageHeader(title: title, onBack: _retake),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screenH,
                4,
                AppSpace.screenH,
                24,
              ),
              children: [
                const _StepPill(current: 3, dark: false),
                const SizedBox(height: 10),
                const _StepProgress(current: 3, dark: false),
                const SizedBox(height: 18),
                Semantics(
                  header: true,
                  child: Text(
                    'Konfirmasi $title',
                    style: AppType.title.copyWith(color: c.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Periksa kembali sebelum mengirim.',
                  style: AppType.small.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: 16),
                _PhotoCard(path: flow.photoPath),
                const SizedBox(height: AppSpace.block),
                AppCard(
                  secondary: true,
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: PhosphorIconsRegular.user,
                        label: 'Jenis',
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: c.mintTint,
                              borderRadius: BorderRadius.circular(
                                AppRadius.chip,
                              ),
                            ),
                            child: Text(
                              title,
                              style: AppType.captionBold.copyWith(
                                color: c.successText,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _DetailRow(
                        icon: PhosphorIconsRegular.mapPin,
                        label: 'Lokasi',
                        value: location,
                      ),
                      const _DetailRow(
                        icon: PhosphorIconsRegular.clock,
                        label: 'Waktu',
                        value: 'Dicatat oleh server saat dikirim',
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  key: const Key('submit-photo'),
                  label: 'Kirim $title',
                  icon: PhosphorIconsBold.caretRight,
                  height: 72,
                  loading: _sending,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    key: const Key('retake'),
                    onPressed: _sending ? null : _retake,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(
                        AppSpace.minTouch * 3,
                        AppSpace.minTouch,
                      ),
                      foregroundColor: c.accentText,
                      textStyle: AppType.button,
                    ),
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.cameraRotate,
                      size: 18,
                    ),
                    label: const Text('Foto Ulang'),
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

class _Headline extends StatelessWidget {
  const _Headline({required this.showNote});

  final bool showNote;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Posisikan wajah Anda\n'),
                      TextSpan(
                        text: 'di dalam bingkai.',
                        style: TextStyle(color: c.mint400),
                      ),
                    ],
                  ),
                  style: AppType.brand.copyWith(
                    fontSize: 28,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
              ),
              if (showNote) ...[
                const SizedBox(height: 12),
                Text(
                  'Pastikan Anda berada di area yang cukup terang agar wajah '
                  'terlihat jelas.',
                  style: AppType.body.copyWith(
                    color: Colors.white.withValues(alpha: .75),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bingkai wajah 3:4 (maks 288x384) dengan empat sudut dan pil status.
class _GuideArea extends StatelessWidget {
  const _GuideArea({
    required this.guideKey,
    required this.status,
    required this.opening,
  });

  final GlobalKey guideKey;

  /// `null` = kamera belum siap.
  final FaceStatus? status;
  final bool opening;

  static const _pillSpace = 72.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = (constraints.maxHeight - _pillSpace).clamp(0.0, 384.0);
        final height = [
          maxH,
          constraints.maxWidth * 4 / 3,
          384.0,
        ].reduce((a, b) => a < b ? a : b);
        final width = height * 3 / 4;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                key: guideKey,
                width: width,
                height: height,
                child: Stack(
                  children: [
                    for (final a in const [
                      Alignment.topLeft,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                      Alignment.bottomRight,
                    ])
                      _FrameCorner(alignment: a),
                    if (opening)
                      const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _StatusPill(status: status),
            ],
          ),
        );
      },
    );
  }
}

class _FrameCorner extends StatelessWidget {
  const _FrameCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: context.colors.mint400, width: 4);
    const r = Radius.circular(24);
    final top = alignment.y < 0;
    final left = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: top ? BorderSide.none : side,
            left: left ? side : BorderSide.none,
            right: left ? BorderSide.none : side,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? r : Radius.zero,
            topRight: top && !left ? r : Radius.zero,
            bottomLeft: !top && left ? r : Radius.zero,
            bottomRight: !top && !left ? r : Radius.zero,
          ),
        ),
      ),
    );
  }
}

/// Status wajah. Tampilan berganti seketika, tetapi screen reader hanya
/// diberi tahu setelah status stabil ([_settle]), agar TalkBack tidak terus
/// berbicara saat wajah keluar-masuk bingkai.
class _StatusPill extends StatefulWidget {
  const _StatusPill({required this.status});

  final FaceStatus? status;

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill> {
  static const _settle = Duration(milliseconds: 700);

  late String _spoken = _spokenFor(widget.status);
  Timer? _timer;

  static String _spokenFor(FaceStatus? status) => switch (status) {
    null => 'Membuka kamera',
    FaceStatus.inside => 'Wajah terdeteksi',
    FaceStatus.outside => 'Sejajarkan wajah ke bingkai',
    FaceStatus.none => 'Wajah tidak terdeteksi',
  };

  @override
  void didUpdateWidget(_StatusPill old) {
    super.didUpdateWidget(old);
    if (old.status == widget.status) return;
    _timer?.cancel();
    final next = _spokenFor(widget.status);
    _timer = Timer(_settle, () {
      if (mounted && next != _spoken) setState(() => _spoken = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = widget.status;
    final inside = status == FaceStatus.inside;
    final text = switch (status) {
      null => 'MEMBUKA KAMERA…',
      FaceStatus.inside => 'WAJAH TERDETEKSI',
      FaceStatus.outside => 'SEJAJARKAN WAJAH KE BINGKAI',
      FaceStatus.none => 'WAJAH TIDAK TERDETEKSI',
    };
    return Semantics(
      container: true,
      liveRegion: true,
      label: _spoken,
      child: ExcludeSemantics(
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey(text),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: inside
                  ? c.gradientStart.withValues(alpha: .95)
                  : AppColors.cameraBackground.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (inside)
                  const PhosphorIcon(
                    PhosphorIconsFill.checkCircle,
                    size: 16,
                    color: Colors.white,
                  )
                else
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    text,
                    key: const Key('face-status'),
                    textAlign: TextAlign.center,
                    style: AppType.smallBold.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({
    required this.enabled,
    required this.capturing,
    required this.onTap,
  });

  final bool enabled;
  final bool capturing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      enabled: enabled,
      label: capturing ? 'Memotret' : 'Ambil foto',
      hint: enabled || capturing ? null : 'Aktif saat wajah ada di bingkai',
      excludeSemantics: true,
      child: GestureDetector(
        key: const Key('shutter'),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 104,
          height: 104,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: .15),
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: enabled ? c.buttonShadow : null,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: enabled || capturing ? c.primaryGradient : null,
                color: enabled || capturing
                    ? null
                    : AppColors.cameraShutterIdle,
              ),
              child: Center(
                child: capturing
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : PhosphorIcon(
                        PhosphorIconsFill.camera,
                        size: 38,
                        color: Colors.white.withValues(alpha: enabled ? 1 : .5),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlipControl extends StatelessWidget {
  const _FlipControl({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Balik kamera',
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : .4,
        child: Column(
          children: [
            Material(
              color: Colors.white.withValues(alpha: .10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withValues(alpha: .06)),
              ),
              child: InkWell(
                key: const Key('flip'),
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: const SizedBox(
                  width: AppSpace.minTouch,
                  height: AppSpace.minTouch,
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.cameraRotate,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'BALIK',
              style: AppType.microBold.copyWith(
                color: Colors.white.withValues(alpha: .75),
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: onTap == null ? .4 : 1,
        child: Material(
          color: Colors.white.withValues(alpha: .12),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: AppSpace.minTouch,
              height: AppSpace.minTouch,
              child: Center(
                child: PhosphorIcon(icon, size: 22, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.current, this.dark = true});

  final int current;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Text(
      'LANGKAH $current DARI 3',
      style: AppType.captionBold.copyWith(
        color: dark ? Colors.white : c.textMuted,
        letterSpacing: 1.1,
      ),
    );
    if (!dark) return text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: text,
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.dark});

  final int current;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = dark ? Colors.white : c.accent;
    final off = dark ? Colors.white.withValues(alpha: .22) : c.divider;
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 1; i <= 3; i++) ...[
            if (i > 1) const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: i <= current ? on : off,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final p = path;
    final Widget image = p == null || p.startsWith('mock://')
        ? DecoratedBox(
            decoration: const BoxDecoration(gradient: AppColors.cameraGradient),
            child: Center(
              child: PhosphorIcon(
                PhosphorIconsFill.user,
                size: 96,
                color: Colors.white.withValues(alpha: .35),
              ),
            ),
          )
        : Image.file(File(p), fit: BoxFit.cover, gaplessPlayback: true);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 340),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Semantics(
            image: true,
            label: 'Foto selfie yang akan dikirim',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: image,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.child,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.rowDivider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(icon, size: 18, color: c.tealIcon),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: AppType.small.copyWith(color: c.textMuted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                child ??
                Text(
                  value ?? '',
                  style: AppType.smallBold.copyWith(color: c.textPrimary),
                ),
          ),
        ],
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}

/// Baris diagnostik deteksi wajah untuk build uji (`DEBUG_TOOLS=true`).
class _FaceDiagnostics extends StatelessWidget {
  const _FaceDiagnostics({required this.diagnostics});

  final ValueListenable<String> diagnostics;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 150,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xB3000000),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ValueListenableBuilder<String>(
              valueListenable: diagnostics,
              builder: (_, text, _) => Text(
                text,
                key: const Key('face-diagnostics'),
                style: const TextStyle(
                  color: Color(0xFFB9F6CA),
                  fontSize: 10,
                  height: 1.3,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
