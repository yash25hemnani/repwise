import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repwise/features/profile/models/user_model.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  // Creates users/{uid} on first sign-in. Signup and AuthGate can both call
  // this, so a second call only fills in a name the first one didn't have
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    final ref = _db.collection('users').doc(uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (!snap.exists) {
        final user = UserModel(
          uid: uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
        tx.set(ref, {
          ...user.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      final savedName = snap.data()?['name'] as String? ?? '';
      if (savedName.isEmpty && name.isNotEmpty) tx.update(ref, {'name': name});
    });
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;

      return UserModel.fromMap(uid, snap.data()!);
    });
  }
}
