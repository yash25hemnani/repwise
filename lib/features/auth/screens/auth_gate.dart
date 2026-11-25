import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repwise/core/layout/app_shell.dart';
import 'package:repwise/features/auth/screens/login_screen.dart';
import 'package:repwise/features/auth/services/auth_service.dart';

// Picks the first screen: login or home
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds on every sign in and sign out
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Firebase hasn't reported the auth state yet
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) return const LoginScreen();
        return const AppShell();
      },
    );
  }
}
