import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/config/prefs_provider.dart';
import 'package:repwise/core/theme/app_theme.dart';
import 'package:repwise/features/auth/screens/auth_gate.dart';
import 'package:repwise/features/settings/providers/theme_provider.dart';
import 'package:repwise/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Needed before any native plugin call ahead of runApp
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Offline cache; must be set before the first Firestore call
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  // Loaded up front so the saved theme applies on the first frame
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const RepwiseApp(),
    ),
  );
}

class RepwiseApp extends ConsumerWidget {
  const RepwiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Repwise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeProvider),
      // Screens without an app bar still get readable status bar icons
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).appBarTheme.systemOverlayStyle!,
        child: child!,
      ),
      home: const AuthGate(),
    );
  }
}
