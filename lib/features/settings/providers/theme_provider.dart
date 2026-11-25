import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/config/prefs_provider.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/profile/providers/user_provider.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    // Saved on the phone, so the right theme shows from the first frame
    final saved = ref.watch(prefsProvider).getString(_key);
    final mode = ThemeMode.values.asNameMap()[saved];
    if (mode != null) return mode;

    // Nothing saved yet (fresh install), so use the profile's once it loads
    final uid = ref.watch(currentUidProvider).value;
    if (uid == null) return ThemeMode.system;
    return ref.watch(userProfileProvider(uid)).value?.theme ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(prefsProvider).setString(_key, mode.name);

    final uid = ref.read(currentUidProvider).value;
    if (uid == null) return;
    // Not awaited: offline writes only finish once back online
    ref.read(userRepositoryProvider).updateTheme(uid, mode).ignore();
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
