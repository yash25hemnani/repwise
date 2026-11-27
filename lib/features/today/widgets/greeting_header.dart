import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/features/auth/providers/auth_provider.dart';
import 'package:repwise/features/profile/providers/user_provider.dart';
import 'package:repwise/features/today/widgets/notification_button.dart';

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// "Hello, <first name>" with today's date and the bell on the right
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key, this.onNotificationsPressed});

  final VoidCallback? onNotificationsPressed;

  // e.g. Thursday, 27 November
  static String _date(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();

    final uid = ref.watch(currentUidProvider).value;
    final name = uid == null
        ? null
        : ref.watch(userProfileProvider(uid)).value?.name.trim();
    final firstName =
        (name == null || name.isEmpty) ? null : name.split(RegExp(r'\s+')).first;

    final greeting = firstName == null ? 'Hello' : 'Hello, $firstName';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(color: c.text),
              ),
              const SizedBox(height: 2),
              Text(
                _date(now),
                style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        NotificationButton(onPressed: onNotificationsPressed),
      ],
    );
  }
}
