import 'package:flutter/material.dart';
import 'package:repwise/core/layout/bottom_navbar.dart';
import 'package:repwise/core/layout/nav_item_model.dart';
import 'package:repwise/core/theme/app_colors.dart';
import 'package:repwise/core/widgets/coming_soon.dart';
import 'package:repwise/features/plans/screens/plans_screen.dart';
import 'package:repwise/features/settings/screens/settings_screen.dart';
import 'package:repwise/features/today/screens/today_screen.dart';

// The signed-in app: the bottom navbar and the page for the selected tab
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;

  // Opened tabs stay built; unopened tabs load nothing
  final _opened = <int>{0};

  void _select(int index) {
    setState(() {
      selectedIndex = index;
      _opened.add(index);
    });
  }

  final navItems = const [
    NavItemModel(
      page: TodayScreen(),
      icon: Icons.home_outlined,
      label: 'Today',
      color: AppColors.blue,
    ),
    NavItemModel(
      page: PlansScreen(),
      icon: Icons.grid_view_outlined,
      label: 'Plan',
      color: AppColors.yellow,
    ),
    NavItemModel(
      page: ComingSoon(title: 'Progress'),
      icon: Icons.insights_outlined,
      label: 'Progress',
      color: AppColors.white,
    ),
    NavItemModel(
      page: SettingsScreen(),
      icon: Icons.settings_outlined,
      label: 'Settings',
      color: AppColors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          for (var i = 0; i < navItems.length; i++)
            _opened.contains(i) ? navItems[i].page : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: selectedIndex,
        onTap: _select,
        navItems: navItems,
      ),
    );
  }
}
