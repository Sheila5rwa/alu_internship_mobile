import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/app_cubit.dart';
import '../models/application_model.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import 'chat_screen.dart';

class StartupApplicantsScreen extends StatefulWidget {
  const StartupApplicantsScreen({super.key});

  @override
  State<StartupApplicantsScreen> createState() => _StartupApplicantsScreenState();
}

class _StartupApplicantsScreenState extends State<StartupApplicantsScreen> {
  final FirebaseService _service = FirebaseService();
  String _selectedFilter = 'All';

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $urlString')),
        );
      }
    }
  }

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
    final profile = context.watch<AppCubit>().state.currentProfile;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AluTheme.primaryMaroon)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Candidates'),
      ),
      body: Column(
        children: [
          // 1. Horizontal Status Filters Header
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Pending', 'Shortlisted', 'Interview Scheduled', 'Confirmed', 'Hired', 'Rejected'].map((status) {
                final isSelected = _selectedFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (value) {
                      if (value) {
                        setState(() => _selectedFilter = status);
                      }
                    },
                    selectedColor: AluTheme.primaryMaroon,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. Live Submissions List
          Expanded(
            child: StreamBuilder<List<ApplicationModel>>(
              stream: _service.streamApplicationsForStartup(profile.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AluTheme.primaryMaroon));
                }

                final allApplications = snapshot.data ?? [];
                
                // Perform local status filtering
                final applications = allApplications.where((app) {
                  if (_selectedFilter == 'All') return true;
                  return app.status == _selectedFilter;
                }).toList();

                if (applications.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.badge_outlined, size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No Candidates Found',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedFilter == 'All' 
                                ? 'No applications have been sent to your posts yet.'
                                : 'No submissions found under the status: $_selectedFilter',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final app = applications[index];

                    Color statusColor = Colors.grey;
                    if (app.status == 'Pending') {
                      statusColor = Colors.orange;
                    } else if (app.status == 'Shortlisted') {
                      statusColor = AluTheme.secondaryGold;
                    } else if (app.status == 'Interview Scheduled') {
                      statusColor = AluTheme.primaryMaroon;
                    } else if (app.status == 'Confirmed') {
                      statusColor = AluTheme.accentSpruce;
                    } else if (app.status == 'Hired') {
                      statusColor = Colors.blueAccent;
                    } else if (app.status == 'Rejected') {
                      statusColor = Colors.redAccent;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Headline Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.studentName,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Applied for: ${app.opportunityTitle}',
                                        style: const TextStyle(fontSize: 12, color: AluTheme.primaryMaroon, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor, width: 1),
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
                            const SizedBox(height: 6),
                            Text(app.studentEmail, style: theme.textTheme.bodyMedium),
                            const Divider(height: 20, color: AluTheme.borderGrey),

                            if (app.studentBio.isNotEmpty) ...[
                              const Text('Candidate Bio:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(app.studentBio, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 12),
                            ],

                            if (app.studentSkills.isNotEmpty) ...[
                              const Text('Key Skills:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(app.studentSkills, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 12),
                            ],

                            const Text('Cover Note:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              app.coverNote.isEmpty ? 'No cover note submitted.' : app.coverNote,
                              style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 12),

                            // Interactive Portfolio chips
                            if (app.studentGithubLink.isNotEmpty || app.studentPortfolioLink.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (app.studentGithubLink.isNotEmpty)
                                    ActionChip(
                                      avatar: const Icon(Icons.code, size: 14),
                                      label: const Text('GitHub'),
                                      onPressed: () => _launchUrl(app.studentGithubLink),
                                    ),
                                  if (app.studentPortfolioLink.isNotEmpty)
                                    ActionChip(
                                      avatar: const Icon(Icons.link, size: 14),
                                      label: const Text('Portfolio'),
                                      onPressed: () => _launchUrl(app.studentPortfolioLink),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interview layout if set
                            if (app.status == 'Interview Scheduled') ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AluTheme.primaryMaroon.withAlpha(15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AluTheme.primaryMaroon.withAlpha(30)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.event, color: AluTheme.primaryMaroon, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Schedule details',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AluTheme.primaryMaroon),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Date: ${app.interviewDate} @ ${app.interviewTime}', style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 2),
                                    GestureDetector(
                                      onTap: () => _launchUrl(app.interviewLink),
                                      child: Text(
                                        'Meeting link: ${app.interviewLink}',
                                        style: const TextStyle(fontSize: 12, color: Colors.blue, decoration: TextDecoration.underline),
                                      ),
                                    ),
                                    if (app.interviewNotes.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text('Notes: ${app.interviewNotes}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Workflow Action Bar Buttons
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline, color: AluTheme.primaryMaroon),
                                  tooltip: 'Chat with Student',
                                  onPressed: () => _talkToCandidate(context, app),
                                ),
                                const Spacer(),

                                // Pop Up Context Actions
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade700),
                                  tooltip: 'Change Status',
                                  onSelected: (status) async {
                                    if (status == 'Interview') {
                                      await _openScheduleDialog(context, app);
                                    } else {
                                      await context.read<AppCubit>().updateApplicationStatus(applicationId: app.id, status: status);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'Pending', child: Text('Mark as Pending')),
                                    const PopupMenuItem(value: 'Shortlisted', child: Text('Shortlist Candidate')),
                                    const PopupMenuItem(value: 'Interview', child: Text('Schedule Interview...')),
                                    const PopupMenuItem(value: 'Confirmed', child: Text('Accept Candidate')),
                                    const PopupMenuItem(value: 'Hired', child: Text('Hire Candidate')),
                                    const PopupMenuItem(value: 'Rejected', child: Text('Reject Candidate')),
                                  ],
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
          ),
        ],
      ),
    );
  }
}
