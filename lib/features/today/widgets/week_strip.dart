import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/features/today/providers/selected_day_provider.dart';
import 'package:repwise/features/today/widgets/day_chip.dart';

// Monday to Sunday of this week; tapping a day selects it
class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDayProvider);
    final today = dateOnly(DateTime.now());
    final week = currentWeek();

    return Row(
      children: [
        for (var i = 0; i < week.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: DayChip(
              day: week[i],
              selected: week[i] == selected,
              isToday: week[i] == today,
              onTap: () => ref.read(selectedDayProvider.notifier).select(week[i]),
            ),
          ),
        ],
      ],
    );
  }
}
