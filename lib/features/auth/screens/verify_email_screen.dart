import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/auth/services/auth_service.dart';

// Keeps email sign-ups here until they tap the link
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _authService = AuthService();
  late final AppLifecycleListener _lifecycle;

  bool _isChecking = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Checks again when they come back from the email app
    _lifecycle = AppLifecycleListener(onResume: () => _check(quiet: true));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // AuthGate moves on by itself once verified
  Future<void> _check({bool quiet = false}) async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final verified = await _authService.checkEmailVerified();
      if (!verified && !quiet && mounted) {
        _showMessage('Not verified yet. Tap the link in the email first');
      }
    } on FirebaseAuthException catch (e) {
      if (!quiet && mounted) _showMessage(AuthService.messageFor(e));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resend() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      await _authService.resendVerification();
      if (mounted) _showMessage('Sent a new link to ${widget.email}');
    } on FirebaseAuthException catch (e) {
      if (mounted) _showMessage(AuthService.messageFor(e));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.mark_email_unread_rounded,
                  size: 56,
                  color: colors.primaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  'Check your email',
                  textAlign: TextAlign.center,
                  style: text.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a link to ${widget.email}. Tap it, then come back '
                  "here. Can't find it? Check your spam folder.",
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _check,
                  child: _isChecking
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.onAccent,
                          ),
                        )
                      : const Text("I've verified"),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isSending ? null : _resend,
                  child: const Text('Resend email'),
                ),
                TextButton(
                  onPressed: _authService.signOut,
                  child: const Text('Log out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
