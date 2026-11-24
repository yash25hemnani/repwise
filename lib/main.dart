import 'package:flutter/material.dart';
import 'package:repwise/core/layout/app_shell.dart';
import 'package:repwise/core/theme/app_theme.dart';

void main() {
  runApp(const RepwiseApp());
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
      home: const AppShell(),
    );
  }
}