import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_cubit.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import 'chat_screen.dart';

class ChatHubScreen extends StatefulWidget {
  const ChatHubScreen({super.key});

  @override
  State<ChatHubScreen> createState() => _ChatHubScreenState();
}

class _ChatHubScreenState extends State<ChatHubScreen> {
  final FirebaseService _service = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.read<AppCubit>().state.currentProfile;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not found')),
      );
    }

    final isStudent = profile.role == 'student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox Messages'),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.streamMyChats(profile.uid, profile.role),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AluTheme.primaryMaroon));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No Conversations Yet',
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isStudent
                          ? 'Browse opportunities and tap "Message Founder" to initiate a dialog.'
                          : 'Applicants can message you or you can trigger messages from candidates review.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          final chats = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AluTheme.borderGrey),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat['id'] as String? ?? '';
              
              // Resolve metadata
              final studentId = chat['studentId'] as String? ?? '';
              final studentName = chat['studentName'] as String? ?? 'Student Candidate';
              final startupId = chat['startupId'] as String? ?? '';
              final startupName = chat['startupName'] as String? ?? 'Startup Team';
              
              final peerName = isStudent ? startupName : studentName;
              final lastMsg = chat['lastMessage'] as String? ?? '';
              
              // Extract date/time
              String formattedTime = '';
              try {
                if (chat['lastMessageAt'] != null) {
                  final dt = DateTime.parse(chat['lastMessageAt'] as String);
                  final diff = DateTime.now().difference(dt);
                  if (diff.inDays == 0) {
                    formattedTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  } else if (diff.inDays == 1) {
                    formattedTime = 'Yesterday';
                  } else {
                    formattedTime = '${dt.day}/${dt.month}';
                  }
                }
              } catch (_) {}

              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isStudent ? AluTheme.accentSpruce.withOpacity(0.1) : AluTheme.primaryMaroon.withOpacity(0.1),
                  child: Text(
                    peerName.isNotEmpty ? peerName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: isStudent ? AluTheme.accentSpruce : AluTheme.primaryMaroon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  peerName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  lastMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        peerId: isStudent ? startupId : studentId,
                        peerName: peerName,
                        studentId: studentId,
                        studentName: studentName,
                        startupId: startupId,
                        startupName: startupName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
