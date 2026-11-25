import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repwise/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  // Set weights on Material's plain styles first, then hand them to
  // google_fonts. It loads each weight as its own family, so changing
  // fontWeight on an already-DM Sans style keeps the old file.
  static TextTheme _weighted(TextTheme base) {
    TextStyle? w(TextStyle? style, FontWeight weight) =>
        style?.copyWith(fontWeight: weight);

    return GoogleFonts.dmSansTextTheme(
      base.copyWith(
        displayLarge: w(base.displayLarge, FontWeight.w600),
        displayMedium: w(base.displayMedium, FontWeight.w600),
        displaySmall: w(base.displaySmall, FontWeight.w600),
        headlineLarge: w(base.headlineLarge, FontWeight.w800),
        headlineMedium: w(base.headlineMedium, FontWeight.w800),
        headlineSmall: w(base.headlineSmall, FontWeight.w800),
        titleLarge: w(base.titleLarge, FontWeight.w800),
        titleMedium: w(base.titleMedium, FontWeight.w600),
        titleSmall: w(base.titleSmall, FontWeight.w600),
        labelLarge: w(base.labelLarge, FontWeight.w600),
        labelMedium: w(base.labelMedium, FontWeight.w600),
        labelSmall: w(base.labelSmall, FontWeight.w600),
        // w500 because typed text in fields uses bodyLarge
        bodyLarge: w(base.bodyLarge, FontWeight.w500),
        bodyMedium: w(base.bodyMedium, FontWeight.w400),
        bodySmall: w(base.bodySmall, FontWeight.w400),
      ),
    );
  }

  static ThemeData get light =>
      _build(AppColors.light, Brightness.light, ThemeData.light().textTheme);

  static ThemeData get dark =>
      _build(AppColors.dark, Brightness.dark, ThemeData.dark().textTheme);

  static ThemeData _build(AppColors c, Brightness brightness, TextTheme base) {
    final isDark = brightness == Brightness.dark;
    final textTheme = _weighted(base);

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

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: brightness,
        primary: c.greenText,
        onPrimary: c.onGreenText,
        surface: c.background,
        error: c.red,
      ),
      textTheme: textTheme,
      extensions: [c],
      appBarTheme: AppBarTheme(systemOverlayStyle: overlay),
      // Mint with black text in both modes, like the selected navbar pill
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.onAccent,
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.text),
        actionTextColor: c.greenText,
      ),
    );
  }
}
