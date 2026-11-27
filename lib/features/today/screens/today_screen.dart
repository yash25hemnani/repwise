import 'package:flutter/material.dart';
import 'package:repwise/features/today/widgets/greeting_header.dart';
import 'package:repwise/features/today/widgets/today_workout_card.dart';
import 'package:repwise/features/today/widgets/week_strip.dart';

// The home tab: greeting, this week's days, then the selected day's workout
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: const [
            GreetingHeader(),
            SizedBox(height: 20),
            WeekStrip(),
            SizedBox(height: 20),
            TodayWorkoutCard(),
          ],
        ),
      ),
    );
  }
}
