import 'package:repwise/core/utils/image_url.dart';

// One library exercise. The library is read-only in the app; the admin
// panel writes it (see repwise-admin/docs/data-contract.md)
class ExerciseModel {
  final String id;
  final String name;
  final List<String> searchTokens;
  final String muscleGroupId;
  final String targetMuscleId;
  final List<String> secondaryMuscleIds;
  final String equipmentId;
  final String category; // strength, cardio, stretching, ...
  final String level; // beginner, intermediate, expert
  final List<String> steps; // the guide, in order
  final List<String> stillUrls; // full-size originals, in order

  const ExerciseModel({
    required this.id,
    required this.name,
    this.searchTokens = const [],
    required this.muscleGroupId,
    this.targetMuscleId = '',
    this.secondaryMuscleIds = const [],
    required this.equipmentId,
    this.category = '',
    this.level = '',
    this.steps = const [],
    this.stillUrls = const [],
  });

  String? get thumbUrl => stillUrls.isEmpty
      ? null
      : sizedImageUrl(stillUrls.first, thumbTransform);

  List<String> get detailUrls => [
    for (final u in stillUrls) sizedImageUrl(u, detailTransform),
  ];

  factory ExerciseModel.fromMap(String id, Map<String, dynamic> map) {
    final media = map['media'] as Map? ?? const {};
    final stills = media['stills'] as List? ?? const [];

    return ExerciseModel(
      id: id,
      name: map['name'] as String? ?? '',
      searchTokens: List<String>.from(map['searchTokens'] as List? ?? const []),
      muscleGroupId: map['muscleGroupId'] as String? ?? '',
      targetMuscleId: map['targetMuscleId'] as String? ?? '',
      secondaryMuscleIds: List<String>.from(
        map['secondaryMuscleIds'] as List? ?? const [],
      ),
      equipmentId: map['equipmentId'] as String? ?? '',
      category: map['category'] as String? ?? '',
      level: map['level'] as String? ?? '',
      steps: List<String>.from(map['steps'] as List? ?? const []),
      stillUrls: [
        for (final s in stills)
          if (s is Map && s['url'] is String) s['url'] as String,
      ],
    );
  }
}
