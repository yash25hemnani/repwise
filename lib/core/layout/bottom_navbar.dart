import 'package:flutter/material.dart';
import 'package:repwise/core/layout/nav_item_model.dart';
import 'package:repwise/core/theme/app_colors.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<NavItemModel> navItems;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < navItems.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _NavItem(
                  item: navItems[i],
                  selected: i == selectedIndex,
                  onTap: () => onTap(i),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// A surface circle with an icon, or when selected a card pill with the
// destination's plate dot and label, outlined in light mode
class _NavItem extends StatelessWidget {
  final NavItemModel item;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = Theme.of(context).brightness == Brightness.light;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? c.card : c.surface,
        shape: StadiumBorder(
          side: selected && light
              ? BorderSide(color: c.ink, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedSize(
            duration: animate
                ? const Duration(milliseconds: 200)
                : Duration.zero,
            curve: Curves.easeOut,
            child: SizedBox(
              height: 52,
              child: Padding(
                // 14 + 24 icon + 14 = a 52 circle when not selected
                padding: EdgeInsets.symmetric(horizontal: selected ? 20 : 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: selected
                      ? [
                          _PlateDot(color: item.color),
                          const SizedBox(width: 10),
                          Text(
                            item.label,
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(color: c.text),
                          ),
                        ]
                      : [Icon(item.icon, color: c.textSecondary)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlateDot extends StatelessWidget {
  final Color color;

  const _PlateDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.ink,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
    );
  }
}
