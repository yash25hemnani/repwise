import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/utils/workout_format.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';
import 'package:repwise/features/plans/models/plan_exercise_model.dart';
import 'package:repwise/features/plans/providers/plan_provider.dart';
import 'package:repwise/features/plans/services/plan_actions_service.dart';
import 'package:repwise/features/plans/sheets/sets_sheet.dart';

// One exercise's sets for the day, on its detail page. Tapping opens the
// sets sheet, and the day saves straight away
class PlanSetsCard extends ConsumerWidget {
  const PlanSetsCard({
    super.key,
    required this.planId,
    required this.weekday,
    required this.planExerciseId,
  });

  final String planId;
  final PlanWeekday weekday;
  final String planExerciseId;

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    PlanExerciseModel exercise,
  ) async {
    final sets = await SetsSheet.show(context, exercise);
    if (sets == null || !context.mounted) return;

    // Read the day again, it may have changed while the sheet was open
    final day = ref.read(planProvider(planId))?.day(weekday);
    if (day == null) return;
    final repo = ref.read(planRepositoryProvider);

    PlanActionsService.write(
      context,
      ref,
      (uid) => repo.updateDay(
        uid,
        planId,
        weekday,
        day.copyWith(
          exercises: [
            for (final e in day.exercises)
              e.id == exercise.id ? e.copyWith(sets: sets) : e,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final light = Theme.of(context).brightness == Brightness.light;
    final exercise = ref
        .watch(planProvider(planId))
        ?.day(weekday)
        .exercises
        .where((e) => e.id == planExerciseId)
        .firstOrNull;

    // Removed from the day elsewhere
    if (exercise == null) return const SizedBox.shrink();

    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: light ? BorderSide(color: c.ink, width: 2) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _edit(context, ref, exercise),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your sets on ${weekday.label}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      setsSummary(exercise),
                      style: textTheme.titleMedium?.copyWith(color: c.text),
                    ),
                  ],
                ),
              ),
              SizedBox.square(
                dimension: 44,
                child: Icon(
                  Icons.edit_outlined,
                  color: c.textSecondary,
                  semanticLabel: 'Edit sets',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
