import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../cubits/app_cubit.dart';
import '../models/opportunity.dart';
import '../models/startup_profile.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import 'applicant_review_screen.dart';

class StartupDashboardScreen extends StatefulWidget {
  const StartupDashboardScreen({super.key});

  @override
  State<StartupDashboardScreen> createState() => _StartupDashboardScreenState();
}

class _StartupDashboardScreenState extends State<StartupDashboardScreen> {
  final FirebaseService _service = FirebaseService();
  final _uuid = const Uuid();
  
  // Post opportunity text controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _roleController = TextEditingController();
  final _durationController = TextEditingController();
  final _skillsController = TextEditingController();
  
  String _opportunityType = 'Internship';
  String _workMode = 'Full-time';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _roleController.dispose();
    _durationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _postOpportunity(StartupProfile startup) async {
    if (_titleController.text.trim().isEmpty || 
        _descController.text.trim().isEmpty || 
        _roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out Title, Description and Role'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final opportunity = Opportunity(
      id: _uuid.v4(),
      startupId: startup.ownerId, // Set owner ID (matches student profile uid)
      startupName: startup.name,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      role: _roleController.text.trim(),
      category: startup.sector.isEmpty ? 'General' : startup.sector,
      location: startup.location,
      duration: _durationController.text.trim().isEmpty ? '3 Months' : _durationController.text.trim(),
      stipend: _workMode,
      opportunityType: _opportunityType,
      skills: _skillsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      isActive: true,
      createdAt: DateTime.now(),
    );

    await context.read<AppCubit>().createOpportunity(opportunity: opportunity);
    
    // Clear forms
    _titleController.clear();
    _descController.clear();
    _roleController.clear();
    _durationController.clear();
    _skillsController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opportunity posted successfully!'),
        backgroundColor: AluTheme.accentSpruce,
      ),
    );
  }

  Future<void> _toggleMockVerification(StartupProfile startup) async {
    final currentStatus = startup.status;
    final nextStatus = currentStatus == 'Approved' ? 'Pending' : 'Approved';
    
    await _service.simulateStartupVerification(startup.id, nextStatus);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification simulated: Status set to $nextStatus'),
        backgroundColor: nextStatus == 'Approved' ? AluTheme.accentSpruce : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.read<AppCubit>().state.currentProfile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Portal'),
        actions: [
          IconButton(
            onPressed: () => context.read<AppCubit>().signOut(),
            icon: const Icon(Icons.logout, color: AluTheme.primaryMaroon),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<StartupProfile?>(
          stream: _service.streamStartupByOwner(profile.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AluTheme.primaryMaroon));
            }

            final startup = snapshot.data;
            if (startup == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                      const SizedBox(height: 12),
                      const Text(
                        'Startup Profile Missing',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please sign out and complete your profile, selecting "Founder" as your role.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.read<AppCubit>().signOut(),
                        child: const Text('Sign Out'),
                      )
                    ],
                  ),
                ),
              );
            }

            final isVerified = startup.isVerified && startup.status == 'Approved';

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Startup Status Profile Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                startup.name,
                                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? AluTheme.accentSpruce.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                startup.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isVerified ? AluTheme.accentSpruce : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          startup.mission,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.domain, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Sector: ${startup.sector}', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 16),
                            const Icon(Icons.key, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Registry Code: ${startup.regCode}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const Divider(height: 24, color: AluTheme.borderGrey),
                        
                        // Simulator Control Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Simulation Controller:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AluTheme.primaryMaroon),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _toggleMockVerification(startup),
                              icon: Icon(isVerified ? Icons.lock : Icons.verified),
                              label: Text(isVerified ? 'Mock Revoke Status' : 'Mock Verify Startup'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isVerified ? Colors.redAccent : AluTheme.accentSpruce,
                                ),
                                foregroundColor: isVerified ? Colors.redAccent : AluTheme.accentSpruce,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Post Opportunity Panel (conditional on approval status)
                Text('Post Opportunities', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                
                if (!isVerified)
                  // Warning Alert
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Account Verification Required',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.orange.shade900),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Only validated ALU student entities are permitted to list internship posts. Use the simulator control above to mock-authorize this startup profile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                else
                  // Form Grid
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Internship Title'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Detailed Role Description',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _roleController,
                                  decoration: const InputDecoration(labelText: 'Job Category Target (e.g. Developer)'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _durationController,
                                  decoration: const InputDecoration(labelText: 'Duration (e.g. 3 months)'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _opportunityType,
                                  decoration: const InputDecoration(labelText: 'Type'),
                                  items: const [
                                    DropdownMenuItem(value: 'Internship', child: Text('Internship')),
                                    DropdownMenuItem(value: 'Part-time role', child: Text('Part-time')),
                                    DropdownMenuItem(value: 'Community join', child: Text('Community')),
                                  ],
                                  onChanged: (value) => setState(() => _opportunityType = value ?? 'Internship'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _workMode,
                                  decoration: const InputDecoration(labelText: 'Work Mode'),
                                  items: const [
                                    DropdownMenuItem(value: 'Full-time', child: Text('Full-time')),
                                    DropdownMenuItem(value: 'Part-time', child: Text('Part-time')),
                                    DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                                    DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                                  ],
                                  onChanged: (value) => setState(() => _workMode = value ?? 'Full-time'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _skillsController,
                            decoration: const InputDecoration(
                              labelText: 'Desired Skills (comma separated)',
                              hintText: 'e.g. Flutter, Dart, REST API',
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => _postOpportunity(startup),
                            style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                            child: const Text('Post Opportunity'),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // 3. Current active opportunities
                StreamBuilder<List<Opportunity>>(
                  stream: _service.streamMyOpportunities(profile.uid),
                  builder: (context, oppSnap) {
                    if (oppSnap.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    final lists = oppSnap.data ?? [];
                    
                    if (lists.isEmpty) {
                      return const Text('');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Job Postings', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ...lists.map((opp) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(opp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${opp.role} • ${opp.opportunityType}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Candidates Review Command
                                    IconButton(
                                      icon: const Icon(Icons.people_outline, color: AluTheme.primaryMaroon),
                                      tooltip: 'Review Candidates',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ApplicantReviewScreen(
                                              opportunityId: opp.id,
                                              opportunityTitle: opp.title,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Delete Command
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () async {
                                        await context.read<AppCubit>().deleteOpportunity(id: opp.id);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Opportunity deleted')),
                                          );
                                        }
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
            );
          },
        ),
      ),
    );
  }
}
