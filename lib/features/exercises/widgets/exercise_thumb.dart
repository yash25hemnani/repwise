import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';

// Square exercise still with a 2 ink outline in light mode, or an icon when
// there's no image or it fails
class ExerciseThumb extends StatelessWidget {
  const ExerciseThumb({
    super.key,
    required this.url,
    this.timed = false,
    this.size = 58,
  });

  final String? url;
  final bool timed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = Theme.of(context).brightness == Brightness.light;
    const radius = BorderRadius.all(Radius.circular(13));
    final fallback = Icon(
      timed ? Icons.timer_outlined : Icons.fitness_center_rounded,
      size: 24,
      color: c.textSecondary,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: radius,
        border: light ? Border.all(color: c.ink, width: 2) : null,
      ),
      // Clip inside the outline so the image doesn't cover it
      child: ClipRRect(
        borderRadius: light
            ? const BorderRadius.all(Radius.circular(11))
            : radius,
        child: Center(
          child: url == null
              ? fallback
              : Image.network(
                  url!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}
