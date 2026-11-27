import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/widgets/plate_card.dart';
import 'package:repwise/features/plans/models/plan_model.dart';
import 'package:repwise/features/plans/widgets/week_dots.dart';

// The Plan tab's black card: the plan Today follows and its week. Tap to edit
class ActivePlanCard extends StatelessWidget {
  const ActivePlanCard({super.key, required this.plan, required this.onEdit});

  final PlanModel plan;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const onPlate = AppColors.onBlue; // white text on the black card

    // The black card says it's the active plan, so screen readers get the
    // words instead of a visible label
    return Semantics(
      container: true,
      button: true,
      label: 'Active plan',
      hint: 'Edit plan',
      child: Padding(
        // Room for the hard shadow
        padding: const EdgeInsets.only(right: 6, bottom: 6),
        // The whole card opens the editor
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onEdit,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: plateCard(context, fill: AppColors.onAccent).copyWith(
              // Black on a black background needs an edge in dark mode
              border: dark
                  ? Border.all(color: context.colors.border, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineLarge?.copyWith(color: onPlate),
                ),
                const SizedBox(height: 6),
                Text(
                  trainingDaysList(plan),
                  style: textTheme.bodyMedium?.copyWith(color: onPlate),
                ),
                const SizedBox(height: 18),
                WeekDots(plan: plan),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Shown when there are plans but none is active
class NoActivePlanCard extends StatelessWidget {
  const NoActivePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final light = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: light ? Border.all(color: c.ink, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No active plan',
            style: textTheme.titleMedium?.copyWith(color: c.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Open a plan\'s menu below and choose Set as active. Today will follow it.',
            style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
