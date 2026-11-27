import 'package:flutter_riverpod/flutter_riverpod.dart';

// Midnight of the given day, so dates compare by day only
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// Monday to Sunday of the week that holds today
List<DateTime> currentWeek() {
  final today = dateOnly(DateTime.now());
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return [for (var i = 0; i < 7; i++) DateTime(monday.year, monday.month, monday.day + i)];
}

class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => dateOnly(DateTime.now());

  void select(DateTime day) => state = dateOnly(day);
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime>(
  SelectedDayNotifier.new,
);
