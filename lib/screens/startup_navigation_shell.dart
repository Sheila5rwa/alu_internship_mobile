import 'package:flutter/material.dart';

import 'startup_dashboard_screen.dart';

class StartupNavigationShell extends StatefulWidget {
  const StartupNavigationShell({super.key});

  @override
  State<StartupNavigationShell> createState() => _StartupNavigationShellState();
}

class _StartupNavigationShellState extends State<StartupNavigationShell> {
  int _index = 0;

  final List<Widget> _pages = [
    const StartupDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
}
