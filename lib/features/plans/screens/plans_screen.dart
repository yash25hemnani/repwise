import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/widgets/plate_button.dart';
import 'package:repwise/core/widgets/plate_card.dart';
import 'package:repwise/features/plans/models/plan_model.dart';
import 'package:repwise/features/plans/providers/plan_provider.dart';
import 'package:repwise/features/plans/screens/plan_editor_screen.dart';
import 'package:repwise/features/plans/services/plan_actions_service.dart';
import 'package:repwise/features/plans/sheets/plan_name_sheet.dart';
import 'package:repwise/features/plans/widgets/active_plan_card.dart';
import 'package:repwise/features/plans/widgets/plan_tile.dart';

// The Plan tab: the active plan on its yellow plate, then the other plans
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await PlanNameSheet.show(
      context,
      title: 'New plan',
      action: 'Create plan',
    );
    if (name == null || !context.mounted) return;

    // The first plan, or one made after the active plan went missing,
    // becomes active
    final makeActive = ref.read(activePlanProvider) == null;
    final repo = ref.read(planRepositoryProvider);

    PlanActionsService.write(
      context,
      ref,
      (uid) => repo.createPlan(uid: uid, name: name, makeActive: makeActive),
      done: makeActive ? '$name created and set as active' : '$name created',
    );
  }

  void _edit(BuildContext context, PlanModel plan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlanEditorScreen(planId: plan.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansProvider);
    final active = ref.watch(activePlanProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _Header(onCreate: () => _create(context, ref)),
            ),
            Expanded(
              child: plans.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const _Message(
                  title: 'Couldn\'t load your plans',
                  body: 'Check your connection, then open this tab again.',
                ),
                data: (plans) {
                  if (plans.isEmpty) {
                    return _EmptyState(onCreate: () => _create(context, ref));
                  }

                  // The hero already shows the active plan, and its editor
                  // has the rename and duplicate actions
                  final others = active == null
                      ? plans
                      : [
                          for (final p in plans)
                            if (p.id != active.id) p,
                        ];

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    children: [
                      if (active != null)
                        ActivePlanCard(
                          plan: active,
                          onEdit: () => _edit(context, active),
                        )
                      else
                        const NoActivePlanCard(),
                      if (others.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(
                          title: active == null ? 'All plans' : 'Other plans',
                        ),
                        const SizedBox(height: 12),
                      ],
                      for (final plan in others) ...[
                        PlanTile(
                          plan: plan,
                          onTap: () => _edit(context, plan),
                          onAction: (action) => PlanActionsService.run(
                            context,
                            ref,
                            plan,
                            action,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final light = Theme.of(context).brightness == Brightness.light;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Plans',
            style: textTheme.titleLarge?.copyWith(color: c.text),
          ),
        ),
        Tooltip(
          message: 'New plan',
          child: Material(
            color: light ? c.card : c.surface,
            shape: CircleBorder(
              side: light
                  ? BorderSide(color: c.ink, width: 2)
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onCreate,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: 44,
                child: Icon(
                  Icons.add_rounded,
                  size: 24,
                  color: c.text,
                  semanticLabel: 'New plan',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: context.colors.text),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: Container(
                width: 72,
                height: 72,
                decoration: plateCard(
                  context,
                  fill: AppColors.yellow,
                  radius: 20,
                  shadow: 5,
                ),
                child: const Icon(
                  Icons.calendar_view_week_rounded,
                  size: 32,
                  color: AppColors.onAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No plans yet',
              style: textTheme.titleLarge?.copyWith(color: c.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Make a weekly plan, then give each day its exercises and sets.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: 24),
            PlateButton(
              label: 'Create plan',
              icon: Icons.add_rounded,
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: textTheme.titleMedium?.copyWith(color: c.text)),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
