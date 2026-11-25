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

// A surface circle with an icon, or a green pill with icon and label when selected
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
    final colors = context.colors;
    final color = selected ? AppColors.onAccent : colors.textSecondary;

    return Material(
      color: selected ? AppColors.green : colors.surface,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: SizedBox(
            height: 52,
            child: Padding(
              // 14 + 24 icon + 14 = a 52 circle when not selected
              padding: EdgeInsets.symmetric(horizontal: selected ? 24 : 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? item.activeIcon : item.icon, color: color),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: color),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
