import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/layout/app_shell.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/auth/screens/login_screen.dart';
import 'package:repwise/features/auth/screens/verify_email_screen.dart';
import 'package:repwise/features/auth/services/auth_service.dart';
import 'package:repwise/features/profile/providers/user_provider.dart';

// Picks the first screen: login, profile setup, or home
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds on sign in, sign out and verification
    return ref.watch(authUserProvider).when(
      loading: () => const _Loading(),
      error: (err, stack) =>
          _ProfileError(title: "Couldn't check your sign-in", error: err),
      data: (user) {
        if (user == null) return const LoginScreen();

        // Google accounts arrive verified; email sign-ups wait here
        if (!user.emailVerified) {
          return VerifyEmailScreen(email: user.email ?? '');
        }

        // Signed in, so check for a users/{uid} profile
        final profileAsync = ref.watch(userProfileProvider(user.uid));

        return profileAsync.when(
          data: (profile) =>
              profile == null ? _CreateProfile(user: user) : const AppShell(),
          loading: () => const _Loading(),
          error: (err, stack) =>
              _ProfileError(title: "Couldn't load your profile", error: err),
        );
      },
    );
  }
}

// First sign-in: writes users/{uid}, then the profile stream moves on
class _CreateProfile extends ConsumerStatefulWidget {
  const _CreateProfile({required this.user});

  final User user;

  @override
  ConsumerState<_CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends ConsumerState<_CreateProfile> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    _create();
  }

  Future<void> _create() async {
    try {
      await ref
          .read(userRepositoryProvider)
          .createUser(
            uid: widget.user.uid,
            name: widget.user.displayName ?? '',
            email: widget.user.email ?? '',
          );
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _retry() {
    setState(() => _error = null);
    _create();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error == null) return const _Loading();

    return _ProfileError(
      title: "Couldn't set up your profile",
      error: error,
      onRetry: _retry,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// Shown when the profile can't be read or written, with a way out
class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.title, required this.error, this.onRetry});

  final String title;
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (onRetry != null)
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              TextButton(
                onPressed: () => AuthService().signOut(),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
