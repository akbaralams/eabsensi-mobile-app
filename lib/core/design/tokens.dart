import 'package:flutter/material.dart';

/// Token desain eAbsensi (sumber: docs/design/README.md).
/// Widget fitur tidak boleh menulis warna atau ukuran langsung; pakai token ini.

const fontFamily = 'PlusJakartaSans';

/// Palet warna semantik. Satu instance untuk terang, satu untuk gelap.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.isDark,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.blobMint,
    required this.blobTeal,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.divider,
    required this.rowDivider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentText,
    required this.primary,
    required this.mint400,
    required this.mint300,
    required this.teal,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onGradient,
    required this.mintTint,
    required this.tealTint,
    required this.tealIcon,
    required this.statHadir,
    required this.successTint,
    required this.successText,
    required this.amber,
    required this.amberIcon,
    required this.amberTint,
    required this.amberText,
    required this.amberSoft,
    required this.errorText,
    required this.errorStrong,
    required this.errorTint,
    required this.errorSoft,
    required this.errorBorder,
    required this.shadow,
    required this.toastBackground,
    required this.toastText,
  });

  final bool isDark;

  // Latar layar
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color blobMint;
  final Color blobTeal;

  // Permukaan
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color divider;
  final Color rowDivider;

  // Teks
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Aksen
  final Color accent; // ikon/aksen hijau (primaryDark)
  final Color accentText; // teks aksen di atas surface (kontras >= 4.5:1)
  final Color primary;
  final Color mint400;
  final Color mint300;
  final Color teal;
  final Color gradientStart;
  final Color gradientEnd;
  final Color onGradient;

  // Tint
  final Color mintTint;
  final Color tealTint;
  final Color tealIcon;
  final Color statHadir;
  final Color successTint;
  final Color successText;
  final Color amber;
  final Color amberIcon;
  final Color amberTint;
  final Color amberText;
  final Color amberSoft;
  final Color errorText;
  final Color errorStrong;
  final Color errorTint;
  final Color errorSoft;
  final Color errorBorder;

  final Color shadow;
  final Color toastBackground;
  final Color toastText;

  static const light = AppColors(
    isDark: false,
    backgroundTop: Color(0xFFF0FDF4),
    backgroundBottom: Color(0xFFFFFFFF),
    blobMint: Color(0xFFD1FAE5),
    blobTeal: Color(0xFFCCFBF1),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0FDF4),
    border: Color(0xFF7A9A8D),
    divider: Color(0xFFE3EFE9),
    rowDivider: Color(0xFFF0F5F2),
    textPrimary: Color(0xFF053B2C),
    textSecondary: Color(0xFF3F5F53),
    textMuted: Color(0xFF4B6B5F),
    accent: Color(0xFF059669),
    accentText: Color(0xFF047857),
    primary: Color(0xFF10B981),
    mint400: Color(0xFF34D399),
    mint300: Color(0xFF6EE7B7),
    teal: Color(0xFF14B8A6),
    gradientStart: Color(0xFF047857),
    gradientEnd: Color(0xFF0F766E),
    onGradient: Color(0xFFFFFFFF),
    mintTint: Color(0xFFD1FAE5),
    tealTint: Color(0xFFCCFBF1),
    tealIcon: Color(0xFF0D9488),
    statHadir: Color(0xFFECFDF5),
    successTint: Color(0xFFD1FAE5),
    successText: Color(0xFF047857),
    amber: Color(0xFFF59E0B),
    amberIcon: Color(0xFFB45309),
    amberTint: Color(0xFFFEF3C7),
    amberText: Color(0xFF92400E),
    amberSoft: Color(0xFFFFFBEB),
    errorText: Color(0xFFB91C1C),
    errorStrong: Color(0xFFB91C1C),
    errorTint: Color(0xFFFEE2E2),
    errorSoft: Color(0xFFFEF2F2),
    errorBorder: Color(0xFFF87171),
    shadow: Color(0xFF064E3B),
    toastBackground: Color(0xFF053B2C),
    toastText: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    isDark: true,
    backgroundTop: Color(0xFF0B3B33),
    backgroundBottom: Color(0xFF0F172A),
    blobMint: Color(0x33064E3B),
    blobTeal: Color(0x2214B8A6),
    surface: Color(0xFF1E293B),
    surfaceAlt: Color(0xFF334155),
    border: Color(0xFF64748B),
    divider: Color(0xFF334155),
    rowDivider: Color(0xFF2B3A4F),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textMuted: Color(0xFFA3B1C6),
    accent: Color(0xFF34D399),
    accentText: Color(0xFF6EE7B7),
    primary: Color(0xFF10B981),
    mint400: Color(0xFF34D399),
    mint300: Color(0xFF6EE7B7),
    teal: Color(0xFF14B8A6),
    gradientStart: Color(0xFF047857),
    gradientEnd: Color(0xFF0F766E),
    onGradient: Color(0xFFFFFFFF),
    mintTint: Color(0xFF064E3B),
    tealTint: Color(0xFF134E4A),
    tealIcon: Color(0xFF14B8A6),
    statHadir: Color(0xFF064E3B),
    successTint: Color(0xFF064E3B),
    successText: Color(0xFF6EE7B7),
    amber: Color(0xFFF59E0B),
    amberIcon: Color(0xFFFBBF24),
    amberTint: Color(0x2EF59E0B),
    amberText: Color(0xFFFBBF24),
    amberSoft: Color(0x1FF59E0B),
    errorText: Color(0xFFFCA5A5),
    errorStrong: Color(0xFFFCA5A5),
    errorTint: Color(0x2EEF4444),
    errorSoft: Color(0x1FEF4444),
    errorBorder: Color(0xFFF87171),
    shadow: Color(0xFF000000),
    toastBackground: Color(0xFFF8FAFC),
    toastText: Color(0xFF0F172A),
  );

  /// Gradien tombol utama.
  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientEnd],
  );

  /// Gradien badge jam, avatar, dan logo.
  LinearGradient get badgeGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint300, teal],
  );

  LinearGradient get bannerGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [mintTint, tealTint],
  );

  /// Orb hasil absen (tidak berubah antar mode).
  static const successOrbGradient = RadialGradient(
    center: Alignment(-.3, -.3),
    stops: [0, .35, 1],
    colors: [Color(0xFFFFFFFF), Color(0xFF34D399), Color(0xFF059669)],
  );
  static const warningOrbGradient = RadialGradient(
    center: Alignment(-.3, -.3),
    stops: [0, .35, 1],
    colors: [Color(0xFFFFFFFF), Color(0xFFFBBF24), Color(0xFFD97706)],
  );
  static const successOrbShadow = Color(0xFF059669);
  static const warningOrbShadow = Color(0xFFD97706);

  /// Penggelap area di luar bingkai oval kamera.
  static const cameraMask = Color(0x4D064E3B);

  /// Bayangan dan isi lencana jam di beranda.
  static const badgeShadow = Color(0x4D0D9488);
  static const badgeGlyph = Color(0xFF047857);

  /// Latar kamera / pemindai QR.
  static const cameraGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.6, 1],
    colors: [Color(0xFF064E3B), Color(0xFF0F766E), Color(0xFF14B8A6)],
  );

  List<BoxShadow> get cardShadow => _shadow(0, 8, 28, isDark ? .35 : .07);
  List<BoxShadow> get tileShadow => _shadow(0, 6, 20, isDark ? .3 : .06);
  List<BoxShadow> get softShadow => _shadow(0, 4, 14, isDark ? .3 : .05);
  List<BoxShadow> get circleShadow => _shadow(0, 4, 14, isDark ? .3 : .08);
  List<BoxShadow> get navShadow => _shadow(0, -6, 24, isDark ? .3 : .06);
  List<BoxShadow> get toastShadow => _shadow(0, 10, 30, isDark ? .4 : .3);
  List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(0xFF059669).withValues(alpha: .28),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  List<BoxShadow> _shadow(double dx, double dy, double blur, double alpha) => [
    BoxShadow(
      color: shadow.withValues(alpha: alpha),
      blurRadius: blur,
      offset: Offset(dx, dy),
    ),
  ];

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < .5 ? this : other;
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

