import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/utils/workout_format.dart';
import 'package:repwise/core/widgets/plate_button.dart';
import 'package:repwise/core/widgets/plate_card.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';
import 'package:repwise/features/plans/models/plan_model.dart';
import 'package:repwise/features/plans/providers/plan_provider.dart';
import 'package:repwise/features/profile/providers/user_provider.dart';
import 'package:repwise/features/sessions/models/session_model.dart';
import 'package:repwise/features/sessions/providers/session_provider.dart';
import 'package:repwise/features/sessions/widgets/plate_strip.dart';
import 'package:repwise/features/today/providers/selected_day_provider.dart';

const _tabular = [FontFeature.tabularFigures()];
const _onBlue = AppColors.onBlue;
final _onBlueFaint = AppColors.onBlue.withValues(alpha: 0.75);

bool _waiting(AsyncValue<Object?> v) => !v.hasValue && !v.hasError;

// The selected day's workout: in progress, done, training, rest, or no plan
class TodayWorkoutCard extends ConsumerWidget {
  const TodayWorkoutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider).value;
    if (uid == null) return const SizedBox.shrink();

    final plans = ref.watch(plansProvider);
    final profile = ref.watch(userProfileProvider(uid));
    final active = ref.watch(activeSessionProvider);

    // Nothing until the data lands, so "no plan" doesn't flash first
    if (_waiting(plans) || _waiting(profile) || _waiting(active)) {
      return const SizedBox.shrink();
    }

    // A running workout wins on every day, so a second can't be started
    final session = active.value;
    if (session != null) return _ProgressCard(session: session);

    final plan = ref.watch(activePlanProvider);
    if (plan == null) return const _NoPlanCard();

    final selected = ref.watch(selectedDayProvider);
    final finished = ref.watch(finishedSessionOnProvider(selected));
    if (finished != null) return _DoneCard(session: finished);

    final weekday = PlanWeekday.fromDate(selected);
    if (plan.day(weekday).isRest) {
      return _RestCard(plan: plan, selected: selected);
    }
    return _TrainingCard(plan: plan, weekday: weekday);
  }
}

// The plate card shell, with room on the right and bottom for its shadow
class _FilledCard extends StatelessWidget {
  const _FilledCard({required this.fill, required this.child});

  final Color fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: plateCard(context, fill: fill),
        child: child,
      ),
    );
  }
}

class _TrainingCard extends ConsumerStatefulWidget {
  const _TrainingCard({required this.plan, required this.weekday});

  final PlanModel plan;
  final PlanWeekday weekday;

  @override
  ConsumerState<_TrainingCard> createState() => _TrainingCardState();
}

class _TrainingCardState extends ConsumerState<_TrainingCard> {
  bool _starting = false;

