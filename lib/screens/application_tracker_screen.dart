import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_cubit.dart';
import '../services/firebase_service.dart';

class ApplicationTrackerScreen extends StatelessWidget {
  ApplicationTrackerScreen({super.key});

  final FirebaseService _service = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AppCubit>().state.currentProfile;
    if (profile == null) return const SizedBox();
    return Scaffold(
      appBar: AppBar(title: const Text('My applications')),
      body: StreamBuilder(
        stream: _service.streamMyApplications(profile.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final applications = snapshot.data!;
          if (applications.isEmpty) return const Center(child: Text('No applications yet.'));
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              return Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ListTile(
                  title: Text(app.opportunityTitle),
                  subtitle: Text(app.coverNote.isEmpty ? 'No note provided' : app.coverNote),
                  trailing: Chip(label: Text(app.status)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
