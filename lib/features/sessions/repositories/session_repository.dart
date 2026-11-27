import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';
import 'package:repwise/features/plans/models/plan_model.dart';
import 'package:repwise/features/sessions/models/session_exercise_model.dart';
import 'package:repwise/features/sessions/models/session_model.dart';

class SessionRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _db.collection('users').doc(uid).collection('sessions');

  // The unfinished session, if any; only one runs at a time
  Stream<SessionModel?> watchActive(String uid) {
    return _sessions(uid)
        .where('status', isEqualTo: SessionStatus.active.name)
        .limit(1)
        .snapshots()
        .map(
          (snap) => snap.docs.isEmpty
              ? null
              : SessionModel.fromMap(snap.docs.first.id, snap.docs.first.data()),
        );
  }

  // Sessions started on or after since, oldest first. One field, so no
  // composite index is needed
  Stream<List<SessionModel>> watchSince(String uid, DateTime since) {
    return _sessions(uid)
        .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('startedAt')
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs) SessionModel.fromMap(doc.id, doc.data()),
          ],
        );
  }

  // Copies the plan day into a new session. Client time is used for
  // startedAt so the running clock is right before the write syncs
  Future<String> start({
    required String uid,
    required PlanModel plan,
    required PlanWeekday weekday,
  }) async {
    final ref = _sessions(uid).doc();
    final day = plan.day(weekday);
    final session = SessionModel(
      id: ref.id,
      planId: plan.id,
      planName: plan.name,
      weekday: weekday,
      title: day.title.isEmpty ? weekday.label : day.title,
      status: SessionStatus.active,
      startedAt: DateTime.now(),
      exercises: [
        for (final e in day.exercises) SessionExerciseModel.fromPlan(e),
      ],
    );

    await ref.set(session.toMap());
    return ref.id;
  }

  // Arrays can't be updated by index, so every edit rewrites the list
  Future<void> updateExercises(
    String uid,
    String sessionId,
    List<SessionExerciseModel> exercises,
  ) {
    return _sessions(uid).doc(sessionId).update({
      'exercises': [for (final e in exercises) e.toMap()],
    });
  }

  // Keeps only ticked sets, and drops exercises with none ticked
  Future<void> finish(String uid, SessionModel session) {
    final logged = [
      for (final e in session.exercises)
        if (e.doneSetCount > 0)
          e.copyWith(sets: e.sets.where((s) => s.done).toList()),
    ];

    return _sessions(uid).doc(session.id).update({
      'status': SessionStatus.finished.name,
      'finishedAt': Timestamp.fromDate(DateTime.now()),
      'exercises': [for (final e in logged) e.toMap()],
    });
  }

  Future<void> discard(String uid, String sessionId) {
    return _sessions(uid).doc(sessionId).delete();
  }
}
