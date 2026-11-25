import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/features/auth/services/auth_service.dart';

// The signed-in user's uid; null when signed out
final currentUidProvider = StreamProvider<String?>(
  (ref) => AuthService().authStateChanges.map((user) => user?.uid),
);

// The signed-in user, updated on reload and token refresh; null when signed out
final authUserProvider = StreamProvider<User?>(
  (ref) => AuthService().userChanges,
);
