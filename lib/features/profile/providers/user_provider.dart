import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/profile/models/user_model.dart';
import 'package:repwise/features/profile/repositories/user_repository.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

final userProfileProvider = StreamProvider.family<UserModel?, String>(
  (ref, uid) {
    // Rebuilds on every sign in and sign out, so a permission-denied
    // from the last session isn't kept after signing back in
    final currentUid = ref.watch(currentUidProvider).value;

    // Stays loading until this uid is the one signed in
    if (currentUid != uid) return const Stream.empty();

    return ref.watch(userRepositoryProvider).watchUser(uid);
  },
  // Retrying can't fix a rules denial and keeps AuthGate on the spinner
  retry: (retryCount, error) =>
      error is FirebaseException && error.code == 'permission-denied'
      ? null
      : ProviderContainer.defaultRetry(retryCount, error),
);
