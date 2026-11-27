import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';

const _shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _longDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _radius = BorderRadius.all(Radius.circular(14));

// Rounded rectangle with the short day name over the date. Filled with ink
// when selected, an ink ring on today when another day is selected
class DayChip extends StatelessWidget {
  const DayChip({
    super.key,
    required this.day,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final fill = selected ? c.ink : c.surface;
    final nameColor = selected ? c.background : c.textSecondary;
    final numberColor = selected ? c.background : c.text;
    final ring = !selected && isToday
        ? BorderSide(color: c.ink, width: 2)
        : BorderSide.none;

    return Semantics(
      button: true,
      selected: selected,
      label: '${_longDays[day.weekday - 1]} ${day.day}${isToday ? ', today' : ''}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
        curve: Curves.easeOut,
        decoration: ShapeDecoration(
          color: fill,
          shape: RoundedRectangleBorder(borderRadius: _radius, side: ring),
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const RoundedRectangleBorder(borderRadius: _radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 68,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _shortDays[day.weekday - 1],
                    style: textTheme.labelMedium?.copyWith(color: nameColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: textTheme.titleMedium?.copyWith(
                      color: numberColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
