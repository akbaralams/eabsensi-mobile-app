// DIBANGKITKAN oleh tool/generate_phosphor_icons.py. Jangan diedit tangan.
// Ikon Phosphor (MIT) memakai berkas font dari paket phosphor_flutter.

import 'package:flutter/widgets.dart';

/// Pengganti widget `PhosphorIcon` dari paket (yang tidak bisa dikompilasi).
class PhosphorIcon extends StatelessWidget {
  const PhosphorIcon(this.icon, {this.size, this.color, super.key});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Icon(icon, size: size, color: color);
}

/// Ikon Duotone: glyph garis utama dan lapisan isi.
final class DuotoneIconData {
  const DuotoneIconData(this.main, this.secondary);

  final IconData main;
  final IconData secondary;
}

/// Satu warna untuk dua lapis: isi digambar dengan [secondaryOpacity]
/// (bawaan Phosphor 20%), jadi tetap satu aksen.
class PhosphorDuotoneIcon extends StatelessWidget {
  const PhosphorDuotoneIcon(
    this.icon, {
    this.size,
    this.color,
    this.secondaryOpacity = .2,
    super.key,
  });

  final DuotoneIconData icon;
  final double? size;
  final Color? color;
  final double secondaryOpacity;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Opacity(
        opacity: secondaryOpacity,
        child: Icon(icon.secondary, size: size, color: color),
      ),
      Icon(icon.main, size: size, color: color),
    ],
  );
}

abstract final class PhosphorIconsRegular {
  static const airplaneTilt = IconData(
    0xe5d6,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const arrowClockwise = IconData(
    0xe036,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const arrowLeft = IconData(
    0xe058,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const bell = IconData(
    0xe0ce,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const buildings = IconData(
    0xe102,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const calendarBlank = IconData(
    0xe10a,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const calendarCheck = IconData(
    0xe712,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const camera = IconData(
    0xe10e,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const cameraRotate = IconData(
    0xe7a4,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const caretDown = IconData(
    0xe136,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const caretLeft = IconData(
    0xe138,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const caretRight = IconData(
    0xe13a,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const circleNotch = IconData(
    0xeb44,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const clipboardText = IconData(
    0xe198,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const clock = IconData(
    0xe19a,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const clockCounterClockwise = IconData(
    0xe1a0,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const crosshair = IconData(
    0xe1d6,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const deviceMobile = IconData(
    0xe1e0,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const eye = IconData(
    0xe220,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const eyeSlash = IconData(
    0xe224,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const fileText = IconData(
    0xe23a,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const files = IconData(
    0xe710,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const flashlight = IconData(
    0xe246,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const flask = IconData(
    0xe79e,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const gearSix = IconData(
    0xe272,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const house = IconData(
    0xe2c2,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const info = IconData(
    0xe2ce,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const lock = IconData(
    0xe2fa,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const mapPin = IconData(
    0xe316,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const moon = IconData(
    0xe330,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const navigationArrow = IconData(
    0xeade,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const prohibit = IconData(
    0xe3de,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const signIn = IconData(
    0xe428,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const signOut = IconData(
    0xe42a,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const squaresFour = IconData(
    0xe464,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const stamp = IconData(
    0xea48,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const timer = IconData(
    0xe492,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const umbrella = IconData(
    0xe684,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const user = IconData(
    0xe4c2,
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
}

abstract final class PhosphorIconsFill {
  static const bellRinging = IconData(
    0xe5e8,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const camera = IconData(
    0xe10e,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const checkCircle = IconData(
    0xe184,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const clipboardText = IconData(
    0xe198,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const clockCountdown = IconData(
    0xed2c,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const clockCounterClockwise = IconData(
    0xe1a0,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const fileText = IconData(
    0xe23a,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const files = IconData(
    0xe710,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const flashlight = IconData(
    0xe246,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const hourglassMedium = IconData(
    0xe2b8,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const house = IconData(
    0xe2c2,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const info = IconData(
    0xe2ce,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const lock = IconData(
    0xe2fa,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const mapPin = IconData(
    0xe316,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const minusCircle = IconData(
    0xe32c,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const user = IconData(
    0xe4c2,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const warning = IconData(
    0xe4e0,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const warningCircle = IconData(
    0xe4e2,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const wifiSlash = IconData(
    0xe4f2,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const xCircle = IconData(
    0xe4f8,
    fontFamily: 'PhosphorFill',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
}

abstract final class PhosphorIconsBold {
  static const arrowRight = IconData(
    0xe06c,
    fontFamily: 'PhosphorBold',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const caretRight = IconData(
    0xe13a,
    fontFamily: 'PhosphorBold',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const check = IconData(
    0xe182,
    fontFamily: 'PhosphorBold',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const hourglassMedium = IconData(
    0xe2b8,
    fontFamily: 'PhosphorBold',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
  static const x = IconData(
    0xe4f6,
    fontFamily: 'PhosphorBold',
    fontPackage: 'phosphor_flutter',
    matchTextDirection: true,
  );
}

abstract final class PhosphorIconsDuotone {
  static const airplaneTilt = DuotoneIconData(
    IconData(
      0xe5d7,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe5d6,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const briefcase = DuotoneIconData(
    IconData(
      0xe0ef,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe0ee,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const clockCountdown = DuotoneIconData(
    IconData(
      0xed2d,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xed2c,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const firstAidKit = DuotoneIconData(
    IconData(
      0xe571,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe570,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const flag = DuotoneIconData(
    IconData(
      0xe245,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe244,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const graduationCap = DuotoneIconData(
    IconData(
      0xe62d,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe62c,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const hand = DuotoneIconData(
    IconData(
      0xe299,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe298,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const heartbeat = DuotoneIconData(
    IconData(
      0xe2ad,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe2ac,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const houseLine = DuotoneIconData(
    IconData(
      0xe2c5,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe2c4,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const moonStars = DuotoneIconData(
    IconData(
      0xe58f,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe58e,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const squaresFour = DuotoneIconData(
    IconData(
      0xe465,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe464,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const stamp = DuotoneIconData(
    IconData(
      0xea49,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xea48,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
  static const umbrella = DuotoneIconData(
    IconData(
      0xe685,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
    IconData(
      0xe684,
      fontFamily: 'PhosphorDuotone',
      fontPackage: 'phosphor_flutter',
      matchTextDirection: true,
    ),
  );
}
