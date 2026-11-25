import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/auth/services/auth_service.dart';
import 'package:repwise/features/settings/widgets/theme_picker.dart';

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
            style: TextButton.styleFrom(foregroundColor: context.colors.red),
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
    final colors = context.colors;

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
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          const ListTile(
            leading: Icon(Icons.contrast_rounded),
            title: Text('Theme'),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: ThemePicker(),
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: colors.red),
            title: Text('Log out', style: TextStyle(color: colors.red)),
            onTap: () => _confirmLogOut(context),
          ),
        ],
      ),
    );
  }
}