/// Radius (logical px).
abstract final class AppRadius {
  static const card = 24.0;
  static const cardSecondary = 22.0;
  static const listItem = 16.0;
  static const tile = 18.0;
  static const button = 16.0;
  static const input = 14.0;
  static const segmentTrack = 14.0;
  static const segment = 11.0;
  static const iconBox = 13.0;
  static const chip = 999.0;
  static const navTop = 26.0;
  static const sheetTop = 28.0;
}

/// Jarak (logical px).
abstract final class AppSpace {
  static const screenH = 18.0;
  static const block = 14.0;
  static const card = 16.0;
  static const grid = 10.0;
  static const minTouch = 48.0;
  static const buttonHeight = 54.0;
  static const inputHeight = 50.0;
  static const menuItemHeight = 54.0;
  static const navHeight = 88.0;
  static const contentBottom = 110.0;
}

/// Skala tipe. Warna diberikan oleh widget pemakai.
abstract final class AppType {
  static const _base = TextStyle(fontFamily: fontFamily);

  static final brand = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.64,
  );
  static final clock = _base.copyWith(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.76,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final resultTime = _base.copyWith(
    fontSize: 60,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.8,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final title = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  static final header = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );
  static final cardTitle = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static final body = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
  static final bodyBold = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  static final small = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
  static final smallBold = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  static final caption = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static final captionBold = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static final micro = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
  static final microBold = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );
  static final button = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
}
