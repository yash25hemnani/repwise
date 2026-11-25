import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/auth/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // AuthGate sees the signed-out user and swaps to the login screen
  Future<void> _confirmLogOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true) await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: Text(user.displayName ?? 'Your account'),
              subtitle: Text(
                user.email ?? '',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.red),
            title: const Text(
              'Log out',
              style: TextStyle(color: AppColors.red),
            ),
            onTap: () => _confirmLogOut(context),
          ),
        ],
      ),
    );
  }
}
