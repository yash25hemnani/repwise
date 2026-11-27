import 'package:flutter/material.dart';
import 'package:repwise/core/theme/app_colors.dart';

// The one primary action per screen: a plate-coloured fill with a hard
// shadow it presses down into. Light mode adds an ink outline; dark mode
// drops it and uses the plate's own darker edge as the shadow. Flat buttons
// sit on a plate that already has depth, so they shrink when pressed instead
class PlateButton extends StatefulWidget {
  const PlateButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fill = AppColors.primary,
    this.foreground,
    this.flat = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color fill;
  final Color? foreground;
  final bool flat;

  @override
  State<PlateButton> createState() => _PlateButtonState();
}

class _PlateButtonState extends State<PlateButton> {
  static const _depth = 5.0;
  bool _down = false;

  void _press(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.ink;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final enabled = widget.onPressed != null;
    final depth = widget.flat ? 0.0 : _depth;
    final lift = _down ? 0.0 : depth;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 120);

    // Only blue takes white text by default
    final onFill =
        widget.foreground ??
        (widget.fill == AppColors.blue ? AppColors.onBlue : AppColors.onAccent);
    final outline = dark || widget.flat ? AppColors.transparent : ink;
    final edge = dark
        ? Color.lerp(widget.fill, AppColors.onAccent, 0.45)!
        : ink;
    final style = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: onFill);

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _press(true) : null,
        onTapUp: enabled ? (_) => _press(false) : null,
        onTapCancel: () => _press(false),
        onTap: widget.onPressed,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          // Room for the shadow, so the button doesn't grow when pressed
          child: Padding(
            padding: EdgeInsets.only(right: depth, bottom: depth),
            child: AnimatedScale(
              scale: widget.flat && _down ? 0.97 : 1,
              duration: duration,
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(
                  depth - lift,
                  depth - lift,
                  0,
                ),
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.fill,
                  borderRadius: BorderRadius.circular(14),
                  // Kept when transparent so the size matches in both modes
                  border: Border.all(color: outline, width: 3),
                  boxShadow: widget.flat
                      ? null
                      : [BoxShadow(color: edge, offset: Offset(lift, lift))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: onFill),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
