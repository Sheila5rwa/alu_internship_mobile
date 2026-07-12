import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/app_cubit.dart';
import '../models/application_model.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import 'chat_screen.dart';

class ApplicationTrackerScreen extends StatelessWidget {
  ApplicationTrackerScreen({super.key});

  final FirebaseService _service = FirebaseService();

  void _talkToFounder(BuildContext context, ApplicationModel app) {
    final studentProfile = context.read<AppCubit>().state.currentProfile;
    if (studentProfile == null) return;
    
    // Chat ID format: studentId_founderId
    final chatId = "${studentProfile.uid}_${app.startupId}";
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          peerId: app.startupId,
          peerName: app.startupName.isEmpty ? 'Startup founder' : app.startupName,
          studentId: studentProfile.uid,
          studentName: studentProfile.displayName,
          startupId: app.startupId,
          startupName: app.startupName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.read<AppCubit>().state.currentProfile;
    if (profile == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Tracker'),
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: _service.streamMyApplications(profile.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AluTheme.primaryMaroon));
          }
          final applications = snapshot.data ?? [];
          if (applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No Applications Yet',
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Search opportunities and submit interest to get started on your internship path!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              
              Color statusColor = Colors.orange;
              if (app.status == 'Confirmed') {
                statusColor = AluTheme.accentSpruce;
              } else if (app.status == 'Interview Scheduled') {
                statusColor = AluTheme.primaryMaroon;
              } else if (app.status == 'Rejected') {
                statusColor = Colors.redAccent;
              }

              return Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.opportunityTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Posted by ${app.startupName}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              app.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: AluTheme.borderGrey),
                      
                      // Cover Note Text
                      Text(
                        'Your Cover Note:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.coverNote.isEmpty ? 'No cover note submitted.' : app.coverNote,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),

                      // Interview details if scheduled
                      if (app.status == 'Interview Scheduled') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AluTheme.primaryMaroon.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AluTheme.primaryMaroon.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.event, color: AluTheme.primaryMaroon, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Interview Agenda Scheduled',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AluTheme.primaryMaroon),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Date: ${app.interviewDate} @ ${app.interviewTime}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              
                              if (app.interviewNotes.isNotEmpty) ...[
                                Text('Prep Notes: ${app.interviewNotes}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 8),
                              ],

                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      icon: const Icon(Icons.video_call, size: 16),
                                      label: const Text('Join Interview Session', style: TextStyle(fontSize: 12)),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AluTheme.primaryMaroon,
                                        minimumSize: const Size(double.infinity, 36),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () async {
                                        final uri = Uri.parse(app.interviewLink);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Cannot open link: ${app.interviewLink}')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],

                      // Bottom actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Applied: ${app.appliedAt.day}/${app.appliedAt.month}/${app.appliedAt.year}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.chat_bubble_outline, size: 16),
                            label: const Text('Chat Founder'),
                            onPressed: () => _talkToFounder(context, app),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
