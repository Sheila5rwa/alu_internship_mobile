import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_cubit.dart';
import '../services/firebase_service.dart';
import '../theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  
  // Startup Specific Fields
  final _startupNameController = TextEditingController();
  final _startupMissionController = TextEditingController();
  final _startupSectorController = TextEditingController();
  final _startupLocationController = TextEditingController();
  final _startupWebsiteController = TextEditingController();
  final _startupRegCodeController = TextEditingController();

  String _role = 'student';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startupLocationController.text = 'Remote';
    // Pre-populate display name from existing if available
    final currentProfile = context.read<AppCubit>().state.currentProfile;
    if (currentProfile != null) {
      _nameController.text = currentProfile.displayName;
      _role = currentProfile.role;
      _bioController.text = currentProfile.bio;
      _skillsController.text = currentProfile.skills;
      _githubController.text = currentProfile.githubLink;
      _portfolioController.text = currentProfile.portfolioLink;
      if (_role == 'startup') {
        _loadExistingStartup(currentProfile.uid);
      }
    }
  }

  Future<void> _loadExistingStartup(String ownerId) async {
    final service = FirebaseService();
    final startup = await service.getStartupByOwner(ownerId);
    if (startup != null && mounted) {
      setState(() {
        _startupNameController.text = startup.name;
        _startupMissionController.text = startup.mission;
        _startupSectorController.text = startup.sector;
        _startupLocationController.text = startup.location;
        _startupWebsiteController.text = startup.website;
        _startupRegCodeController.text = startup.regCode;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _startupNameController.dispose();
    _startupMissionController.dispose();
    _startupSectorController.dispose();
    _startupLocationController.dispose();
    _startupWebsiteController.dispose();
    _startupRegCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _submitting = true);

    final cubit = context.read<AppCubit>();
    try {
      await cubit.completeProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skillsController.text.trim(),
        role: _role,
        githubLink: _githubController.text.trim(),
        portfolioLink: _portfolioController.text.trim(),
        startupName: _startupNameController.text.trim(),
        startupMission: _startupMissionController.text.trim(),
        startupSector: _startupSectorController.text.trim(),
        startupLocation: _startupLocationController.text.trim(),
        startupWebsite: _startupWebsiteController.text.trim(),
        startupRegCode: _startupRegCodeController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AppCubit>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AluTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.badge_outlined, color: AluTheme.secondaryGold, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to the Hub!',
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Let’s set up your profile details. Startups and students will use this information to connect and collaborate.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Personal Profile Info', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.face_unlock_outlined, size: 20),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Your Primary Role',
                  prefixIcon: Icon(Icons.work_history_outlined, size: 20),
                ),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student (Seeking Internships)')),
                  DropdownMenuItem(value: 'startup', child: Text('Founder (Posting Opportunities)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _role = value);
                  }
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Short Professional Bio',
                  prefixIcon: Icon(Icons.notes, size: 20),
                  alignLabelWithHint: true,
                  hintText: 'Share your background, interests, or what you are building...',
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a short bio description' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills & Tools',
                  prefixIcon: Icon(Icons.construction_outlined, size: 20),
                  hintText: 'e.g. Flutter, Firebase, Python, UI/UX Design',
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please input at least one skill representation' : null,
              ),
              const SizedBox(height: 12),

              if (_role == 'student') ...[
                TextFormField(
                  controller: _githubController,
                  decoration: const InputDecoration(
                    labelText: 'GitHub / GitLab Profile Link (Optional)',
                    prefixIcon: Icon(Icons.code_outlined, size: 20),
                    hintText: 'https://github.com/yourusername',
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _portfolioController,
                  decoration: const InputDecoration(
                    labelText: 'Online Portfolio / LinkedIn URL (Optional)',
                    prefixIcon: Icon(Icons.link_outlined, size: 20),
                    hintText: 'https://linkedin.com/in/yourusername',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Conditional Startup Fields
              if (_role == 'startup') AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Divider(color: AluTheme.borderGrey, thickness: 1.5),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.rocket_launch_outlined, color: AluTheme.primaryMaroon, size: 22),
                        const SizedBox(width: 8),
                        Text('Startup Venture Registration', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Provide information about your startup. To register, your startup must possess a valid ALU student team registry card/code.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _startupNameController,
                      decoration: const InputDecoration(
                        labelText: 'Startup Venture Name',
                        prefixIcon: Icon(Icons.business_outlined, size: 20),
                      ),
                      validator: (value) => _role == 'startup' && (value == null || value.trim().isEmpty)
                          ? 'Venture name is required for founders'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _startupMissionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Mission Statement & Business Goal',
                        prefixIcon: Icon(Icons.lightbulb_outline, size: 20),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) => _role == 'startup' && (value == null || value.trim().isEmpty)
                          ? 'Provide a short mission statement'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _startupSectorController,
                      decoration: const InputDecoration(
                        labelText: 'Industry Sector',
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                        hintText: 'e.g. EdTech, FinTech, Agritech, SaaS',
                      ),
                      validator: (value) => _role == 'startup' && (value == null || value.trim().isEmpty)
                          ? 'Specify your startup sector'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: ['Remote', 'Hybrid', 'Onsite'].contains(_startupLocationController.text)
                          ? _startupLocationController.text
                          : 'Remote',
                      decoration: const InputDecoration(
                        labelText: 'Campus / Location',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                        DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                        DropdownMenuItem(value: 'Onsite', child: Text('Onsite')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _startupLocationController.text = value;
                          });
                        }
                      },
                      validator: (value) => _role == 'startup' && (value == null || value.trim().isEmpty)
                          ? 'Venture location is required'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _startupWebsiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website / Demo Pitch Deck Link (Optional)',
                        prefixIcon: Icon(Icons.public, size: 20),
                        hintText: 'https://my-startup.com',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _startupRegCodeController,
                      decoration: const InputDecoration(
                        labelText: 'ALU Organization registry status code',
                        prefixIcon: Icon(Icons.verified_user_outlined, size: 20),
                        hintText: 'e.g. ALUSG-2026-88',
                      ),
                      validator: (value) {
                        if (_role == 'startup') {
                          if (value == null || value.trim().isEmpty) {
                            return 'ALU registry reference code remains mandatory';
                          }
                          if (!value.toUpperCase().startsWith('ALU')) {
                            return 'Please enter a valid format starting with ALU- (e.g. ALU-GRP-XXX)';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save & Enter Dashboard'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
