import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';
import 'package:repwise/features/plans/models/plan_model.dart';

class PlanRepository {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _plans(String uid) =>
      _user(uid).collection('plans');

  // Oldest first, so the list doesn't reshuffle when a plan is renamed
  Stream<List<PlanModel>> watchPlans(String uid) {
    return _plans(uid).orderBy('createdAt').snapshots().map(
      (snap) => [for (final doc in snap.docs) PlanModel.fromMap(doc.id, doc.data())],
    );
  }

  // New plans start with seven rest days. makeActive is set for the
  // first plan, so Today has something to follow straight away
  Future<String> createPlan({
    required String uid,
    required String name,
    bool makeActive = false,
  }) async {
    final ref = _plans(uid).doc();
    final now = DateTime.now();
    final plan = PlanModel(
      id: ref.id,
      name: name,
      authorId: uid,
      createdAt: now,
      updatedAt: now,
      days: {for (final d in PlanWeekday.values) d: PlanDayModel.rest},
    );

    final batch = _db.batch();
    batch.set(ref, {
      ...plan.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (makeActive) batch.update(_user(uid), {'activePlanId': ref.id});
    await batch.commit();

    return ref.id;
  }

  Future<void> renamePlan(String uid, String planId, String name) {
    return _plans(uid).doc(planId).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Replaces one day, leaving the other six untouched
  Future<void> updateDay(
    String uid,
    String planId,
    PlanWeekday weekday,
    PlanDayModel day,
  ) {
    return _plans(uid).doc(planId).update({
      'days.${weekday.name}': day.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Copies every day into a new plan; the copy isn't made active
  Future<String> duplicatePlan(String uid, PlanModel plan) async {
    final ref = _plans(uid).doc();

    await ref.set({
      ...plan.toMap(),
      'name': '${plan.name} copy',
      'authorId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  // The screen stops the active plan from being deleted
  Future<void> deletePlan(String uid, String planId) {
    return _plans(uid).doc(planId).delete();
  }

  Future<void> setActivePlan(String uid, String planId) {
    return _user(uid).update({'activePlanId': planId});
  }
}
