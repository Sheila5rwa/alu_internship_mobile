import 'package:flutter/material.dart';

import 'chat_hub_screen.dart';
import 'startup_dashboard_screen.dart';
import 'startup_applicants_screen.dart';
import 'profile_screen.dart';

class StartupNavigationShell extends StatefulWidget {
  const StartupNavigationShell({super.key});

  @override
  State<StartupNavigationShell> createState() => _StartupNavigationShellState();
}

class _StartupNavigationShellState extends State<StartupNavigationShell> {
  int _index = 0;

  final List<Widget> _pages = [
    const StartupDashboardScreen(),
    const StartupApplicantsScreen(),
    const ChatHubScreen(),
    const ProfileScreen(),
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
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Applicants'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
