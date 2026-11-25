import 'package:flutter/material.dart';
import 'package:repwise/core/layout/bottom_navbar.dart';
import 'package:repwise/core/layout/nav_item_model.dart';
import 'package:repwise/core/widgets/coming_soon.dart';
import 'package:repwise/features/settings/screens/settings_screen.dart';

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
      page: ComingSoon(title: 'Today'),
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Today',
    ),
    NavItemModel(
      page: ComingSoon(title: 'Plan'),
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Plan',
    ),
    NavItemModel(
      page: ComingSoon(title: 'Progress'),
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Progress',
    ),
    NavItemModel(
      page: SettingsScreen(),
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
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
