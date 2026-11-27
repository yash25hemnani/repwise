import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/utils/workout_format.dart';
import 'package:repwise/features/exercises/widgets/exercise_thumb.dart';
import 'package:repwise/features/plans/models/plan_exercise_model.dart';

const _radius = BorderRadius.all(Radius.circular(16));

// An exercise in the day editor: a card outlined in light mode with thumb,
// name, sets summary and a drag handle. The handle is the only place a drag starts, so taps and swipes
// on the card stay free
class PlanExerciseCard extends StatelessWidget {
  const PlanExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.onTap,
  });

  final PlanExerciseModel exercise;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final light = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: _radius,
        side: light ? BorderSide(color: c.ink, width: 2) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Row(
            children: [
              ExerciseThumb(
                url: exercise.thumbUrl,
                timed: exercise.logType == ExerciseLogType.timed,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: c.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // The numbers you act on, so ink rather than grey
                    Text(
                      setsSummary(exercise),
                      style: textTheme.bodyMedium?.copyWith(color: c.text),
                    ),
                  ],
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: SizedBox.square(
                  dimension: 48,
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: c.textSecondary,
                    semanticLabel: 'Drag to reorder',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
