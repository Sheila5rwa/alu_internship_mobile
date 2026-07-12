import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/app_cubit.dart';
import '../models/application_model.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import 'chat_screen.dart';

class ApplicantReviewScreen extends StatefulWidget {
  final String opportunityId;
  final String opportunityTitle;

  const ApplicantReviewScreen({
    super.key,
    required this.opportunityId,
    required this.opportunityTitle,
  });

  @override
  State<ApplicantReviewScreen> createState() => _ApplicantReviewScreenState();
}

class _ApplicantReviewScreenState extends State<ApplicantReviewScreen> {
  final FirebaseService _service = FirebaseService();

  Future<void> _openScheduleDialog(BuildContext context, ApplicationModel applicant) async {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final linkController = TextEditingController(text: 'https://meet.google.com/');
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Interview'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Interview Date',
                    hintText: 'Tap to select date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      dateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    }
                  },
                  validator: (value) => value == null || value.trim().isEmpty ? 'Date is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Interview Time',
                    hintText: 'Tap to select time',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      timeController.text = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                    }
                  },
                  validator: (value) => value == null || value.trim().isEmpty ? 'Time is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting Link or Room',
                    prefixIcon: Icon(Icons.video_call_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Link/Room is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Preparation Notes (Optional)',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );

    if (result != true) return;

    await _service.scheduleInterview(
      applicationId: applicant.id,
      date: dateController.text.trim(),
      time: timeController.text.trim(),
      link: linkController.text.trim(),
      notes: notesController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Interview scheduled successfully! Student notified.'),
        backgroundColor: AluTheme.accentSpruce,
      ),
    );
  }

  void _talkToCandidate(BuildContext context, ApplicationModel applicant) {
    final founderProfile = context.read<AppCubit>().state.currentProfile;
    if (founderProfile == null) return;
    
    // Chat ID format: studentId_founderId
    final chatId = "${applicant.studentId}_${founderProfile.uid}";
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          peerId: applicant.studentId,
          peerName: applicant.studentName,
          studentId: applicant.studentId,
          studentName: applicant.studentName,
          startupId: founderProfile.uid,
          startupName: applicant.startupName.isEmpty ? founderProfile.displayName : applicant.startupName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Candidate Submissions'),
            Text(
              widget.opportunityTitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: _service.streamApplicationsForOpportunity(widget.opportunityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AluTheme.primaryMaroon));
          }

          final applicants = snapshot.data ?? [];
          if (applicants.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No Submissions Yet',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    const Text('Student applications will display here in real time.'),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final applicant = applicants[index];
              
              Color statusColor = Colors.orange;
              if (applicant.status == 'Confirmed') {
                statusColor = AluTheme.accentSpruce;
              } else if (applicant.status == 'Interview Scheduled') {
                statusColor = AluTheme.primaryMaroon;
              } else if (applicant.status == 'Rejected') {
                statusColor = Colors.redAccent;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              applicant.studentName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              applicant.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(applicant.studentEmail, style: theme.textTheme.bodyMedium),
                      const Divider(height: 20, color: AluTheme.borderGrey),

                      if (applicant.studentBio.isNotEmpty) ...[
                        const Text(
                          'Candidate Bio:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(applicant.studentBio, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 12),
                      ],

                      if (applicant.studentSkills.isNotEmpty) ...[
                        const Text(
                          'Reported Skills:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(applicant.studentSkills, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 12),
                      ],

                      Text(
                        'Application Cover Note:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        applicant.coverNote.isEmpty ? 'No cover note submitted.' : applicant.coverNote,
                        style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),

                      if (applicant.studentGithubLink.isNotEmpty || applicant.studentPortfolioLink.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          children: [
                            if (applicant.studentGithubLink.isNotEmpty)
                              ActionChip(
                                avatar: const Icon(Icons.code, size: 14),
                                label: const Text('GitHub'),
                                onPressed: () async {
                                  final uri = Uri.parse(applicant.studentGithubLink);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                            if (applicant.studentPortfolioLink.isNotEmpty)
                              ActionChip(
                                avatar: const Icon(Icons.link, size: 14),
                                label: const Text('Portfolio'),
                                onPressed: () async {
                                  final uri = Uri.parse(applicant.studentPortfolioLink);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Interview details if scheduled
                      if (applicant.status == 'Interview Scheduled') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AluTheme.primaryMaroon.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AluTheme.primaryMaroon.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event, color: AluTheme.primaryMaroon, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Interview Scheduled Detail',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AluTheme.primaryMaroon.withOpacity(0.9)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Date: ${applicant.interviewDate} @ ${applicant.interviewTime}', style: const TextStyle(fontSize: 12)),
                              Text('Location/Link: ${applicant.interviewLink}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                              if (applicant.interviewNotes.isNotEmpty)
                                Text('Notes: ${applicant.interviewNotes}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Actions Controls Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Chat
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: AluTheme.primaryMaroon),
                            tooltip: 'Chat with Student',
                            onPressed: () => _talkToCandidate(context, applicant),
                          ),
                          const Spacer(),
                          
                          // Schedule Interview
                          OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month, size: 16),
                            label: const Text('Schedule'),
                            onPressed: () => _openScheduleDialog(context, applicant),
                          ),
                          const SizedBox(width: 8),

                          // Approve
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: AluTheme.accentSpruce),
                            onPressed: () async {
                              await context.read<AppCubit>().updateApplicationStatus(applicationId: applicant.id, status: 'Confirmed');
                            },
                            child: const Text('Accept'),
                          ),
                          const SizedBox(width: 6),

                          // Reject
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
                            onPressed: () async {
                              await context.read<AppCubit>().updateApplicationStatus(applicationId: applicant.id, status: 'Rejected');
                            },
                            child: const Text('Reject'),
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
