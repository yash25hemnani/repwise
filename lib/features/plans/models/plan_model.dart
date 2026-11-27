import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';

// A weekly plan at users/{uid}/plans/{id}. All seven days are always stored
class PlanModel {
  final String id;
  final String name;
  // Who wrote it; a trainer later on, the owner for now
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<PlanWeekday, PlanDayModel> days;

  const PlanModel({
    required this.id,
    required this.name,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    required this.days,
  });

  PlanDayModel day(PlanWeekday d) => days[d] ?? PlanDayModel.rest;

  int get trainingDayCount =>
      PlanWeekday.values.where((d) => !day(d).isRest).length;

  // id is the doc id, so it isn't stored as a field
  Map<String, dynamic> toMap() => {
    'name': name,
    'authorId': authorId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'days': {for (final d in PlanWeekday.values) d.name: day(d).toMap()},
  };

  factory PlanModel.fromMap(String id, Map<String, dynamic> map) {
    final days = map['days'] as Map<String, dynamic>? ?? const {};

    return PlanModel(
      id: id,
      name: map['name'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      // Null until the server timestamp lands
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      days: {
        for (final d in PlanWeekday.values)
          d: days[d.name] is Map
              ? PlanDayModel.fromMap(Map<String, dynamic>.from(days[d.name]))
              : PlanDayModel.rest,
      },
    );
  }
}
