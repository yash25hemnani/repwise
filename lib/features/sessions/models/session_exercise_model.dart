import 'package:repwise/features/plans/models/plan_exercise_model.dart';
import 'package:repwise/features/sessions/models/session_set_model.dart';

// An exercise inside a session, copied from the plan day when it starts
// so later plan edits don't change it
class SessionExerciseModel {
  final String id;
  final String exerciseId;
  final String name;
  final String muscleGroupId;
  final String equipmentId;
  final String? thumbUrl;
  final ExerciseLogType logType;
  final List<SessionSetModel> sets;

  const SessionExerciseModel({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.muscleGroupId,
    required this.equipmentId,
    this.thumbUrl,
    this.logType = ExerciseLogType.weighted,
    this.sets = const [],
  });

  factory SessionExerciseModel.fromPlan(PlanExerciseModel e) {
    return SessionExerciseModel(
      id: e.id,
      exerciseId: e.exerciseId,
      name: e.name,
      muscleGroupId: e.muscleGroupId,
      equipmentId: e.equipmentId,
      thumbUrl: e.thumbUrl,
      logType: e.logType,
      sets: [for (final s in e.sets) SessionSetModel.fromPlan(s)],
    );
  }

  int get doneSetCount => sets.where((s) => s.done).length;

  // Every set ticked; drives the filled plate on the strip
  bool get isDone => sets.isNotEmpty && doneSetCount == sets.length;

  double get volumeKg => sets
      .where((s) => s.done)
      .fold(0.0, (total, s) => total + s.volumeKg);

  SessionExerciseModel copyWith({List<SessionSetModel>? sets}) {
    return SessionExerciseModel(
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

  factory SessionExerciseModel.fromMap(Map<String, dynamic> map) {
    final sets = map['sets'] as List<dynamic>? ?? const [];

    return SessionExerciseModel(
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
          SessionSetModel.fromMap(Map<String, dynamic>.from(s as Map)),
      ],
    );
  }
}
