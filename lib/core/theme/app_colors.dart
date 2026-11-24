import 'package:flutter/material.dart';

// Dark palette from the design reference. Light tokens come with THEM-01.
class AppColors {
  AppColors._();

  // Surfaces
  static const background = Color(0xFF000000);
  static const transparent = Color(0x00000000);
  static const surface = Color(0xFF1C1C1F); // navbar circles, dark cards
  static const border = Color(0xFF2A2A2E);

  // Text
  static const text = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1A8);

  // Bright accents
  static const blue = Color(0xFF2B52EB);
  static const green = Color(0xFF5DF0A6);
  static const yellow = Color(0xFFF9C356);
  static const purple = Color(0xFFA78BFA);
  static const red = Color(0xFFE5534B);

  // Text and icons on the bright accents
  static const onAccent = Color(0xFF000000);
  static const ink = Color(0xFF050505);

  // Avatar gradient
  static const avatarLight = Color(0xFFBCC2E2);
  static const avatarDark = Color(0xFFA7AED3);
}