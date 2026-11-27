import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/exercises/providers/exercise_provider.dart';
import 'package:repwise/features/exercises/widgets/exercise_stills.dart';

// An exercise from the library: its stills, what it works and how to do it.
// [planSection] adds the plan's own part, like the day's sets
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    required this.name,
    this.planSection,
    this.bottomBar,
  });

  final String exerciseId;
  final String name; // shown straight away, before the exercise loads
  final Widget? planSection;
  final Widget? bottomBar; // the picker's Pick button

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final exercise = ref.watch(exerciseProvider(exerciseId));
    final muscles = ref.watch(targetMuscleNamesProvider).value ?? const {};
    final equipment = ref.watch(equipmentNamesProvider).value ?? const {};
    final e = exercise.value;
    final also = [
      for (final id in e?.secondaryMuscleIds ?? const <String>[])
        ?muscles[id],
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: AppColors.transparent,
      ),
      bottomNavigationBar: bottomBar,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          ExerciseStills(urls: e?.detailUrls ?? const []),
          const SizedBox(height: 20),
          Text(
            e?.name ?? name,
            style: textTheme.headlineLarge?.copyWith(color: c.text),
          ),
          if (e != null) ...[
            const SizedBox(height: 14),
            _Facts(
              items: [
                ('Targets', muscles[e.targetMuscleId] ?? ''),
                ('Equipment', equipment[e.equipmentId] ?? ''),
                ('Level', _capitalised(e.level)),
              ],
            ),
            if (also.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Also works ${also.join(', ')}',
                style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ],
          ],
          if (planSection != null) ...[
            const SizedBox(height: 24),
            planSection!,
          ],
          if (e != null && e.steps.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'How to do it',
              style: textTheme.titleMedium?.copyWith(color: c.text),
            ),
            const SizedBox(height: 14),
            for (final (i, step) in e.steps.indexed)
              _Step(number: i + 1, text: step),
          ],
          if (exercise.hasError || (exercise.hasValue && e == null)) ...[
            const SizedBox(height: 16),
            Text(
              exercise.hasError
                  ? 'Couldn\'t load this exercise. Check your connection, then open it again.'
                  : 'This exercise is no longer in the library.',
              style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

String _capitalised(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

class _Facts extends StatelessWidget {
  const _Facts({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in items)
          if (value.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.labelLarge?.copyWith(color: c.text),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

// Numbered because the guide is done in order
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Text(
              '$number',
              style: textTheme.labelLarge?.copyWith(color: AppColors.onAccent),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyLarge?.copyWith(color: c.text, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
