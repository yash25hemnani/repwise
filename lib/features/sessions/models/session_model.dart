import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';
import 'package:repwise/features/sessions/models/session_exercise_model.dart';

enum SessionStatus { active, finished }

// One workout at users/{uid}/sessions/{id}. weekday is the plan day that
// was trained, which can differ from the day it was done on
class SessionModel {
  final String id;
  final String planId;
  final String planName;
  final PlanWeekday weekday;
  final String title;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<SessionExerciseModel> exercises;

  const SessionModel({
    required this.id,
    required this.planId,
    required this.planName,
    required this.weekday,
    required this.title,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.exercises = const [],
  });

  bool get isActive => status == SessionStatus.active;

  int get setCount => exercises.fold(0, (total, e) => total + e.sets.length);

  int get doneSetCount =>
      exercises.fold(0, (total, e) => total + e.doneSetCount);

  int get doneExerciseCount => exercises.where((e) => e.isDone).length;

  double get volumeKg =>
      exercises.fold(0.0, (total, e) => total + e.volumeKg);

  // Muscle groups with at least one set ticked
  Set<String> get musclesWorked => {
    for (final e in exercises)
      if (e.doneSetCount > 0) e.muscleGroupId,
  };

  // Runs on until the session is finished
  Duration get duration =>
      (finishedAt ?? DateTime.now()).difference(startedAt);

  SessionModel copyWith({List<SessionExerciseModel>? exercises}) {
    return SessionModel(
      id: id,
      planId: planId,
      planName: planName,
      weekday: weekday,
      title: title,
      status: status,
      startedAt: startedAt,
      finishedAt: finishedAt,
      exercises: exercises ?? this.exercises,
    );
  }

  // id is the doc id, so it isn't stored as a field
  Map<String, dynamic> toMap() => {
    'planId': planId,
    'planName': planName,
    'weekday': weekday.name,
    'title': title,
    'status': status.name,
    'startedAt': Timestamp.fromDate(startedAt),
    'finishedAt': finishedAt == null ? null : Timestamp.fromDate(finishedAt!),
    'exercises': [for (final e in exercises) e.toMap()],
  };

  factory SessionModel.fromMap(String id, Map<String, dynamic> map) {
    final exercises = map['exercises'] as List<dynamic>? ?? const [];

    return SessionModel(
      id: id,
      planId: map['planId'] as String? ?? '',
      planName: map['planName'] as String? ?? '',
      weekday:
          PlanWeekday.values.asNameMap()[map['weekday']] ?? PlanWeekday.mon,
      title: map['title'] as String? ?? '',
      status:
          SessionStatus.values.asNameMap()[map['status']] ??
          SessionStatus.finished,
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      finishedAt: (map['finishedAt'] as Timestamp?)?.toDate(),
      exercises: [
        for (final e in exercises)
          SessionExerciseModel.fromMap(Map<String, dynamic>.from(e as Map)),
      ],
    );
  }
}
