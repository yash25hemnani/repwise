import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_theme.dart';
import 'package:repwise/features/auth/screens/auth_gate.dart';
import 'package:repwise/firebase_options.dart';

Future<void> main() async {
  // Needed before any native plugin call ahead of runApp
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Offline cache; must be set before the first Firestore call
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const ProviderScope(child: RepwiseApp()));
}

class RepwiseApp extends StatelessWidget {
  const RepwiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repwise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Dark only until light tokens exist (THEM-01)
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
    );
  }
}
