import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aurora Design System — design tokens (ThemeExtension).
///
/// 3-level structure:
///   Primitive  →  Semantic (this file)  →  Component (per-widget)
///
/// Widgets read ONLY from semantic tokens — never from primitive colors directly.
@immutable
class AuroraTokens extends ThemeExtension<AuroraTokens> {
  const AuroraTokens({
    // ── Brand ──────────────────────────────────────────────────────────────
    required this.brandGradientStart,
    required this.brandGradientMid,
    required this.brandGradientEnd,
    // ── Background ─────────────────────────────────────────────────────────
    required this.backgroundCanvas,
    required this.backgroundSurface,
    required this.backgroundSurfaceElevated,
    required this.backgroundOverlay,
    // ── Glass ──────────────────────────────────────────────────────────────
    required this.glassFill,
    required this.glassBorder,
    // ── Text ───────────────────────────────────────────────────────────────
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnBrand,
    required this.textDisabled,
    // ── Border ─────────────────────────────────────────────────────────────
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderStrong,
    // ── State colors ───────────────────────────────────────────────────────
    required this.stateSuccess,
    required this.stateWarning,
    required this.stateError,
    required this.stateInfo,
    // ── State surfaces ─────────────────────────────────────────────────────
    required this.stateSuccessSurface,
    required this.stateWarningSurface,
    required this.stateErrorSurface,
    required this.stateInfoSurface,
    // ── Spacing ────────────────────────────────────────────────────────────
    required this.space2,
    required this.space4,
    required this.space8,
    required this.space12,
    required this.space16,
    required this.space20,
    required this.space24,
    required this.space32,
    required this.space40,
    required this.space48,
    required this.space64,
    // ── Border radius ──────────────────────────────────────────────────────
    required this.radiusXs,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusFull,
  });

  // ── Brand gradient (indigo → violet → pink) ─────────────────────────────
  final Color brandGradientStart;  // #6366f1
  final Color brandGradientMid;    // #8b5cf6
  final Color brandGradientEnd;    // #ec4899

  // ── Backgrounds ──────────────────────────────────────────────────────────
  final Color backgroundCanvas;
  final Color backgroundSurface;
  final Color backgroundSurfaceElevated;
  final Color backgroundOverlay;

  // ── Glass surfaces ────────────────────────────────────────────────────────
  final Color glassFill;
  final Color glassBorder;

  // ── Text ──────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnBrand;
  final Color textDisabled;

  // ── Borders ───────────────────────────────────────────────────────────────
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderStrong;

  // ── States ────────────────────────────────────────────────────────────────
  final Color stateSuccess;
  final Color stateWarning;
  final Color stateError;
  final Color stateInfo;
  final Color stateSuccessSurface;
  final Color stateWarningSurface;
  final Color stateErrorSurface;
  final Color stateInfoSurface;

  // ── Spacing (4px base grid) ───────────────────────────────────────────────
  final double space2;
  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space20;
  final double space24;
  final double space32;
  final double space40;
  final double space48;
  final double space64;

  // ── Border radius ─────────────────────────────────────────────────────────
  final double radiusXs;    // 6
  final double radiusSm;    // 10
  final double radiusMd;    // 14
  final double radiusLg;    // 20
  final double radiusXl;    // 28
  final double radiusFull;  // 999

  // ── Aliases & derived helpers ────────────────────────────────────────────

  // Color aliases used by dashboard widgets
  Color get surfaceCard => backgroundSurface;
  Color get surfaceSubtle => backgroundSurfaceElevated;
  Color get brandPrimary => brandGradientStart;

  // Radius aliases (short names)
  double get radiusS => radiusSm;
  double get radiusM => radiusMd;
  double get radiusL => radiusLg;
  double get radiusXL => radiusXl;

  // Extra spacing steps not in the base grid
  double get space6 => 6;
  double get space10 => 10;

