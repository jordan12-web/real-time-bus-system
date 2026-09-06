import 'package:flutter/material.dart';

import '../screens/my_trips_screen.dart';
import '../screens/tracking_screen.dart';
import '../screens/trip_list_screen.dart';
import '../theme/design_tokens.dart';

/// Main passenger navigation shell featuring a clean bottom NavigationBar.
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    TripListScreen(),
    MyTripsScreen(),
    TrackingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: primary.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(
            key: Key('nav_search_trips'),
            icon: Icon(Icons.directions_bus_outlined),
            selectedIcon: Icon(Icons.directions_bus_rounded),
            label: 'Search Trips',
          ),
          NavigationDestination(
            key: Key('nav_my_tickets'),
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded),
            label: 'My Tickets',
          ),
          NavigationDestination(
            key: Key('nav_live_track'),
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar_rounded),
            label: 'Live Track',
          ),
        ],
      ),
    );
  }
}
