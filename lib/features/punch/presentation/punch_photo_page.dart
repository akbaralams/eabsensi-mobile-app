import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import 'punch_actions.dart';
import 'punch_providers.dart';

/// Langkah foto. Pratinjau kamera di tahap dummy disimulasikan; integrasi
/// kamera nyata menyusul bersama client API (lihat docs/design/DEVIATIONS.md).
class PunchPhotoPage extends ConsumerStatefulWidget {
  const PunchPhotoPage({super.key});

  @override
  ConsumerState<PunchPhotoPage> createState() => _PunchPhotoPageState();
}

class _PunchPhotoPageState extends ConsumerState<PunchPhotoPage> {
  bool _sending = false;

  Future<void> _shoot() async {
    if (_sending) return;
    setState(() => _sending = true);
    ref
        .read(punchFlowProvider.notifier)
        .setPhoto('mock://selfie-${DateTime.now().millisecondsSinceEpoch}.jpg');
    await submitAndShowOutcome(context, ref);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
                _Preview(sending: _sending),
                const SizedBox(height: 24),
                Center(
                  child: Semantics(
                    button: true,
                    label: _sending ? 'Mengirim foto' : 'Ambil foto',
                    excludeSemantics: true,
                    child: GestureDetector(
                      key: const Key('shutter'),
                      onTap: _sending ? null : _shoot,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.sending});

  final bool sending;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Pratinjau kamera depan',
      image: true,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          gradient: AppColors.cameraGradient,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: CustomPaint(
                size: const Size(double.infinity, 400),
                painter: _OvalMaskPainter(),
              ),
            ),
            PhosphorIcon(
              PhosphorIconsFill.user,
              size: 96,
              color: Colors.white.withValues(alpha: .25),
            ),
            Positioned(
              bottom: 14,
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
                      sending
                          ? PhosphorIconsRegular.circleNotch
                          : PhosphorIconsFill.checkCircle,
                      size: 16,
                      color: c.accentText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sending ? 'Mengirim…' : 'Wajah terdeteksi',
                      style: AppType.captionBold.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
