import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/app_cubit.dart';
import 'cubits/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/startup_navigation_shell.dart';
import 'screens/student_navigation_shell.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final authStatus = state.authStatus;
        if (authStatus == AuthStatus.initial ||
            authStatus == AuthStatus.loading ||
            authStatus == AuthStatus.unauthenticated) {
          return const AuthScreen();
        }
        if (authStatus == AuthStatus.needsProfile) {
          return const ProfileSetupScreen();
        }
        if (authStatus == AuthStatus.authenticated) {
          final profile = state.currentProfile;
          if (profile?.role == 'startup') {
            return const StartupNavigationShell();
          }
          return const StudentNavigationShell();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
