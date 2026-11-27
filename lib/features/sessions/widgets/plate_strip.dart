import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';

// Workout progress as a loaded barbell: one plate per exercise, outlined
// until the exercise is done, then filled. The current plate stands taller.
// Colours come from the card it sits on
class PlateStrip extends StatelessWidget {
  const PlateStrip({
    super.key,
    required this.done,
    required this.outline,
    required this.emptyFill,
    required this.doneFill,
    this.current,
    this.onTap,
  });

  final List<bool> done;
  final Color outline;
  // The card colour, so the bar doesn't show through empty plates
  final Color emptyFill;
  final Color doneFill;
  final int? current;
  final ValueChanged<int>? onTap;

  static const _plateHeight = 44.0;
  static const _currentHeight = 54.0;

  @override
  Widget build(BuildContext context) {
    if (done.isEmpty) return const SizedBox.shrink();
    final doneCount = done.where((d) => d).length;

    return Semantics(
      label: '$doneCount of ${done.length} exercises done',
      container: true,
      child: SizedBox(
        height: _currentHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The bar runs the full width behind the plates
            Container(
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.steel,
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Collar(),
                for (var i = 0; i < done.length; i++)
                  Flexible(child: _plate(i)),
                const _Collar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _plate(int i) {
    final isDone = done[i];
    final plate = Container(
      width: 16,
      height: i == current ? _currentHeight : _plateHeight,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isDone ? doneFill : emptyFill,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: outline, width: 2),
      ),
    );
    if (onTap == null) return ExcludeSemantics(child: plate);

    return Semantics(
      button: true,
      label: 'Exercise ${i + 1}${isDone ? ', done' : ''}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap!(i),
        child: plate,
      ),
    );
  }
}

// Holds the plates on; steel like the bar
class _Collar extends StatelessWidget {
  const _Collar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: AppColors.steel,
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
  }
}
