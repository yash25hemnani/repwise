import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';

// Stand-in page for tabs built in later phases
class ComingSoon extends StatelessWidget {
  final String title;

  const ComingSoon({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$title is coming soon',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}