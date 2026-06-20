import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'aurora_tokens.dart';

abstract final class AuroraTheme {
  static ThemeData light() => _build(
        tokens: AuroraTokens.light,
        brightness: Brightness.light,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AuroraTokens.light.backgroundCanvas,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

  static ThemeData dark() => _build(
        tokens: AuroraTokens.dark,
        brightness: Brightness.dark,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AuroraTokens.dark.backgroundCanvas,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

  static ThemeData _build({
    required AuroraTokens tokens,
    required Brightness brightness,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.brandGradientStart,
      onPrimary: tokens.textOnBrand,
      primaryContainer: tokens.backgroundSurface,
      onPrimaryContainer: tokens.textPrimary,
      secondary: tokens.brandGradientMid,
      onSecondary: tokens.textOnBrand,
      secondaryContainer: tokens.backgroundSurfaceElevated,
      onSecondaryContainer: tokens.textPrimary,
      tertiary: tokens.brandGradientEnd,
      onTertiary: tokens.textOnBrand,
      tertiaryContainer: tokens.backgroundSurfaceElevated,
      onTertiaryContainer: tokens.textPrimary,
      error: tokens.stateError,
      onError: tokens.textOnBrand,
      errorContainer: tokens.stateErrorSurface,
      onErrorContainer: tokens.stateError,
      surface: tokens.backgroundSurface,
      onSurface: tokens.textPrimary,
      surfaceContainerHighest: tokens.backgroundSurfaceElevated,
      onSurfaceVariant: tokens.textSecondary,
      outline: tokens.borderDefault,
      outlineVariant: tokens.borderSubtle,
      shadow: Colors.black,
      scrim: tokens.backgroundOverlay,
      inverseSurface: tokens.textPrimary,
      onInverseSurface: tokens.backgroundCanvas,
      inversePrimary: tokens.brandGradientMid,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.backgroundCanvas,

      extensions: [tokens],

      // ── Typography ─────────────────────────────────────────────────────
      textTheme: _buildTextTheme(tokens, brightness),

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: systemOverlayStyle,
        centerTitle: true,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: tokens.textPrimary,
        ),
        iconTheme: IconThemeData(color: tokens.textPrimary),
      ),

      // ── BottomNavigationBar ────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.backgroundSurface,
        indicatorColor: tokens.brandGradientStart.withAlpha(26),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? tokens.brandGradientStart : tokens.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? tokens.brandGradientStart : tokens.textTertiary,
            size: 24,
          );
        }),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.brandGradientStart,
          foregroundColor: tokens.textOnBrand,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.brandGradientStart,
          side: BorderSide(color: tokens.brandGradientStart, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.brandGradientStart,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      // ── InputDecoration ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.backgroundSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.brandGradientStart, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.stateError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.stateError, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: tokens.textTertiary,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: tokens.textSecondary,
          fontSize: 15,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: tokens.backgroundSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          side: BorderSide(color: tokens.borderSubtle),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: tokens.backgroundSurfaceElevated,
        selectedColor: tokens.brandGradientStart.withAlpha(26),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: tokens.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          side: BorderSide(color: tokens.borderDefault),
        ),
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: tokens.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          color: tokens.backgroundCanvas,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── BottomSheet ────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.backgroundSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusXl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: tokens.borderDefault,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.backgroundSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusXl),
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: tokens.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 15,
          color: tokens.textSecondary,
        ),
      ),

      // ── ListTile ───────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: tokens.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: tokens.textSecondary,
        ),
      ),

      // ── Switch ─────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? tokens.textOnBrand
              : tokens.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? tokens.brandGradientStart
              : tokens.borderDefault;
        }),
      ),

      // ── ProgressIndicator ──────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.brandGradientStart,
        linearTrackColor: tokens.borderSubtle,
        circularTrackColor: tokens.borderSubtle,
      ),
    );
  }

  static TextTheme _buildTextTheme(AuroraTokens tokens, Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.blackMountainView
        : Typography.whiteMountainView;

    return base.copyWith(
      // Display — SpaceGrotesk
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: tokens.textPrimary,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: tokens.textPrimary,
      ),
      // Headline — SpaceGrotesk
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: tokens.textPrimary,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: tokens.textPrimary,
      ),
      // Title — SpaceGrotesk
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: tokens.textPrimary,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: tokens.textPrimary,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: tokens.textPrimary,
      ),
      // Body — Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: tokens.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: tokens.textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: tokens.textTertiary,
      ),
      // Label — Inter
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: tokens.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: tokens.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: tokens.textTertiary,
      ),
    );
  }
}
