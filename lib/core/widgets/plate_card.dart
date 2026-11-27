import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';

// A card that sits on chalk like a solid object: ink outline and a hard
// shadow in light mode, a flat panel in dark mode. Leave room for the
// shadow on the right and bottom so it isn't clipped
BoxDecoration plateCard(
  BuildContext context, {
  Color? fill,
  double radius = 22,
  double shadow = 6,
}) {
  final c = context.colors;
  final dark = Theme.of(context).brightness == Brightness.dark;

  return BoxDecoration(
    color: fill ?? c.card,
    borderRadius: BorderRadius.circular(radius),
    border: dark ? null : Border.all(color: c.ink, width: 3),
    boxShadow: dark ? null : [BoxShadow(color: c.ink, offset: Offset(shadow, shadow))],
  );
}
