import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/sessions/models/session_model.dart';
import 'package:repwise/features/sessions/repositories/session_repository.dart';
import 'package:repwise/features/today/providers/selected_day_provider.dart';

final sessionRepositoryProvider = Provider((ref) => SessionRepository());

// Retrying can't fix a rules denial
Duration? _retry(int retryCount, Object error) =>
    error is FirebaseException && error.code == 'permission-denied'
    ? null
    : ProviderContainer.defaultRetry(retryCount, error);

// The session in progress; null when none is running
final activeSessionProvider = StreamProvider<SessionModel?>((ref) {
  final uid = ref.watch(currentUidProvider).value;

  // Stays loading while signed out
  if (uid == null) return const Stream.empty();

  return ref.watch(sessionRepositoryProvider).watchActive(uid);
}, retry: _retry);

// Every session started this week, Monday onwards
final weekSessionsProvider = StreamProvider<List<SessionModel>>((ref) {
  final uid = ref.watch(currentUidProvider).value;
  if (uid == null) return const Stream.empty();

  return ref
      .watch(sessionRepositoryProvider)
      .watchSince(uid, currentWeek().first);
}, retry: _retry);

// The last workout finished on a given day; null if there wasn't one
final finishedSessionOnProvider = Provider.family<SessionModel?, DateTime>((
  ref,
  day,
) {
  final sessions = ref.watch(weekSessionsProvider).value ?? const [];

  SessionModel? last;
  for (final s in sessions) {
    if (!s.isActive && dateOnly(s.startedAt) == dateOnly(day)) last = s;
  }
  return last;
});
