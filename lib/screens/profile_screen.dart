import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/app_cubit.dart';
import '../models/startup_profile.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _service = FirebaseService();

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

  Future<void> _toggleVerification(StartupProfile startup) async {
    final nextStatus = startup.status == 'Approved' ? 'Pending' : 'Approved';
    await _service.simulateStartupVerification(startup.id, nextStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification updated to: $nextStatus'),
          backgroundColor: nextStatus == 'Approved' ? AluTheme.accentSpruce : Colors.orange,
        ),
      );
    }
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

    final isStudent = profile.role == 'student';
    final initials = profile.displayName.isNotEmpty
        ? profile.displayName.split(' ').map((e) => e[0]).take(2).join('').toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Sleek Gradient Header Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Curved Gradient Background Container
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AluTheme.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles overlay
                      Positioned(
                        right: -50,
                        top: -50,
                        child: CircleAvatar(
                          radius: 120,
                          backgroundColor: Colors.white.withAlpha(15),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white.withAlpha(8),
                        ),
                      ),
                      // Custom Transparent AppBar inside Stack
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Profile',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                                tooltip: 'Edit Profile Details',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Absolute Floating Identity Card
                Positioned(
                  top: 135,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withAlpha(15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Hexagon avatar wrapper
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AluTheme.primaryMaroon.withAlpha(30),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: const Color(0xFFFAF5F5),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AluTheme.primaryMaroon,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AluTheme.darkSlate,
                                      fontFamily: 'Outfit',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.email,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Account Role',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: isStudent ? AluTheme.spruceGradient : AluTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isStudent ? 'Student Developer' : 'Startup Founder',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Padding to offset from absolute positioned floating card height
            const SizedBox(height: 115),

            // 2. Profile Details & Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // About Me Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin_outlined, color: AluTheme.primaryMaroon, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'About Me',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AluTheme.darkSlate,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.bio.isNotEmpty ? profile.bio : 'No personal introduction specified yet. Click edit to configure.',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Skills & Knowledge Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology_outlined, color: AluTheme.primaryMaroon, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Skills & Competencies',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AluTheme.darkSlate,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        profile.skills.trim().isEmpty
                            ? const Text(
                                'No listed skills. Click edit to represent your abilities.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              )
                            : Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: profile.skills
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .map((skill) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: Text(
                                            skill,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF334155),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Dynamic Section (Student Links OR Founder Registry)
                  if (isStudent) ...[
                    // Student Links
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.link_outlined, color: AluTheme.primaryMaroon, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Professional Links',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AluTheme.darkSlate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _linkTile(
                            context: context,
                            title: 'GitHub Profile',
                            url: profile.githubLink,
                            icon: Icons.code,
                            accentColor: Colors.black87,
                          ),
                          const SizedBox(height: 8),
                          _linkTile(
                            context: context,
                            title: 'Portfolio / LinkedIn',
                            url: profile.portfolioLink,
                            icon: Icons.public,
                            accentColor: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Founder registry card based on live Firestore updates
                    StreamBuilder<StartupProfile?>(
                      stream: _service.streamStartupByOwner(profile.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox();
                        }
                        final startup = snapshot.data;
                        if (startup == null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: const Text('Add startup profile information to see it here.'),
                          );
                        }

                        final isVerified = startup.isVerified;
                        final status = startup.status;

                        Color statusColor = Colors.orange;
                        IconData statusIcon = Icons.pending_actions_outlined;
                        if (status == 'Approved') {
                          statusColor = AluTheme.accentSpruce;
                          statusIcon = Icons.verified;
                        } else if (status == 'Rejected') {
                          statusColor = Colors.redAccent;
                          statusIcon = Icons.cancel_outlined;
                        }

                        return Column(
                          children: [
                            // Startup Main Specs Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.rocket_launch_outlined, color: AluTheme.primaryMaroon, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Startup Venture Profile',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AluTheme.darkSlate,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withAlpha(20),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: statusColor, width: 1.2),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(statusIcon, color: statusColor, size: 13),
                                            const SizedBox(width: 4),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    startup.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AluTheme.primaryMaroon,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    startup.mission,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  const SizedBox(height: 16),

                                  _richInfoRow('Industry Domain', startup.sector, Icons.work_outline),
                                  _richInfoRow('Setup Type', startup.location, Icons.location_on_outlined),
                                  _richInfoRow('ALU Registry code', startup.regCode, Icons.badge_outlined),
                                  if (startup.website.isNotEmpty)
                                    _richInfoRow(
                                      'Website / Deck Link',
                                      startup.website,
                                      Icons.rocket_outlined,
                                      onTap: () => _launchUrl(startup.website),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Interactive Review Simulation Console
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF5F5), // Light warm maroon accent backgrounds
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AluTheme.primaryMaroon.withAlpha(20)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.admin_panel_settings_outlined, color: AluTheme.primaryMaroon, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Registry Simulation Console',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AluTheme.primaryMaroon,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'simulate verification status updates instantly in this testing environment.',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    onPressed: () => _toggleVerification(startup),
                                    icon: Icon(isVerified ? Icons.no_accounts_outlined : Icons.verified_user_outlined, size: 16),
                                    label: Text(
                                      status == 'Approved' 
                                          ? 'Demote to Pending Verification'
                                          : 'Approve registry validation status'
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: status == 'Approved' ? Colors.orange : AluTheme.accentSpruce,
                                      elevation: 0,
                                      side: BorderSide(
                                        color: status == 'Approved' ? Colors.orange.withAlpha(100) : AluTheme.accentSpruce.withAlpha(100),
                                      ),
                                      minimumSize: const Size(double.infinity, 44),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 4. Log out Action
                  OutlinedButton.icon(
                    onPressed: () => context.read<AppCubit>().signOut(),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign Out of Application'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFF87171), width: 1.2),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkTile({
    required BuildContext context,
    required String title,
    required String url,
    required IconData icon,
    required Color accentColor,
  }) {
    final hasUrl = url.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: accentColor.withAlpha(15),
          child: Icon(icon, color: accentColor, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AluTheme.darkSlate)),
        subtitle: Text(
          hasUrl ? url : 'Not configure yet (Optional)',
          style: TextStyle(
            fontSize: 12,
            color: hasUrl ? const Color(0xFF475569) : const Color(0xFF94A3B8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: hasUrl
            ? IconButton(
                icon: const Icon(Icons.open_in_new, color: AluTheme.primaryMaroon, size: 16),
                onPressed: () => _launchUrl(url),
              )
            : const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 16),
      ),
    );
  }

  Widget _richInfoRow(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: onTap != null ? FontWeight.bold : FontWeight.w500,
                  color: onTap != null ? AluTheme.primaryMaroon : const Color(0xFF1E293B),
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
