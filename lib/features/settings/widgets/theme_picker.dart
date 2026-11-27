import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/settings/providers/theme_provider.dart';

// System / Light / Dark as pills, styled like the bottom navbar
class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  static const _options = [
    (ThemeMode.system, 'System', Icons.brightness_auto_rounded),
    (ThemeMode.light, 'Light', Icons.light_mode_rounded),
    (ThemeMode.dark, 'Dark', Icons.dark_mode_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);

    return Row(
      children: [
        for (final (mode, label, icon) in _options) ...[
          if (mode != ThemeMode.system) const SizedBox(width: 8),
          Expanded(
            child: _ThemePill(
              label: label,
              icon: icon,
              selected: mode == current,
              onTap: () => ref.read(themeProvider.notifier).set(mode),
            ),
          ),
        ],
      ],
    );
  }
}

class _ThemePill extends StatelessWidget {
  const _ThemePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? AppColors.onPrimary : colors.textSecondary;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primary : colors.surface,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
