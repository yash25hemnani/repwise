import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/exercises/models/exercise_model.dart';
import 'package:repwise/features/exercises/widgets/exercise_thumb.dart';
import 'package:repwise/features/plans/models/plan_exercise_model.dart';

// A library row in the picker. Rows sit on the card fill and the list
// splits them with 2 px of background. Tapping the row opens the exercise;
// the circle picks it, and once picked shows its place in the order the
// exercises will be added
class ExercisePickTile extends StatelessWidget {
  const ExercisePickTile({
    super.key,
    required this.exercise,
    required this.subtitle,
    required this.pickOrder,
    required this.inDay,
    required this.onTap,
    required this.onOpen,
    this.borderRadius = BorderRadius.zero,
  });

  final ExerciseModel exercise;
  final String subtitle; // "Legs · Barbell"
  final int? pickOrder; // 1-based, null when not picked
  final bool inDay;
  final VoidCallback onTap; // picks or unpicks
  final VoidCallback onOpen; // opens the detail page

  // Rounded on the first and last rows of the list
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final picked = pickOrder != null;

    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          // The circle's 48 px target supplies the rest of the right edge
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              ExerciseThumb(
                url: exercise.thumbUrl,
                timed:
                    ExerciseLogType.forCategory(exercise.category) ==
                    ExerciseLogType.timed,
              ),
              const SizedBox(width: 14),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    if (inDay)
                      Text(
                        'Already in this day',
                        style: textTheme.labelMedium?.copyWith(color: c.text),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Semantics(
                button: true,
                checked: picked,
                label: picked
                    ? 'Unpick ${exercise.name}'
                    : 'Pick ${exercise.name}',
                child: InkResponse(
                  onTap: onTap,
                  radius: 24,
                  child: SizedBox.square(
                    dimension: 48,
                    child: Center(child: _PickCircle(order: pickOrder)),
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

// Empty ring, or filled with ink and the pick order when picked
class _PickCircle extends StatelessWidget {
  const _PickCircle({required this.order});

  final int? order;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: order == null ? AppColors.transparent : c.ink,
        border: Border.all(
          color: order == null ? c.textSecondary : c.ink,
          width: 2,
        ),
      ),
      child: order == null
          ? null
          : Text(
              '$order',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: c.background,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
