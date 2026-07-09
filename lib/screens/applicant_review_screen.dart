import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/app_cubit.dart';
import '../models/application_model.dart';
import '../services/firebase_service.dart';

class ApplicantReviewScreen extends StatelessWidget {
  ApplicantReviewScreen({super.key, required this.opportunityId, required this.opportunityTitle});

  final String opportunityId;
  final String opportunityTitle;
  final FirebaseService _service = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(opportunityTitle)),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: _service.streamApplicationsForOpportunity(opportunityId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final applicants = snapshot.data!;
          if (applicants.isEmpty) return const Center(child: Text('No applicants yet.'));
          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final applicant = applicants[index];
              return Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(applicant.studentName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                          Chip(label: Text(applicant.status)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(applicant.studentEmail),
                      if (applicant.studentSkills.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Skills: ${applicant.studentSkills}'),
                      ],
                      if (applicant.studentBio.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(applicant.studentBio),
                      ],
                      if (applicant.studentGithubLink.isNotEmpty || applicant.studentPortfolioLink.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (applicant.studentGithubLink.isNotEmpty)
                              ActionChip(
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
                      ],
                      const SizedBox(height: 8),
                      Text('Application note: ${applicant.coverNote.isEmpty ? 'No note provided' : applicant.coverNote}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () async {
                              await context.read<AppCubit>().updateApplicationStatus(applicationId: applicant.id, status: 'Confirmed');
                            },
                            child: const Text('Confirm'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
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
