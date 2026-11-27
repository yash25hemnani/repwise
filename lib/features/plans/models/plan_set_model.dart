// One target set. Weighted exercises use reps and weightKg, timed ones
// (cardio, stretching) use durationSec
class PlanSetModel {
  final int? reps;
  final double? weightKg;
  final int? durationSec;

  const PlanSetModel({this.reps, this.weightKg, this.durationSec});

  // Only the fields this set uses are stored
  Map<String, dynamic> toMap() => {
    if (reps != null) 'reps': reps,
    if (weightKg != null) 'weightKg': weightKg,
    if (durationSec != null) 'durationSec': durationSec,
  };

  factory PlanSetModel.fromMap(Map<String, dynamic> map) {
    return PlanSetModel(
      reps: (map['reps'] as num?)?.toInt(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      durationSec: (map['durationSec'] as num?)?.toInt(),
    );
  }
}
