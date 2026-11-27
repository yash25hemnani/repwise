import 'dart:async';

import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/widgets/plate_card.dart';

// The exercise's stills as a flip, one frame a second, on a plate card.
// With reduced motion it holds the first frame
class ExerciseStills extends StatefulWidget {
  const ExerciseStills({super.key, required this.urls});

  final List<String> urls;

  @override
  State<ExerciseStills> createState() => _ExerciseStillsState();
}

class _ExerciseStillsState extends State<ExerciseStills> {
  Timer? _timer;
  int _frame = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  @override
  void didUpdateWidget(ExerciseStills old) {
    super.didUpdateWidget(old);
    if (old.urls.length != widget.urls.length) _restart();
  }

  void _restart() {
    // Both frames load up front so the flip never shows a blank
    for (final u in widget.urls) {
      precacheImage(NetworkImage(u), context, onError: (_, _) {});
    }
    _timer?.cancel();
    _timer = null;
    if (widget.urls.length > 1 && !MediaQuery.disableAnimationsOf(context)) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _frame++),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = Theme.of(context).brightness == Brightness.light;
    final urls = widget.urls;
    final fallback = Center(
      child: Icon(
        Icons.fitness_center_rounded,
        size: 40,
        color: c.textSecondary,
      ),
    );

    // Room on the right and bottom for the plate's shadow
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 6),
      child: Container(
        decoration: plateCard(context),
        child: ClipRRect(
          // Inside the 3 outline in light mode
          borderRadius: BorderRadius.circular(light ? 19 : 22),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: urls.isEmpty
                ? fallback
                : Image.network(
                    urls[_frame % urls.length],
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => fallback,
                  ),
          ),
        ),
      ),
    );
  }
}