  // Card shadow
  List<BoxShadow> get shadowCard => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  // Typography shortcuts — match aurora_theme.dart TextTheme entries
  TextStyle get displayLargeStyle => GoogleFonts.spaceGrotesk(fontSize: 57, fontWeight: FontWeight.w700, color: textPrimary);
  TextStyle get headlineMedium => GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary);
  TextStyle get headlineSmall => GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary);
  TextStyle get titleMedium => GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary);
  TextStyle get titleSmall => GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary);
  TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary);
  TextStyle get bodySmall => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textTertiary);
  TextStyle get labelLargeStyle => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary);
  TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary);
  TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textTertiary);

  // ── Derived ───────────────────────────────────────────────────────────────

  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        transform: const GradientRotation(135 * 3.14159 / 180),
        colors: [brandGradientStart, brandGradientMid, brandGradientEnd],
        stops: const [0.0, 0.5, 1.0],
      );

  BoxDecoration get glassDecoration => BoxDecoration(
        color: glassFill,
        border: Border.all(color: glassBorder, width: 1),
        borderRadius: BorderRadius.circular(radiusMd),
      );

  // ── Light theme ───────────────────────────────────────────────────────────

  static const light = AuroraTokens(
    brandGradientStart: Color(0xFF6366F1),
    brandGradientMid: Color(0xFF8B5CF6),
    brandGradientEnd: Color(0xFFEC4899),

    backgroundCanvas: Color(0xFFEDF5F2),
    backgroundSurface: Color(0xFFFFFFFF),
    backgroundSurfaceElevated: Color(0xFFF8FAFF),
    backgroundOverlay: Color(0x80000000),

    glassFill: Color(0xCCFFFFFF),
    glassBorder: Color(0x33FFFFFF),

    textPrimary: Color(0xFF0F1729),
    textSecondary: Color(0xFF4A5568),
    textTertiary: Color(0xFF718096),
    textOnBrand: Color(0xFFFFFFFF),
    textDisabled: Color(0xFFA0AEC0),

    borderDefault: Color(0xFFE2E8F0),
    borderSubtle: Color(0xFFF0F4FF),
    borderStrong: Color(0xFFCBD5E0),

    stateSuccess: Color(0xFF10B981),
    stateWarning: Color(0xFFF59E0B),
    stateError: Color(0xFFEF4444),
    stateInfo: Color(0xFF3B82F6),

    stateSuccessSurface: Color(0xFFECFDF5),
    stateWarningSurface: Color(0xFFFFFBEB),
    stateErrorSurface: Color(0xFFFEF2F2),
    stateInfoSurface: Color(0xFFEFF6FF),

    space2: 2,
    space4: 4,
    space8: 8,
    space12: 12,
    space16: 16,
    space20: 20,
    space24: 24,
    space32: 32,
    space40: 40,
    space48: 48,
    space64: 64,

    radiusXs: 6,
    radiusSm: 10,
    radiusMd: 14,
    radiusLg: 20,
    radiusXl: 28,
    radiusFull: 999,
  );

  // ── Dark theme ────────────────────────────────────────────────────────────

  static const dark = AuroraTokens(
    brandGradientStart: Color(0xFF6366F1),
    brandGradientMid: Color(0xFF8B5CF6),
    brandGradientEnd: Color(0xFFEC4899),

    backgroundCanvas: Color(0xFF0F1729),
    backgroundSurface: Color(0xFF1E2747),
    backgroundSurfaceElevated: Color(0xFF252D4A),
    backgroundOverlay: Color(0xB30F1729),

    glassFill: Color(0x1AFFFFFF),
    glassBorder: Color(0x1AFFFFFF),

    textPrimary: Color(0xFFF7F8FF),
    textSecondary: Color(0xFFB0B8D4),
    textTertiary: Color(0xFF6B7399),
    textOnBrand: Color(0xFFFFFFFF),
    textDisabled: Color(0xFF3D4663),

    borderDefault: Color(0xFF2D3561),
    borderSubtle: Color(0xFF1E2747),
    borderStrong: Color(0xFF3D4663),

    stateSuccess: Color(0xFF34D399),
    stateWarning: Color(0xFFFBBF24),
    stateError: Color(0xFFF87171),
    stateInfo: Color(0xFF60A5FA),

    stateSuccessSurface: Color(0xFF0D2E23),
    stateWarningSurface: Color(0xFF2D1F0A),
    stateErrorSurface: Color(0xFF2D1010),
    stateInfoSurface: Color(0xFF0D1F3D),

    space2: 2,
    space4: 4,
    space8: 8,
    space12: 12,
    space16: 16,
    space20: 20,
    space24: 24,
    space32: 32,
    space40: 40,
    space48: 48,
    space64: 64,

    radiusXs: 6,
    radiusSm: 10,
    radiusMd: 14,
    radiusLg: 20,
    radiusXl: 28,
    radiusFull: 999,
  );

  // ── ThemeExtension overrides ──────────────────────────────────────────────

  @override
  AuroraTokens copyWith({
    Color? brandGradientStart,
    Color? brandGradientMid,
    Color? brandGradientEnd,
    Color? backgroundCanvas,
    Color? backgroundSurface,
    Color? backgroundSurfaceElevated,
    Color? backgroundOverlay,
    Color? glassFill,
    Color? glassBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnBrand,
    Color? textDisabled,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderStrong,
    Color? stateSuccess,
    Color? stateWarning,
    Color? stateError,
    Color? stateInfo,
    Color? stateSuccessSurface,
    Color? stateWarningSurface,
    Color? stateErrorSurface,
    Color? stateInfoSurface,
    double? space2,
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space20,
    double? space24,
    double? space32,
    double? space40,
    double? space48,
    double? space64,
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
  }) =>
      AuroraTokens(
        brandGradientStart: brandGradientStart ?? this.brandGradientStart,
        brandGradientMid: brandGradientMid ?? this.brandGradientMid,
        brandGradientEnd: brandGradientEnd ?? this.brandGradientEnd,
        backgroundCanvas: backgroundCanvas ?? this.backgroundCanvas,
        backgroundSurface: backgroundSurface ?? this.backgroundSurface,
        backgroundSurfaceElevated:
            backgroundSurfaceElevated ?? this.backgroundSurfaceElevated,
        backgroundOverlay: backgroundOverlay ?? this.backgroundOverlay,
        glassFill: glassFill ?? this.glassFill,
        glassBorder: glassBorder ?? this.glassBorder,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        textOnBrand: textOnBrand ?? this.textOnBrand,
        textDisabled: textDisabled ?? this.textDisabled,
        borderDefault: borderDefault ?? this.borderDefault,
        borderSubtle: borderSubtle ?? this.borderSubtle,
        borderStrong: borderStrong ?? this.borderStrong,
        stateSuccess: stateSuccess ?? this.stateSuccess,
        stateWarning: stateWarning ?? this.stateWarning,
        stateError: stateError ?? this.stateError,
        stateInfo: stateInfo ?? this.stateInfo,
        stateSuccessSurface: stateSuccessSurface ?? this.stateSuccessSurface,
        stateWarningSurface: stateWarningSurface ?? this.stateWarningSurface,
        stateErrorSurface: stateErrorSurface ?? this.stateErrorSurface,
        stateInfoSurface: stateInfoSurface ?? this.stateInfoSurface,
        space2: space2 ?? this.space2,
        space4: space4 ?? this.space4,
        space8: space8 ?? this.space8,
        space12: space12 ?? this.space12,
        space16: space16 ?? this.space16,
        space20: space20 ?? this.space20,
        space24: space24 ?? this.space24,
        space32: space32 ?? this.space32,
        space40: space40 ?? this.space40,
        space48: space48 ?? this.space48,
        space64: space64 ?? this.space64,
        radiusXs: radiusXs ?? this.radiusXs,
        radiusSm: radiusSm ?? this.radiusSm,
        radiusMd: radiusMd ?? this.radiusMd,
        radiusLg: radiusLg ?? this.radiusLg,
        radiusXl: radiusXl ?? this.radiusXl,
        radiusFull: radiusFull ?? this.radiusFull,
      );

  @override
  AuroraTokens lerp(AuroraTokens? other, double t) {
    if (other == null) return this;
    return AuroraTokens(
      brandGradientStart: Color.lerp(brandGradientStart, other.brandGradientStart, t)!,
      brandGradientMid: Color.lerp(brandGradientMid, other.brandGradientMid, t)!,
      brandGradientEnd: Color.lerp(brandGradientEnd, other.brandGradientEnd, t)!,
      backgroundCanvas: Color.lerp(backgroundCanvas, other.backgroundCanvas, t)!,
      backgroundSurface: Color.lerp(backgroundSurface, other.backgroundSurface, t)!,
      backgroundSurfaceElevated: Color.lerp(backgroundSurfaceElevated, other.backgroundSurfaceElevated, t)!,
      backgroundOverlay: Color.lerp(backgroundOverlay, other.backgroundOverlay, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      stateSuccess: Color.lerp(stateSuccess, other.stateSuccess, t)!,
      stateWarning: Color.lerp(stateWarning, other.stateWarning, t)!,
      stateError: Color.lerp(stateError, other.stateError, t)!,
      stateInfo: Color.lerp(stateInfo, other.stateInfo, t)!,
      stateSuccessSurface: Color.lerp(stateSuccessSurface, other.stateSuccessSurface, t)!,
      stateWarningSurface: Color.lerp(stateWarningSurface, other.stateWarningSurface, t)!,
      stateErrorSurface: Color.lerp(stateErrorSurface, other.stateErrorSurface, t)!,
      stateInfoSurface: Color.lerp(stateInfoSurface, other.stateInfoSurface, t)!,
      space2: space2,
      space4: space4,
      space8: space8,
      space12: space12,
      space16: space16,
      space20: space20,
      space24: space24,
      space32: space32,
      space40: space40,
      space48: space48,
      space64: space64,
      radiusXs: radiusXs,
      radiusSm: radiusSm,
      radiusMd: radiusMd,
      radiusLg: radiusLg,
      radiusXl: radiusXl,
      radiusFull: radiusFull,
    );
  }
}

extension BuildContextAuroraX on BuildContext {
  AuroraTokens get aurora =>
      Theme.of(this).extension<AuroraTokens>() ?? AuroraTokens.light;
}
