import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:repwise/features/profile/repositories/user_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn.instance;

  // initialize may only run once per app, and AuthService is created per screen
  static Future<void>? _googleReady;
  Future<void> _initGoogle() => _googleReady ??= _google.initialize();

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

  // Returns null if the account picker is closed. AuthGate creates the profile
  Future<User?> signInWithGoogle() async {
    await _initGoogle();

    final GoogleSignInAccount account;
    try {
      account = await _google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() async {
    // Clears the picked Google account so the picker shows next time
    try {
      await _initGoogle();
      await _google.signOut();
    } on GoogleSignInException {
      // Firebase sign-out below still logs the user out
    }
    await _auth.signOut();
  }

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
      case 'account-exists-with-different-credential':
        return 'This email already has a password. Log in with your email and password';
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

  // Plain-language message for a Google sign-in error
  static String googleMessageFor(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.uiUnavailable:
        return "Google sign-in isn't available on this phone";
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return "Google sign-in isn't set up right (${e.code.name})";
      default:
        return "Couldn't sign in with Google. Try again";
    }
  }
}
