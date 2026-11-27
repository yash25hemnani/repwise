import 'package:flutter/material.dart';

// Static colours look the same in both modes. Instance colours change with
// the theme, so read them with context.colors
class AppColors extends ThemeExtension<AppColors> {
  // Plate colours, fills only. Each feature keeps its plate everywhere
  static const red = Color(0xFFE5534B); // widget, personal bests, destructive
  static const blue = Color(0xFF2B52EB); // primary buttons, logging
  static const yellow = Color(0xFFF9C356); // weekly plan
  static const green = Color(0xFF5DF0A6); // library, done
  static const white = Color(0xFFFFFFFF); // progress and stats

  // Text and icons on red, yellow, green and white
  static const onAccent = Color(0xFF000000);
  static const onBlue = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);

  // The primary plate. Change both together to recolour every primary action
  static const primary = blue;
  static const onPrimary = onBlue;

  // Bar and collar art only
  static const steel = Color(0xFFB4B8B2);

  final Color background;
  final Color card; // cards, sheets, dialogs
  final Color surface; // nav circles, input fills, rows inside cards
  final Color border;
  final Color ink; // outlines and hard shadows
  final Color text;
  final Color textSecondary;
  // Primary that reads as text on background; plate blue is too dark on black
  final Color primaryText;
  final Color onPrimaryText;
  final Color redText;

  const AppColors._({
    required this.background,
    required this.card,
    required this.surface,
    required this.border,
    required this.ink,
    required this.text,
    required this.textSecondary,
    required this.primaryText,
    required this.onPrimaryText,
    required this.redText,
  });

  static const dark = AppColors._(
    background: Color(0xFF000000),
    card: Color(0xFF1C1C1F),
    surface: Color(0xFF1C1C1F),
    border: Color(0xFF2A2A2E),
    ink: Color(0xFFFFFFFF),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA1A1A8),
    primaryText: Color(0xFF7C97FF),
    onPrimaryText: onAccent,
    redText: red,
  );

  // Gym chalk: cool off-white, pure black text, rubber-grey raised surfaces
  static const light = AppColors._(
    background: Color(0xFFF4F5F3),
    card: Color(0xFFFFFFFF),
    surface: Color(0xFFE6E8E5),
    border: Color(0xFFD5D8D4),
    ink: Color(0xFF000000),
    text: Color(0xFF000000),
    textSecondary: Color(0xFF5C6066),
    primaryText: blue,
    onPrimaryText: onBlue,
    redText: Color(0xFFC7362F),
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
      card: mix(card, other.card),
      surface: mix(surface, other.surface),
      border: mix(border, other.border),
      ink: mix(ink, other.ink),
      text: mix(text, other.text),
      textSecondary: mix(textSecondary, other.textSecondary),
      primaryText: mix(primaryText, other.primaryText),
      onPrimaryText: mix(onPrimaryText, other.onPrimaryText),
      redText: mix(redText, other.redText),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
