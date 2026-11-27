import 'package:repwise/features/exercises/models/exercise_model.dart';
import 'package:repwise/features/plans/models/plan_set_model.dart';

// How an exercise is logged: reps × kg, or time
enum ExerciseLogType {
  weighted,
  timed;

  // Library categories that are logged by time
  static ExerciseLogType forCategory(String? category) =>
      category == 'cardio' || category == 'stretching' ? timed : weighted;
}

// An exercise inside a plan day. Name, muscle group and thumb are copied
// from the library so the plan shows without reading every exercise
class PlanExerciseModel {
  final String id; // unique within the day, so one exercise can appear twice
  final String exerciseId;
  final String name;
  final String muscleGroupId;
  final String equipmentId;
  final String? thumbUrl;
  final ExerciseLogType logType;
  final List<PlanSetModel> sets;

  const PlanExerciseModel({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.muscleGroupId,
    required this.equipmentId,
    this.thumbUrl,
    this.logType = ExerciseLogType.weighted,
    this.sets = const [],
  });

  // A library exercise added to a day, with starter sets the user can edit:
  // 3 × 10, or one 5 minute set when it's timed
  factory PlanExerciseModel.fromExercise(ExerciseModel e, {required String id}) {
    final logType = ExerciseLogType.forCategory(e.category);

    return PlanExerciseModel(
      id: id,
      exerciseId: e.id,
      name: e.name,
      muscleGroupId: e.muscleGroupId,
      equipmentId: e.equipmentId,
      thumbUrl: e.thumbUrl,
      logType: logType,
      sets: logType == ExerciseLogType.timed
          ? const [PlanSetModel(durationSec: 300)]
          : const [
              PlanSetModel(reps: 10),
              PlanSetModel(reps: 10),
              PlanSetModel(reps: 10),
            ],
    );
  }

  PlanExerciseModel copyWith({List<PlanSetModel>? sets}) {
    return PlanExerciseModel(
      id: id,
      exerciseId: exerciseId,
      name: name,
      muscleGroupId: muscleGroupId,
      equipmentId: equipmentId,
      thumbUrl: thumbUrl,
      logType: logType,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'exerciseId': exerciseId,
    'name': name,
    'muscleGroupId': muscleGroupId,
    'equipmentId': equipmentId,
    'thumbUrl': thumbUrl,
    'logType': logType.name,
    'sets': [for (final s in sets) s.toMap()],
  };

  factory PlanExerciseModel.fromMap(Map<String, dynamic> map) {
    final sets = map['sets'] as List<dynamic>? ?? const [];

    return PlanExerciseModel(
      id: map['id'] as String? ?? '',
      exerciseId: map['exerciseId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      muscleGroupId: map['muscleGroupId'] as String? ?? '',
      equipmentId: map['equipmentId'] as String? ?? '',
      thumbUrl: map['thumbUrl'] as String?,
      logType:
          ExerciseLogType.values.asNameMap()[map['logType']] ??
          ExerciseLogType.weighted,
      sets: [
        for (final s in sets)
          PlanSetModel.fromMap(Map<String, dynamic>.from(s as Map)),
      ],
    );
  }
}
