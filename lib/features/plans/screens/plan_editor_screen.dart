import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';
import 'package:repwise/features/plans/models/plan_model.dart';
import 'package:repwise/features/plans/providers/plan_provider.dart';
import 'package:repwise/features/plans/screens/day_editor_screen.dart';
import 'package:repwise/features/plans/services/plan_actions_service.dart';
import 'package:repwise/features/plans/widgets/plan_day_tile.dart';
import 'package:repwise/features/plans/widgets/plan_tile.dart';
import 'package:repwise/features/plans/widgets/week_dots.dart';

// One plan's week. Tap the name to rename, tap a day to edit it
class PlanEditorScreen extends ConsumerWidget {
  const PlanEditorScreen({super.key, required this.planId});

  final String planId;

  void _openDay(BuildContext context, PlanWeekday weekday) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DayEditorScreen(planId: planId, weekday: weekday),
      ),
    );
  }

  void _onAction(
    BuildContext context,
    WidgetRef ref,
    PlanModel plan,
    PlanAction action,
  ) {
    final navigator = Navigator.of(context);
    PlanActionsService.run(
      context,
      ref,
      plan,
      action,
      onDeleted: navigator.pop,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plan = ref.watch(planProvider(planId));
    final active = ref.watch(activePlanIdProvider) == planId;
    final today = PlanWeekday.fromDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: plan == null
            ? null
            : _Title(
                plan: plan,
                onTap: () =>
                    _onAction(context, ref, plan, PlanAction.rename),
              ),
        actions: [
          if (plan != null)
            PopupMenuButton<PlanAction>(
              tooltip: 'Plan options',
              icon: Icon(Icons.more_vert_rounded, color: c.text),
              color: c.card,
              onSelected: (action) => _onAction(context, ref, plan, action),
              itemBuilder: (context) => [
                if (!active)
                  const PopupMenuItem(
                    value: PlanAction.setActive,
                    child: Text('Set as active'),
                  ),
                const PopupMenuItem(
                  value: PlanAction.duplicate,
                  child: Text('Duplicate'),
                ),
                if (!active)
                  PopupMenuItem(
                    value: PlanAction.delete,
                    child: Text('Delete', style: TextStyle(color: c.redText)),
                  ),
              ],
            ),
        ],
      ),
      body: plan == null
          ? const _Missing()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _WeekGrid(
                  children: [
                    for (final d in PlanWeekday.values)
                      PlanDayTile(
                        weekday: d,
                        day: plan.day(d),
                        isToday: d == today,
                        onTap: () => _openDay(context, d),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

// Day cards in rows of 2 on phones, 4 on tablets. Cards in a row share
// the tallest one's height
class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;

        return Column(
          children: [
            for (var i = 0; i < children.length; i += columns) ...[
              if (i > 0) const SizedBox(height: 7),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = i; j < i + columns; j++) ...[
                      if (j > i) const SizedBox(width: 7),
                      Expanded(
                        child: j < children.length
                            ? children[j]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.plan, required this.onTap});

  final PlanModel plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      hint: 'Rename plan',
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(color: c.text),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.edit_outlined, size: 16, color: c.textSecondary),
                ],
              ),
              Text(
                trainingDaysLabel(plan),
                style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Shown while loading, or once the plan is deleted on another device
class _Missing extends StatelessWidget {
  const _Missing();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'This plan isn\'t available. It may have been deleted.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        ),
      ),
    );
  }
}
