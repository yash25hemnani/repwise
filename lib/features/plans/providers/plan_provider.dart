import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/plans/models/plan_model.dart';
import 'package:repwise/features/plans/repositories/plan_repository.dart';
import 'package:repwise/features/profile/providers/user_provider.dart';

final planRepositoryProvider = Provider((ref) => PlanRepository());

// The signed-in user's plans, oldest first
final plansProvider = StreamProvider<List<PlanModel>>(
  (ref) {
    final uid = ref.watch(currentUidProvider).value;

    // Stays loading while signed out
    if (uid == null) return const Stream.empty();

    return ref.watch(planRepositoryProvider).watchPlans(uid);
  },
  // Retrying can't fix a rules denial
  retry: (retryCount, error) =>
      error is FirebaseException && error.code == 'permission-denied'
      ? null
      : ProviderContainer.defaultRetry(retryCount, error),
);

// One plan by id; null while loading or once it's deleted
final planProvider = Provider.family<PlanModel?, String>((ref, id) {
  final plans = ref.watch(plansProvider).value ?? const [];

  for (final plan in plans) {
    if (plan.id == id) return plan;
  }
  return null;
});

// Read from users/{uid}; null when no plan is active
final activePlanIdProvider = Provider<String?>((ref) {
  final uid = ref.watch(currentUidProvider).value;
  if (uid == null) return null;

  return ref.watch(userProfileProvider(uid)).value?.activePlanId;
});

// Null when there's no active plan, or it was deleted on another device
final activePlanProvider = Provider<PlanModel?>((ref) {
  final id = ref.watch(activePlanIdProvider);
  final plans = ref.watch(plansProvider).value ?? const [];
  if (id == null) return null;

  for (final plan in plans) {
    if (plan.id == id) return plan;
  }
  return null;
});
