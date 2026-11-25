import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';

// Splits the email form from Continue with Google
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(child: Divider(color: colors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        ),
        Expanded(child: Divider(color: colors.border)),
      ],
    );
  }
}
