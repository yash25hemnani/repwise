import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';

// Round bell button at the top right of Today
class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key, this.onPressed});

  // Null until notifications exist
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = Theme.of(context).brightness == Brightness.light;

    return Tooltip(
      message: 'Notifications',
      child: Material(
        color: light ? c.card : c.surface,
        shape: CircleBorder(
          side: light ? BorderSide(color: c.ink, width: 2) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: c.text,
              semanticLabel: 'Notifications',
            ),
          ),
        ),
      ),
    );
  }
}
