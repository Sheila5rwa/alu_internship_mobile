import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../cubits/app_cubit.dart';
import '../models/opportunity.dart';
import '../models/startup_profile.dart';
import '../screens/applicant_review_screen.dart';
import '../services/firebase_service.dart';

class StartupDashboardScreen extends StatefulWidget {
  const StartupDashboardScreen({super.key});

  @override
  State<StartupDashboardScreen> createState() => _StartupDashboardScreenState();
}

class _StartupDashboardScreenState extends State<StartupDashboardScreen> {
  final FirebaseService _service = FirebaseService();
  final _uuid = const Uuid();
  final _startupNameController = TextEditingController();
  String _workMode = 'Full-time';
  final _missionController = TextEditingController();
  final _sectorController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _roleController = TextEditingController();
  final _durationController = TextEditingController();
  final _skillsController = TextEditingController();
  String _opportunityType = 'Internship';

  @override
  void dispose() {
    _startupNameController.dispose();
    _missionController.dispose();
    _sectorController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _roleController.dispose();
    _durationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _createStartup() async {
    final cubit = context.read<AppCubit>();
    final profile = cubit.state.currentProfile;
    if (profile == null) return;
    final startup = StartupProfile(
      id: _uuid.v4(),
      ownerId: profile.uid,
      name: _startupNameController.text.trim(),
      mission: _missionController.text.trim(),
      sector: _sectorController.text.trim(),
      location: _locationController.text.trim(),
      website: _websiteController.text.trim(),
      isVerified: true,
      createdAt: DateTime.now(),
    );
    await cubit.createStartup(startup: startup);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Startup profile created')));
  }

  Future<void> _postOpportunity() async {
    final cubit = context.read<AppCubit>();
    final profile = cubit.state.currentProfile;
    if (profile == null) return;
    final opportunity = Opportunity(
      id: _uuid.v4(),
      startupId: profile.uid,
      startupName: _startupNameController.text.trim().isEmpty ? 'Your Startup' : _startupNameController.text.trim(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      role: _roleController.text.trim(),
      category: _sectorController.text.trim().isEmpty ? 'General' : _sectorController.text.trim(),
      location: _locationController.text.trim(),
      duration: _durationController.text.trim(),
      stipend: _workMode,
      opportunityType: _opportunityType,
      skills: _skillsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      isActive: true,
      createdAt: DateTime.now(),
    );
    await cubit.createOpportunity(opportunity: opportunity);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opportunity posted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Dashboard'),
        actions: [
          IconButton(onPressed: () => context.read<AppCubit>().signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Create your startup profile', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _startupNameController, decoration: const InputDecoration(labelText: 'Startup name')),
            TextField(controller: _missionController, decoration: const InputDecoration(labelText: 'Mission')),
            TextField(controller: _sectorController, decoration: const InputDecoration(labelText: 'Sector')),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
            TextField(controller: _websiteController, decoration: const InputDecoration(labelText: 'Website')),
            const SizedBox(height: 8),
            FilledButton(onPressed: _createStartup, child: const Text('Save startup profile')),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('Post an internship opportunity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Opportunity title')),
            TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: _roleController, decoration: const InputDecoration(labelText: 'Role')),
            TextField(controller: _durationController, decoration: const InputDecoration(labelText: 'Duration')),
            DropdownButtonFormField<String>(
              initialValue: _opportunityType,
              decoration: const InputDecoration(labelText: 'Opportunity type'),
              items: const [
                DropdownMenuItem(value: 'Internship', child: Text('Internship')),
                DropdownMenuItem(value: 'Part-time role', child: Text('Part-time role')),
                DropdownMenuItem(value: 'Community join', child: Text('Community join')),
                DropdownMenuItem(value: 'Job', child: Text('Job')),
              ],
              onChanged: (value) => setState(() => _opportunityType = value ?? 'Internship'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _workMode,
              decoration: const InputDecoration(labelText: 'Work mode'),
              items: const [
                DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                DropdownMenuItem(value: 'Remote', child: Text('Remote')),
              ],
              onChanged: (value) => setState(() => _workMode = value ?? 'Full-time'),
            ),
            const SizedBox(height: 8),
            TextField(controller: _skillsController, decoration: const InputDecoration(labelText: 'Skills (comma separated)')),
            const SizedBox(height: 8),
            FilledButton(onPressed: _postOpportunity, child: const Text('Post opportunity')),
            const SizedBox(height: 24),
            StreamBuilder<List<Opportunity>>(
              stream: _service.streamMyOpportunities(context.read<AppCubit>().state.currentProfile?.uid ?? ''),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Text('No opportunities posted yet.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your posted opportunities', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...items.map((item) => Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text('${item.role} • ${item.opportunityType}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.people_outline),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ApplicantReviewScreen(opportunityId: item.id, opportunityTitle: item.title),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await context.read<AppCubit>().deleteOpportunity(id: item.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
