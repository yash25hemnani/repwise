import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/exercises/models/muscle_group_model.dart';

// One-line row of filters: All, then each muscle group. null means All
class MuscleGroupChips extends StatelessWidget {
  const MuscleGroupChips({
    super.key,
    required this.groups,
    required this.selectedId,
    required this.onSelected,
  });

  final List<MuscleGroupModel> groups;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'All',
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          for (final g in groups) ...[
            const SizedBox(width: 8),
            _Chip(
              label: g.name,
              selected: selectedId == g.id,
              onTap: () => onSelected(g.id),
            ),
          ],
        ],
      ),
    );
  }
}

// Pill: card fill with a 2 ink outline when off (flat surface in dark mode),
// ink fill with inverted text when on
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = Theme.of(context).brightness == Brightness.light;

    final fill = selected
        ? c.ink
        : light
        ? c.card
        : c.surface;
    final side = light || selected
        ? BorderSide(color: c.ink, width: 2)
        : BorderSide.none;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: fill,
        shape: StadiumBorder(side: side),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? c.background : c.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
