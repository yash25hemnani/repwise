import 'package:repwise/features/plans/models/plan_exercise_model.dart';

// Monday first, matching the week strip. Stored by name as the days map key
enum PlanWeekday {
  mon('Monday'),
  tue('Tuesday'),
  wed('Wednesday'),
  thu('Thursday'),
  fri('Friday'),
  sat('Saturday'),
  sun('Sunday');

  const PlanWeekday(this.label);

  final String label;

  String get short => label.substring(0, 3);
  String get letter => label.substring(0, 1);

  // DateTime.weekday is 1 for Monday
  static PlanWeekday fromDate(DateTime d) => values[d.weekday - 1];
}

// One day of a plan. A day with no exercises is a rest day
class PlanDayModel {
  final String title;
  final List<PlanExerciseModel> exercises;

  const PlanDayModel({this.title = '', this.exercises = const []});

  static const rest = PlanDayModel();

  bool get isRest => exercises.isEmpty;

  int get setCount => exercises.fold(0, (sum, e) => sum + e.sets.length);

  PlanDayModel copyWith({String? title, List<PlanExerciseModel>? exercises}) {
    return PlanDayModel(
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'exercises': [for (final e in exercises) e.toMap()],
  };

  factory PlanDayModel.fromMap(Map<String, dynamic> map) {
    final exercises = map['exercises'] as List<dynamic>? ?? const [];

    return PlanDayModel(
      title: map['title'] as String? ?? '',
      exercises: [
        for (final e in exercises)
          PlanExerciseModel.fromMap(Map<String, dynamic>.from(e as Map)),
      ],
    );
  }
}
