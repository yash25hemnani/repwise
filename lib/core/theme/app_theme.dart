import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    // Set weights on Material's plain styles first, then hand them to
    // google_fonts. It loads each weight as its own family, so changing
    // fontWeight on an already-DM Sans style keeps the old file.
    final base = ThemeData.light().textTheme;

    TextStyle? w(TextStyle? style, FontWeight weight) =>
        style?.copyWith(fontWeight: weight);

    final weighted = base.copyWith(
      displayLarge: w(base.displayLarge, FontWeight.w600),
      displayMedium: w(base.displayMedium, FontWeight.w600),
      displaySmall: w(base.displaySmall, FontWeight.w600),
      headlineLarge: w(base.headlineLarge, FontWeight.w700),
      headlineMedium: w(base.headlineMedium, FontWeight.w700),
      headlineSmall: w(base.headlineSmall, FontWeight.w700),
      titleLarge: w(base.titleLarge, FontWeight.w600),
      titleMedium: w(base.titleMedium, FontWeight.w600),
      titleSmall: w(base.titleSmall, FontWeight.w600),
      labelLarge: w(base.labelLarge, FontWeight.w600),
      labelMedium: w(base.labelMedium, FontWeight.w600),
      labelSmall: w(base.labelSmall, FontWeight.w600),
      // w500 because typed text in fields uses bodyLarge
      bodyLarge: w(base.bodyLarge, FontWeight.w500),
      bodyMedium: w(base.bodyMedium, FontWeight.w400),
      bodySmall: w(base.bodySmall, FontWeight.w400),
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.dmSansTextTheme(weighted),
    );
  }
}
