import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/app_cubit.dart';
import '../models/application_model.dart';
import '../models/opportunity.dart';
import '../models/startup_profile.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  String _search = '';

  Future<void> _apply(Opportunity opportunity) async {
    final cubit = context.read<AppCubit>();
    final profile = cubit.state.currentProfile;
    if (profile == null) return;

    final coverNoteController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for this opportunity'),
        content: TextField(
          controller: coverNoteController,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Tell them why you are a fit'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit application'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final application = ApplicationModel(
      id: '',
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      studentId: profile.uid,
      studentName: profile.displayName,
      studentEmail: profile.email,
      studentBio: profile.bio,
      studentSkills: profile.skills,
      studentGithubLink: profile.githubLink,
      studentPortfolioLink: profile.portfolioLink,
      startupId: opportunity.startupId,
      startupName: opportunity.startupName,
      opportunityType: opportunity.opportunityType,
      coverNote: coverNoteController.text.trim(),
      status: 'Pending',
      appliedAt: DateTime.now(),
    );

    await cubit.submitApplication(application: application);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application submitted successfully')));
  }

  Future<void> _showStartupDetails(StartupProfile startup) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(startup.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(startup.mission),
            const SizedBox(height: 8),
            Text('Sector: ${startup.sector}'),
            Text('Location: ${startup.location}'),
            if (startup.website.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(startup.website);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Open website'),
              ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALU Internship Hub'),
        actions: [
          IconButton(onPressed: () => context.read<AppCubit>().signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search opportunities',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Opportunity>>(
              stream: _service.streamOpportunities(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final opportunities = snapshot.data!
                    .where((item) => item.title.toLowerCase().contains(_search) || item.role.toLowerCase().contains(_search) || item.category.toLowerCase().contains(_search))
                    .toList();
                if (opportunities.isEmpty) {
                  return const Center(child: Text('No opportunities yet. Check back soon.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: opportunities.length,
                  itemBuilder: (context, index) {
                    final opportunity = opportunities[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(opportunity.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                                  child: Text(opportunity.category, style: const TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(opportunity.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(label: Text('Role: ${opportunity.role}')),
                                Chip(label: Text('Type: ${opportunity.opportunityType}')),
                                Chip(label: Text('Location: ${opportunity.location}')),
                                Chip(label: Text('Duration: ${opportunity.duration}')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Skills: ${opportunity.skills.join(', ')}'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: Text('Posted by ${opportunity.startupName}')),
                                TextButton(
                                  onPressed: () async {
                                    final startup = await _service.getStartupByOwner(opportunity.startupId);
                                    if (startup != null && mounted) {
                                      _showStartupDetails(startup);
                                    }
                                  },
                                  child: const Text('View startup'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(onPressed: () => _apply(opportunity), child: const Text('Apply')),
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
