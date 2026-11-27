import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/theme/sheet_border.dart';

class AppTheme {
  AppTheme._();

  // Archivo is bundled as one variable font. fontWeight drives the wght axis,
  // so only the width axis is set here. Tabular figures keep counts still
  static TextStyle archivo(
    double size,
    FontWeight weight, {
    double width = 100,
    double? height,
    double spacing = 0,
  }) => TextStyle(
    fontFamily: 'Archivo',
    fontSize: size,
    height: height,
    letterSpacing: size * spacing,
    fontWeight: weight,
    fontVariations: [FontVariation.width(width)],
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // Wide and heavy for names and numbers, normal width for reading
  static TextTheme _textTheme(AppColors c) {
    const w4 = FontWeight.w400;
    const w6 = FontWeight.w600;
    const w8 = FontWeight.w800;
    const w9 = FontWeight.w900;

    return TextTheme(
      displayLarge: archivo(52, w9, width: 125, height: 0.85, spacing: -0.035),
      displayMedium: archivo(56, w9, width: 125, height: 1, spacing: -0.02),
      displaySmall: archivo(40, w9, width: 122, height: 1, spacing: -0.02),
      headlineLarge: archivo(32, w9, width: 118, height: 0.98, spacing: -0.025),
      headlineMedium: archivo(28, w9, width: 116, height: 1, spacing: -0.02),
      headlineSmall: archivo(24, w9, width: 114, height: 1.05, spacing: -0.015),
      titleLarge: archivo(22, w8, width: 110, height: 1.1, spacing: -0.015),
      titleMedium: archivo(20, w8, width: 108, height: 1.15),
      titleSmall: archivo(20, w9, width: 112, height: 1.1),
      bodyLarge: archivo(16, w4, height: 1.5),
      bodyMedium: archivo(14.5, w4, height: 1.45),
      bodySmall: archivo(13, w4, height: 1.4),
      labelLarge: archivo(16, w8, height: 1.2),
      labelMedium: archivo(13.5, w6, height: 1.3),
      labelSmall: archivo(12, w6, height: 1.3),
    ).apply(bodyColor: c.text, displayColor: c.text);
  }

  static ThemeData get light => _build(AppColors.light, Brightness.light);

  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = _textTheme(c);

    // Light mode outlines things that sit on chalk; dark mode stays flat
    final outline = isDark
        ? BorderSide.none
        : BorderSide(color: c.ink, width: 3);
    final inkLine = BorderSide(color: c.ink, width: 3);

    // Status and nav bar icons flip so they show on the background
    final overlay = SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: brightness,
      systemNavigationBarColor: c.background,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    OutlineInputBorder field(BorderSide side) => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: side,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Archivo',
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: c.primaryText,
        onPrimary: c.onPrimaryText,
        surface: c.background,
        outline: c.border,
        error: c.redText,
      ),
      textTheme: textTheme,
      extensions: [c],
      appBarTheme: AppBarTheme(
        systemOverlayStyle: overlay,
        backgroundColor: c.background,
        surfaceTintColor: AppColors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      // The primary button keeps its ink outline in both modes. PlateButton
      // adds the hard shadow; this covers plain FilledButtons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            side: inkLine,
          ),
        ),
      ),
      // Small button: outlined in light, a quiet border line in dark
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          backgroundColor: c.card,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(48, 48),
          side: isDark ? BorderSide(color: c.border, width: 2) : inkLine,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      // The secondary action is a bold link with a thick underline
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.text,
          textStyle: textTheme.labelLarge?.copyWith(
            decoration: TextDecoration.underline,
            decorationThickness: 2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: c.surface,
        border: field(outline),
        enabledBorder: field(outline),
        focusedBorder: field(isDark ? BorderSide(color: c.ink, width: 2) : inkLine),
        errorBorder: field(BorderSide(color: c.redText, width: 3)),
        focusedErrorBorder: field(BorderSide(color: c.redText, width: 3)),
        hintStyle: textTheme.bodyLarge?.copyWith(color: c.textSecondary),
        labelStyle: textTheme.bodyLarge?.copyWith(color: c.textSecondary),
        errorStyle: textTheme.bodySmall?.copyWith(color: c.redText),
      ),
      // Off: card with an ink ring. On: ink fill with the opposite text
      chipTheme: ChipThemeData(
        backgroundColor: c.card,
        selectedColor: c.ink,
        showCheckmark: false,
        labelStyle: textTheme.labelMedium?.copyWith(color: c.text),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: c.background,
        ),
        shape: StadiumBorder(side: BorderSide(color: c.ink, width: 2)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        modalBackgroundColor: c.card,
        surfaceTintColor: AppColors.transparent,
        dragHandleColor: c.textSecondary,
        clipBehavior: Clip.antiAlias,
        shape: SheetBorder(side: outline),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        surfaceTintColor: AppColors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: c.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(26)),
          side: outline,
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 2),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.card,
        elevation: 0,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.text),
        actionTextColor: c.primaryText,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          side: isDark ? BorderSide(color: c.border, width: 2) : inkLine,
        ),
      ),
    );
  }
}
