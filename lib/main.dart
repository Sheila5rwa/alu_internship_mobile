import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_router.dart';
import 'cubits/app_cubit.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    return BlocProvider(
      create: (_) => AppCubit(service),
      child: MaterialApp(
        title: 'ALU Internship Hub',
        debugShowCheckedModeBanner: false,
        theme: AluTheme.lightTheme,
        home: const AppShell(),
      ),
    );
  }
}
