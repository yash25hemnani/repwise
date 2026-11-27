import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/plans/widgets/week_dots.dart';
import 'package:repwise/features/plans/models/plan_model.dart';

enum PlanAction { setActive, rename, duplicate, delete }

const _radius = BorderRadius.all(Radius.circular(16));

// A row under the active plan: a card outlined in light mode. The active
// plan isn't listed, since the yellow plate above already shows it
class PlanTile extends StatelessWidget {
  const PlanTile({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onAction,
  });

  final PlanModel plan;
  final VoidCallback onTap;
  final ValueChanged<PlanAction> onAction;

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
          padding: const EdgeInsets.fromLTRB(18, 14, 4, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: c.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trainingDaysLabel(plan),
                      style: textTheme.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<PlanAction>(
                tooltip: 'Plan options',
                icon: Icon(Icons.more_vert_rounded, color: c.textSecondary),
                color: c.card,
                onSelected: onAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: PlanAction.setActive,
                    child: Text('Set as active'),
                  ),
                  const PopupMenuItem(
                    value: PlanAction.rename,
                    child: Text('Rename'),
                  ),
                  const PopupMenuItem(
                    value: PlanAction.duplicate,
                    child: Text('Duplicate'),
                  ),
                  PopupMenuItem(
                    value: PlanAction.delete,
                    child: Text('Delete', style: TextStyle(color: c.redText)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
