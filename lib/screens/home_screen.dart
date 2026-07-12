import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_cubit.dart';
import '../models/application_model.dart';
import '../models/opportunity.dart';
import '../models/startup_profile.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  String _search = '';
  bool _showOnlyBookmarks = false;

  int _calculateMatchPercentage(List<String> requiredSkills, String studentSkillsRaw) {
    if (requiredSkills.isEmpty) return 100;
    if (studentSkillsRaw.isEmpty) return 0;
    
    final req = requiredSkills
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();
    if (req.isEmpty) return 100;

    final student = studentSkillsRaw
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();

    final intersection = req.intersection(student);
    return ((intersection.length / req.length) * 100).round();
  }

  Future<void> _apply(Opportunity opportunity) async {
    final cubit = context.read<AppCubit>();
    final profile = cubit.state.currentProfile;
    if (profile == null) return;

    final coverNoteController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Opportunity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Applying to: ${opportunity.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: coverNoteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Cover Note / Why you are a fit',
                alignLabelWithHint: true,
                hintText: 'Discuss relevant skills and motivation...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit Application'),
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Application submitted successfully!'),
        backgroundColor: AluTheme.accentSpruce,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startChat(String startupOwnerId, String startupName) {
    final studentProfile = context.read<AppCubit>().state.currentProfile;
    if (studentProfile == null) return;
    
    final chatId = "${studentProfile.uid}_$startupOwnerId";
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          peerId: startupOwnerId,
          peerName: startupName,
          studentId: studentProfile.uid,
          studentName: studentProfile.displayName,
          startupId: startupOwnerId,
          startupName: startupName,
        ),
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

    final bookmarkedIds = profile.bookmarkedOpportunityIds;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.school, color: AluTheme.primaryMaroon, size: 28),
            const SizedBox(width: 8),
            Text(
              'ALU Internship Hub',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AppCubit>().signOut(),
            icon: const Icon(Icons.logout, color: AluTheme.primaryMaroon),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All vs Bookmarked)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('All Postings')),
                    selected: !_showOnlyBookmarks,
                    onSelected: (selected) {
                      if (selected) setState(() => _showOnlyBookmarks = false);
                    },
                    selectedColor: AluTheme.primaryMaroon,
                    labelStyle: TextStyle(
                      color: !_showOnlyBookmarks ? Colors.white : AluTheme.darkSlate,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('My Bookmarks')),
                    selected: _showOnlyBookmarks,
                    onSelected: (selected) {
                      if (selected) setState(() => _showOnlyBookmarks = true);
                    },
                    selectedColor: AluTheme.primaryMaroon,
                    labelStyle: TextStyle(
                      color: _showOnlyBookmarks ? Colors.white : AluTheme.darkSlate,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: AluTheme.primaryMaroon),
                labelText: 'Search opportunities, titles or tags...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value.toLowerCase()),
            ),
          ),

          // Streamed Opportunity List
          Expanded(
            child: StreamBuilder<List<Opportunity>>(
              stream: _service.streamOpportunities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AluTheme.primaryMaroon));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No opportunities posted yet. Startup founders will post soon!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // Filter list
                var opportunities = snapshot.data!;
                if (_showOnlyBookmarks) {
                  opportunities = opportunities
                      .where((item) => bookmarkedIds.contains(item.id))
                      .toList();
                }

                // Filter search
                opportunities = opportunities
                    .where((item) =>
                        item.title.toLowerCase().contains(_search) ||
                        item.role.toLowerCase().contains(_search) ||
                        item.category.toLowerCase().contains(_search) ||
                        item.skills.any((sk) => sk.toLowerCase().contains(_search)))
                    .toList();

                if (opportunities.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _showOnlyBookmarks
                                ? 'No bookmarked items found.'
                                : 'No opportunities match your search query.',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: opportunities.length,
                  itemBuilder: (context, index) {
                    final opportunity = opportunities[index];
                    final isBookmarked = bookmarkedIds.contains(opportunity.id);

                    // Compute match percentage
                    final matchPct = _calculateMatchPercentage(opportunity.skills, profile.skills);

                    // Color based on skill match
                    Color matchColor = Colors.grey.shade600;
                    IconData matchIcon = Icons.info_outline;
                    if (matchPct >= 70) {
                      matchColor = AluTheme.accentSpruce;
                      matchIcon = Icons.stars_rounded;
                    } else if (matchPct >= 40) {
                      matchColor = const Color(0xFFD4AF37); // Dark gold
                      matchIcon = Icons.bolt;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Bookmark row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opportunity.title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // FutureBuilder to load verification details for the startup
                                      FutureBuilder<StartupProfile?>(
                                        future: _service.getStartupByOwner(opportunity.startupId),
                                        builder: (context, startupSnap) {
                                          final isVerified = startupSnap.data?.isVerified ?? false;
                                          final status = startupSnap.data?.status ?? 'Pending';
                                          
                                          if (isVerified && status == 'Approved') {
                                            return const Row(
                                              children: [
                                                Icon(Icons.verified, color: AluTheme.accentSpruce, size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Verified ALU Startup',
                                                  style: TextStyle(
                                                    color: AluTheme.accentSpruce,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return const Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                                              SizedBox(width: 4),
                                              Text(
                                                'Validation Pending',
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: AluTheme.primaryMaroon,
                                  ),
                                  onPressed: () async {
                                    await context.read<AppCubit>().toggleBookmark(opportunity.id);
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: AluTheme.borderGrey),

                            Text(
                              opportunity.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                            ),
                            const SizedBox(height: 12),

                            // Display details chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                Chip(
                                  label: Text(opportunity.opportunityType),
                                  backgroundColor: Colors.grey.shade100,
                                  side: BorderSide.none,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Chip(
                                  label: Text(opportunity.duration),
                                  backgroundColor: Colors.grey.shade100,
                                  side: BorderSide.none,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Chip(
                                  label: Text('⚡ ${opportunity.stipend}'),
                                  backgroundColor: Colors.grey.shade100,
                                  side: BorderSide.none,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Chip(
                                  label: Text('📍 ${opportunity.location}'),
                                  backgroundColor: Colors.grey.shade100,
                                  side: BorderSide.none,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Skills list
                            Text(
                              'Required: ${opportunity.skills.join(', ')}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AluTheme.darkSlate),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Bottom Action row
                            Row(
                              children: [
                                // Match indicator chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: matchColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(matchIcon, color: matchColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$matchPct% Match',
                                        style: TextStyle(
                                          color: matchColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                
                                // Text button for chat
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline, color: AluTheme.primaryMaroon),
                                  tooltip: 'Message Founder',
                                  onPressed: () => _startChat(opportunity.startupId, opportunity.startupName),
                                ),
                                
                                const SizedBox(width: 4),
                                
                                // Apply button
                                OutlinedButton(
                                  onPressed: () => _apply(opportunity),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Apply'),
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
