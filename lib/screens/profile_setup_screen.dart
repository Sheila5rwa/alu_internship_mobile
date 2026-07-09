import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_cubit.dart';

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
  String _role = 'student';

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AppCubit>();
    try {
      await cubit.completeProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skillsController.text.trim(),
        role: _role,
        githubLink: _githubController.text.trim(),
        portfolioLink: _portfolioController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Tell the community who you are', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('This helps startups and students discover the right match.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(labelText: 'Your role'),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'startup', child: Text('Startup founder')),
                  ],
                  onChanged: (value) => setState(() => _role = value ?? 'student'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Short bio'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(labelText: 'Skills (comma separated)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _githubController,
                  decoration: const InputDecoration(labelText: 'GitHub link (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _portfolioController,
                  decoration: const InputDecoration(labelText: 'Portfolio link (optional)'),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _submit, child: const Text('Continue')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
