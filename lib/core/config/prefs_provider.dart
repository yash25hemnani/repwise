import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Loaded in main before runApp, so reads are synchronous
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main'),
);
