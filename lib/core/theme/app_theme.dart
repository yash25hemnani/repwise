import 'package:flutter/material.dart';
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

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    textTheme: _weighted(ThemeData.light().textTheme),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.dark,
      primary: AppColors.green,
      onPrimary: AppColors.onAccent,
      surface: AppColors.background,
    ),
    textTheme: _weighted(ThemeData.dark().textTheme),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surface,
    ),
  );
}