  void _start() {
    final uid = ref.read(currentUidProvider).value;
    if (uid == null || _starting) return;
    setState(() => _starting = true);
    final messenger = ScaffoldMessenger.of(context);

    // Not awaited: the local write shows the session at once, even offline
    ref
        .read(sessionRepositoryProvider)
        .start(uid: uid, plan: widget.plan, weekday: widget.weekday)
        .catchError((Object _) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Couldn\'t start the workout. Try again.'),
            ),
          );
          if (mounted) setState(() => _starting = false);
          return '';
        });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final day = widget.plan.day(widget.weekday);
    final exercises = day.exercises;
    final shown = exercises.take(3).toList();

    return _FilledCard(
      fill: AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.title.isEmpty ? widget.weekday.label : day.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineLarge?.copyWith(color: _onBlue),
          ),
          const SizedBox(height: 6),
          Text(
            '${countLabel(exercises.length, 'exercise')} · '
            '${countLabel(day.setCount, 'set')}',
            style: textTheme.bodyMedium?.copyWith(
              color: _onBlueFaint,
              fontFeatures: _tabular,
            ),
          ),
          const SizedBox(height: 16),
          PlateStrip(
            done: List.filled(exercises.length, false),
            outline: _onBlue,
            emptyFill: AppColors.blue,
            doneFill: AppColors.green,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < shown.length; i++)
            _ExerciseLine(
              number: i + 1,
              name: shown[i].name,
              detail: setsSummary(shown[i]),
            ),
          if (exercises.length > shown.length)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 2),
              child: Text(
                '+${exercises.length - shown.length} more',
                style: textTheme.bodyMedium?.copyWith(color: _onBlueFaint),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PlateButton(
              label: 'Start workout',
              icon: Icons.play_arrow_rounded,
              fill: AppColors.white,
              onPressed: _starting ? null : _start,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.session});

  final SessionModel session;

  // The workout screen replaces this in step 3
  void _open(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('The workout screen is coming next.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final exercises = session.exercises;
    final nextIndex = exercises.indexWhere((e) => !e.isDone);
    final next = nextIndex == -1 ? null : exercises[nextIndex];

    return _FilledCard(
      fill: AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineLarge?.copyWith(color: _onBlue),
          ),
          const SizedBox(height: 6),
          Text(
            '${session.doneExerciseCount} of '
            '${countLabel(exercises.length, 'exercise')} done',
            style: textTheme.bodyMedium?.copyWith(
              color: _onBlueFaint,
              fontFeatures: _tabular,
            ),
          ),
          const SizedBox(height: 16),
          PlateStrip(
            done: [for (final e in exercises) e.isDone],
            current: next == null ? null : nextIndex,
            outline: _onBlue,
            emptyFill: AppColors.blue,
            doneFill: AppColors.green,
          ),
          const SizedBox(height: 14),
          if (next != null)
            _ExerciseLine(
              number: nextIndex + 1,
              name: next.name,
              detail:
                  '${next.doneSetCount} of ${countLabel(next.sets.length, 'set')}',
            )
          else
            Text(
              'Every exercise is done. Finish to save it.',
              style: textTheme.bodyMedium?.copyWith(color: _onBlue),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PlateButton(
              label: 'Resume workout',
              icon: Icons.play_arrow_rounded,
              fill: AppColors.white,
              onPressed: () => _open(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Green is the done plate, so the finished day reads at a glance
class _DoneCard extends StatelessWidget {
  const _DoneCard({required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const ink = AppColors.onAccent;

    return _FilledCard(
      fill: AppColors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineLarge?.copyWith(color: ink),
          ),
          const SizedBox(height: 6),
          Text(
            'Workout done',
            style: textTheme.bodyMedium?.copyWith(color: ink),
          ),
          const SizedBox(height: 16),
          PlateStrip(
            done: [for (final e in session.exercises) e.isDone],
            outline: ink,
            emptyFill: AppColors.green,
            doneFill: ink,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(
                value: '${formatThousands(session.volumeKg)} kg',
                label: 'Volume',
              ),
              _Stat(value: '${session.doneSetCount}', label: 'Sets'),
              _Stat(value: formatElapsed(session.duration), label: 'Time'),
            ],
          ),
        ],
      ),
    );
  }
}

// Dashed and hatched: an empty rack, nothing loaded today
class _RestCard extends StatelessWidget {
  const _RestCard({required this.plan, required this.selected});

  final PlanModel plan;
  final DateTime selected;

  // The first training day after the selected one, e.g. "Next: Legs, tomorrow"
  String _nextLine() {
    final today = dateOnly(DateTime.now());
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    for (var i = 1; i <= 7; i++) {
      final date = DateTime(selected.year, selected.month, selected.day + i);
      final weekday = PlanWeekday.fromDate(date);
      final day = plan.day(weekday);
      if (day.isRest) continue;

      final when = date == today
          ? 'today'
          : date == tomorrow
          ? 'tomorrow'
          : weekday.label;
      return day.title.isEmpty
          ? 'Next workout: $when'
          : 'Next: ${day.title}, $when';
    }
    return 'This plan has no training days yet. Add some in the Plan tab.';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 6),
      child: CustomPaint(
        painter: _RestPainter(edge: c.ink, hatch: c.border),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rest day',
                style: textTheme.headlineLarge?.copyWith(color: c.text),
              ),
              const SizedBox(height: 6),
              Text(
                _nextLine(),
                style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoPlanCard extends StatelessWidget {
  const _NoPlanCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final light = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.all(Radius.circular(22)),
          border: light ? Border.all(color: c.ink, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No plan to follow',
              style: textTheme.titleMedium?.copyWith(color: c.text),
            ),
            const SizedBox(height: 4),
            Text(
              'Set a plan as active in the Plan tab and its workouts show up here.',
              style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// A numbered exercise in training order, with its sets on the right
class _ExerciseLine extends StatelessWidget {
  const _ExerciseLine({
    required this.number,
    required this.name,
    required this.detail,
  });

  final int number;
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$number',
              style: textTheme.labelLarge?.copyWith(
                color: _onBlueFaint,
                fontFeatures: _tabular,
              ),
            ),
          ),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                color: _onBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            detail,
            style: textTheme.bodyMedium?.copyWith(
              color: _onBlueFaint,
              fontFeatures: _tabular,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const ink = AppColors.onAccent;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              color: ink,
              fontFeatures: _tabular,
            ),
          ),
          Text(label, style: textTheme.bodySmall?.copyWith(color: ink)),
        ],
      ),
    );
  }
}

class _RestPainter extends CustomPainter {
  _RestPainter({required this.edge, required this.hatch});

  final Color edge;
  final Color hatch;

  static const _radius = Radius.circular(22);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, _radius);

    // Diagonal hatching, clipped to the card
    canvas.save();
    canvas.clipRRect(rrect);
    final hatchPaint = Paint()
      ..color = hatch
      ..strokeWidth = 2;
    for (var x = -size.height; x < size.width; x += 14) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        hatchPaint,
      );
    }
    canvas.restore();

    // Dashed outline
    final edgePaint = Paint()
      ..color = edge
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(rrect.deflate(1));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 14) {
        canvas.drawPath(metric.extractPath(d, d + 8), edgePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RestPainter old) =>
      old.edge != edge || old.hatch != hatch;
}
