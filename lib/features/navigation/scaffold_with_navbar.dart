import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A Scaffold with a persistent NavigationBar that handles
/// branch navigation for a StatefulShellRoute.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => _onTap(context, index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          // Additional tabs can be added here (e.g. Analytics, History)
        ],
      ),
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, the initial location of that branch
    // is used (e.g. /today, /dashboard, /settings).
    // However, if the user taps the currently active item, we might want to
    // reset the stack (go to initial location of that branch).
    navigationShell.goBranch(
      index,
      // A common pattern when tapping the currently selected item is to reset
      // the stack to the initial location of that branch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
