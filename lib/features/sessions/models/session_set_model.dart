import 'package:repwise/features/plans/models/plan_set_model.dart';

// One logged set. Starts as the plan's target and is edited in place,
// then ticked off with done
class SessionSetModel {
  final int? reps;
  final double? weightKg;
  final int? durationSec;
  final bool done;

  const SessionSetModel({
    this.reps,
    this.weightKg,
    this.durationSec,
    this.done = false,
  });

  factory SessionSetModel.fromPlan(PlanSetModel s) => SessionSetModel(
    reps: s.reps,
    weightKg: s.weightKg,
    durationSec: s.durationSec,
  );

  // reps × kg; bodyweight and timed sets add nothing
  double get volumeKg => (reps ?? 0) * (weightKg ?? 0);

  SessionSetModel copyWith({
    int? reps,
    double? weightKg,
    int? durationSec,
    bool? done,
  }) {
    return SessionSetModel(
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      durationSec: durationSec ?? this.durationSec,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() => {
    if (reps != null) 'reps': reps,
    if (weightKg != null) 'weightKg': weightKg,
    if (durationSec != null) 'durationSec': durationSec,
    'done': done,
  };

  factory SessionSetModel.fromMap(Map<String, dynamic> map) {
    return SessionSetModel(
      reps: (map['reps'] as num?)?.toInt(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      durationSec: (map['durationSec'] as num?)?.toInt(),
      done: map['done'] as bool? ?? false,
    );
  }
}
