import 'package:firebase_auth/firebase_auth.dart';
import 'package:repwise/features/profile/repositories/user_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Emits on every sign in and sign out
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Creates the account, saves the name and sends a verification email
  Future<User?> signUp(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    await user?.updateDisplayName(name);

    // AuthGate may create the profile first, before the name is set
    if (user != null) {
      try {
        await UserRepository().createUser(
          uid: user.uid,
          name: name,
          email: email,
        );
      } on FirebaseException {
        // AuthGate retries and shows the error
      }
    }

    // Doesn't block sign-in
    await user?.sendEmailVerification();
    return user;
  }

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();

  // Plain-language message for a Firebase auth error
  static String messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Wrong email or password';
      case 'invalid-email':
        return "That email doesn't look right";
      case 'email-already-in-use':
        return 'An account with this email already exists. Log in or use Continue with Google';
      case 'weak-password':
        return 'Choose a stronger password';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes';
      case 'network-request-failed':
        return 'No connection. Check your internet and try again';
      default:
        return e.message ?? 'Something went wrong';
    }
  }
}
