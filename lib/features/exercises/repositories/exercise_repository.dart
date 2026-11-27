import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repwise/features/exercises/models/exercise_model.dart';
import 'package:repwise/features/exercises/models/muscle_group_model.dart';

class ExerciseRepository {
  final _db = FirebaseFirestore.instance;

  // Unarchived exercises by name. [token] is one search word; null lists
  // everything. Each filter mix has a composite index in
  // firestore.indexes.json
  Stream<List<ExerciseModel>> watchExercises({
    String? token,
    String? muscleGroupId,
    required int limit,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('exercises')
        .where('archived', isEqualTo: false);
    if (muscleGroupId != null) {
      query = query.where('muscleGroupId', isEqualTo: muscleGroupId);
    }
    if (token != null) {
      query = query.where('searchTokens', arrayContains: token);
    }

    return query
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs)
              ExerciseModel.fromMap(doc.id, doc.data()),
          ],
        );
  }

  // One exercise, or null once it's gone
  Stream<ExerciseModel?> watchExercise(String id) {
    return _db
        .collection('exercises')
        .doc(id)
        .snapshots()
        .map(
          (doc) =>
              doc.exists ? ExerciseModel.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Stream<List<MuscleGroupModel>> watchMuscleGroups() {
    return _db
        .collection('muscleGroups')
        .orderBy('order')
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs)
              MuscleGroupModel.fromMap(doc.id, doc.data()),
          ],
        );
  }

  // Equipment id to display name, e.g. body-only -> Bodyweight
  Stream<Map<String, String>> watchEquipmentNames() {
    return _db
        .collection('equipment')
        .snapshots()
        .map(
          (snap) => {
            for (final doc in snap.docs)
              doc.id: doc.data()['name'] as String? ?? doc.id,
          },
        );
  }

  // Target muscle id to display name, e.g. middle-back -> Middle back
  Stream<Map<String, String>> watchTargetMuscleNames() {
    return _db
        .collection('targetMuscles')
        .snapshots()
        .map(
          (snap) => {
            for (final doc in snap.docs)
              doc.id: doc.data()['name'] as String? ?? doc.id,
          },
        );
  }
}
