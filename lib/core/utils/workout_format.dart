import 'package:repwise/features/plans/models/plan_exercise_model.dart';

// Weight without trailing zeros, e.g. 60.0 → "60", 62.5 → "62.5"
String formatKg(double kg) =>
    kg.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

// Minutes and seconds, e.g. 1200 → "20:00", 45 → "0:45"
String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

// Whole kilos with thousands commas, e.g. 4320.5 → "4,321"
String formatThousands(double kg) => kg
    .round()
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

// Workout length, e.g. "48 min" or "1 h 12 min"
String formatElapsed(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return h == 0 ? '$m min' : '$h h $m min';
}

String countLabel(int n, String one, [String? many]) =>
    '$n ${n == 1 ? one : many ?? '${one}s'}';

// One line for an exercise's sets, e.g. "3 × 10 · 60 kg", "1 × 20:00",
// or "4 sets · 12/10/8/6" when the sets differ
String setsSummary(PlanExerciseModel exercise) {
  final sets = exercise.sets;
  if (sets.isEmpty) return 'No sets yet';
  final n = sets.length;

  if (exercise.logType == ExerciseLogType.timed) {
    final times = {for (final s in sets) s.durationSec};
    if (times.length == 1) {
      final t = times.first;
      return t == null ? countLabel(n, 'set') : '$n × ${formatDuration(t)}';
    }
    final each = sets.map(
      (s) => s.durationSec == null ? '-' : formatDuration(s.durationSec!),
    );
    return '${countLabel(n, 'set')} · ${each.join('/')}';
  }

  final shapes = {for (final s in sets) (s.reps, s.weightKg)};
  if (shapes.length == 1) {
    final (reps, kg) = shapes.first;
    final count = reps == null ? countLabel(n, 'set') : '$n × $reps';
    return kg == null ? count : '$count · ${formatKg(kg)} kg';
  }
  final each = sets.map((s) => s.reps?.toString() ?? '-');
  return '${countLabel(n, 'set')} · ${each.join('/')}';
}
