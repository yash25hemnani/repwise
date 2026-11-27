import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';
import 'package:repwise/features/plans/models/plan_model.dart';

// e.g. "4 training days"
String trainingDaysLabel(PlanModel plan) {
  final count = plan.trainingDayCount;
  if (count == 0) return 'No training days yet';
  return count == 1 ? '1 training day' : '$count training days';
}

// Names the yellow squares, e.g. "Training Mon, Wed, Fri"
String trainingDaysList(PlanModel plan) {
  final days = [
    for (final d in PlanWeekday.values)
      if (!plan.day(d).isRest) d.short,
  ];
  if (days.isEmpty) return 'No training days yet';
  if (days.length == 7) return 'Training every day';
  return 'Training ${days.join(', ')}';
}

// Seven rounded squares on the black card, Monday first. Solid yellow for
// training days, faint outlines for rest days, with a bar under today
class WeekDots extends StatelessWidget {
  const WeekDots({super.key, required this.plan});

  final PlanModel plan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final today = PlanWeekday.fromDate(DateTime.now());

    return Semantics(
      label: [
        for (final d in PlanWeekday.values)
          '${d.label} ${plan.day(d).isRest ? 'rest' : 'training'}'
              '${d == today ? ', today' : ''}',
      ].join(', '),
      excludeSemantics: true,
      child: Row(
        children: [
          for (final d in PlanWeekday.values) ...[
            if (d != PlanWeekday.mon) const SizedBox(width: 6),
            Expanded(
              child: _Dot(
                letter: d.letter,
                training: !plan.day(d).isRest,
                isToday: d == today,
                style: textTheme.labelLarge,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.letter,
    required this.training,
    required this.isToday,
    required this.style,
  });

  final String letter;
  final bool training;
  final bool isToday;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    const fill = AppColors.yellow;
    const black = AppColors.onAccent;
    // Rest days step back so the training days read at a glance
    final faint = AppColors.onBlue.withValues(alpha: 0.3);

    return Column(
      children: [
        Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: training ? fill : AppColors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: training ? fill : faint, width: 2),
          ),
          child: Text(
            letter,
            style: style?.copyWith(
              color: training ? black : AppColors.onBlue.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 4,
          width: 14,
          decoration: BoxDecoration(
            color: isToday ? fill : AppColors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
      ],
    );
  }
}
