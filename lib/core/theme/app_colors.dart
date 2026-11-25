import 'package:flutter/material.dart';

// Static colours look the same in both modes. Instance colours change with
// the theme, so read them with context.colors
class AppColors extends ThemeExtension<AppColors> {
  // Fills that work on black and on chalk
  static const green = Color(0xFF5DF0A6);
  static const blue = Color(0xFF2B52EB);
  static const yellow = Color(0xFFF9C356);
  static const purple = Color(0xFFA78BFA);

  // Text and icons on the fills above
  static const onAccent = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  // Avatar gradient
  static const avatarLight = Color(0xFFBCC2E2);
  static const avatarDark = Color(0xFFA7AED3);

  final Color background;
  final Color surface; // navbar circles, cards
  final Color border;
  final Color text;
  final Color textSecondary;
  // Green that reads as text on background; mint is too pale on chalk
  final Color greenText;
  final Color onGreenText;
  final Color red;

  const AppColors._({
    required this.background,
    required this.surface,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.greenText,
    required this.onGreenText,
    required this.red,
  });

  static const dark = AppColors._(
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1F),
    border: Color(0xFF2A2A2E),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA1A1A8),
    greenText: green,
    onGreenText: onAccent,
    red: Color(0xFFE5534B),
  );

  // Gym chalk: cool off-white, pure black text, rubber-grey raised surfaces
  static const light = AppColors._(
    background: Color(0xFFF4F5F3),
    surface: Color(0xFFE6E8E5),
    border: Color(0xFFD5D8D4),
    text: Color(0xFF000000),
    textSecondary: Color(0xFF5C6066),
    greenText: Color(0xFF0A7A4B),
    onGreenText: Color(0xFFFFFFFF),
    red: Color(0xFFC7362F),
  );

  // Palettes are fixed, so there's nothing to copy
  @override
  AppColors copyWith() => this;

  // Blends the two palettes while the theme switch animates
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppColors._(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      border: mix(border, other.border),
      text: mix(text, other.text),
      textSecondary: mix(textSecondary, other.textSecondary),
      greenText: mix(greenText, other.greenText),
      onGreenText: mix(onGreenText, other.onGreenText),
      red: mix(red, other.red),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
