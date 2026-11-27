import 'package:flutter/material.dart';

class NavItemModel {
  final Widget page;
  final IconData icon;
  final String label;

  // The destination's plate colour, shown as the dot in the selected pill
  final Color color;

  const NavItemModel({
    required this.page,
    required this.icon,
    required this.label,
    required this.color,
  });
}
