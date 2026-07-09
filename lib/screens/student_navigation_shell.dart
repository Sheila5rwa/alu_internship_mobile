import 'package:flutter/material.dart';

import 'application_tracker_screen.dart';
import 'home_screen.dart';

class StudentNavigationShell extends StatefulWidget {
  const StudentNavigationShell({super.key});

  @override
  State<StudentNavigationShell> createState() => _StudentNavigationShellState();
}

class _StudentNavigationShellState extends State<StudentNavigationShell> {
  int _index = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    ApplicationTrackerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Applications'),
        ],
      ),
    );
  }
}
