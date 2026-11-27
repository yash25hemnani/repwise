import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/utils/workout_format.dart';
import 'package:repwise/core/widgets/plate_card.dart';
import 'package:repwise/features/plans/models/plan_day_model.dart';

const _radius = 20.0;
const _shadow = 5.0;

// A day card in the plan editor's week grid: day name, workout name, and
// the exercise count pinned to the bottom. Today is filled with ink. Rest
// days are dashed and hatched, with no shadow
class PlanDayTile extends StatelessWidget {
  const PlanDayTile({
    super.key,
    required this.weekday,
    required this.day,
    required this.isToday,
    required this.onTap,
  });

  final PlanWeekday weekday;
  final PlanDayModel day;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final light = Theme.of(context).brightness == Brightness.light;
    final training = !day.isRest;
    final title = day.title.isNotEmpty
        ? day.title
        : training
        ? 'Workout'
        : 'Rest';

    final strong = isToday ? c.background : c.text;
    final quiet = isToday
        ? c.background.withValues(alpha: 0.72)
        : c.textSecondary;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              weekday.label,
              maxLines: 1,
              style: textTheme.titleMedium?.copyWith(
                color: strong,
                fontVariations: const [FontVariation.width(118)],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(
              color: training ? strong : quiet,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (training)
            Text(
              '${countLabel(day.exercises.length, 'exercise')} · '
              '${countLabel(day.setCount, 'set')}',
              maxLines: 2,
              style: textTheme.labelMedium?.copyWith(color: quiet),
            ),
        ],
      ),
    );

    final Decoration decoration;
    if (training) {
      decoration = plateCard(
        context,
        fill: isToday ? c.ink : null,
        radius: _radius,
        shadow: _shadow,
      );
    } else {
      decoration = BoxDecoration(
        color: isToday ? c.ink : AppColors.transparent,
        borderRadius: BorderRadius.circular(_radius),
      );
    }

    return Semantics(
      button: true,
      label:
          '${weekday.label}${isToday ? ', today' : ''}, $title'
          '${training ? ', ${countLabel(day.exercises.length, 'exercise')}' : ''}',
      excludeSemantics: true,
      child: Padding(
        // Room for the hard shadow
        padding: const EdgeInsets.only(right: _shadow, bottom: _shadow),
        child: DecoratedBox(
          decoration: decoration,
          child: CustomPaint(
            painter: training
                ? null
                : _RestPainter(
                    hatch: isToday
                        ? c.background.withValues(alpha: 0.16)
                        : c.ink.withValues(alpha: 0.09),
                    dash: isToday
                        ? null
                        : light
                        ? c.ink
                        : c.textSecondary,
                  ),
            child: Material(
              type: MaterialType.transparency,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_radius),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 128),
                  child: IntrinsicHeight(child: content),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 45° hatching, 2 px lines 11 px apart, clipped to the card, and a dashed
// outline when [dash] is set
class _RestPainter extends CustomPainter {
  const _RestPainter({required this.hatch, required this.dash});

  final Color hatch;
  final Color? dash;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    );

    canvas.save();
    canvas.clipRRect(rrect);
    final line = Paint()
      ..color = hatch
      ..strokeWidth = 2;
    const gap = 11.0;
    final span = size.width + size.height;
    for (var x = -size.height; x < span; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        line,
      );
    }
    canvas.restore();

    final dashColor = dash;
    if (dashColor == null) return;
    final stroke = Paint()
      ..color = dashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()..addRRect(rrect.deflate(1));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = math.min(d + 8, metric.length);
        canvas.drawPath(metric.extractPath(d, end), stroke);
        d += 14;
      }
    }
  }

  @override
  bool shouldRepaint(_RestPainter old) =>
      old.hatch != hatch || old.dash != dash;
}
