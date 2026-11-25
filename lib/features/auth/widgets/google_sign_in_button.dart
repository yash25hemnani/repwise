import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/auth/services/auth_service.dart';

// Continue with Google, shared by login and signup
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key, this.onSignedIn});

  // Signup uses this to pop back to AuthGate
  final VoidCallback? onSignedIn;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final _authService = AuthService();

  bool _isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signIn() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      // Null means the picker was closed, so stay put
      if (user != null && mounted) widget.onSignedIn?.call();
    } on FirebaseAuthException catch (e) {
      if (mounted) _showMessage(AuthService.messageFor(e));
    } on GoogleSignInException catch (e) {
      if (mounted) _showMessage(AuthService.googleMessageFor(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _signIn,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.text,
        side: BorderSide(color: context.colors.border),
      ),
      child: _isLoading
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/icons/google_g.svg', height: 18),
                const SizedBox(width: 10),
                const Text('Continue with Google'),
              ],
            ),
    );
  }
}
