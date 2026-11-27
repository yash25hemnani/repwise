import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/utils/search_words.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/exercises/models/exercise_model.dart';
import 'package:repwise/features/exercises/models/muscle_group_model.dart';
import 'package:repwise/features/exercises/repositories/exercise_repository.dart';

final exerciseRepositoryProvider = Provider((ref) => ExerciseRepository());

// Retrying can't fix a rules denial or a missing index
Duration? _retry(int retryCount, Object error) =>
    error is FirebaseException &&
        (error.code == 'permission-denied' ||
            error.code == 'failed-precondition')
    ? null
    : ProviderContainer.defaultRetry(retryCount, error);

// What the picker asks for. limit grows as the list scrolls (load more)
typedef ExerciseQuery = ({String search, String? muscleGroupId, int limit});

// hasMore is true when the query filled its limit, so another page may exist
typedef ExercisePage = ({List<ExerciseModel> items, bool hasMore});

// Exercises matching every word of the search, within a muscle group.
// Firestore filters on the longest word; the rest are checked here
final exerciseSearchProvider = StreamProvider.autoDispose
    .family<ExercisePage, ExerciseQuery>((ref, query) {
      final uid = ref.watch(currentUidProvider).value;
      if (uid == null) return const Stream.empty();

      final words = searchWords(query.search)
        ..sort((a, b) => b.length.compareTo(a.length));

      return ref
          .watch(exerciseRepositoryProvider)
          .watchExercises(
            token: words.firstOrNull,
            muscleGroupId: query.muscleGroupId,
            limit: query.limit,
          )
          .map(
            (list) => (
              items: [
                for (final e in list)
                  if (words.every(e.searchTokens.contains)) e,
              ],
              hasMore: list.length == query.limit,
            ),
          );
    }, retry: _retry);

final muscleGroupsProvider = StreamProvider<List<MuscleGroupModel>>((ref) {
  final uid = ref.watch(currentUidProvider).value;
  if (uid == null) return const Stream.empty();

  return ref.watch(exerciseRepositoryProvider).watchMuscleGroups();
}, retry: _retry);

final equipmentNamesProvider = StreamProvider<Map<String, String>>((ref) {
  final uid = ref.watch(currentUidProvider).value;
  if (uid == null) return const Stream.empty();

  return ref.watch(exerciseRepositoryProvider).watchEquipmentNames();
}, retry: _retry);

final targetMuscleNamesProvider = StreamProvider<Map<String, String>>((ref) {
  final uid = ref.watch(currentUidProvider).value;
  if (uid == null) return const Stream.empty();

  return ref.watch(exerciseRepositoryProvider).watchTargetMuscleNames();
}, retry: _retry);

// One exercise for its detail page; null once it's gone from the library
final exerciseProvider = StreamProvider.autoDispose
    .family<ExerciseModel?, String>((ref, id) {
      final uid = ref.watch(currentUidProvider).value;
      if (uid == null) return const Stream.empty();

      return ref.watch(exerciseRepositoryProvider).watchExercise(id);
    }, retry: _retry);
