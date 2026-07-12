import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_cubit.dart';
import '../services/firebase_service.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String peerId;
  final String peerName;
  final String studentId;
  final String studentName;
  final String startupId;
  final String startupName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.peerId,
    required this.peerName,
    required this.studentId,
    required this.studentName,
    required this.startupId,
    required this.startupName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final profile = context.read<AppCubit>().state.currentProfile;
    if (profile == null) return;

    await _service.sendMessage(
      chatId: widget.chatId,
      senderId: profile.uid,
      senderName: profile.displayName,
      content: text,
      studentId: widget.studentId,
      studentName: widget.studentName,
      startupId: widget.startupId,
      startupName: widget.startupName,
    );
    
    // Tiny delay to allow state stream update, then scroll
    Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AppCubit>().state.currentProfile;
    final currentUserId = profile?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AluTheme.primaryMaroon.withOpacity(0.1),
              child: Text(
                widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 14, color: AluTheme.primaryMaroon, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Active Ecosystem chat',
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message stream list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _service.streamMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AluTheme.primaryMaroon));
                }
                
                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mark_unread_chat_alt, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text(
                            'Start the Conversation',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Send a friendly message about opportunity details, skills required, or scheduled dates.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Trigger scroll to bottom on load
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final senderId = message['senderId'] as String? ?? '';
                    final content = message['content'] as String? ?? '';
                    final isMe = senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? AluTheme.primaryMaroon : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            )
                          ],
                          border: isMe ? null : Border.all(color: AluTheme.borderGrey),
                        ),
                        child: Text(
                          content,
                          style: TextStyle(
                            color: isMe ? Colors.white : AluTheme.darkSlate,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Input field row
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AluTheme.borderGrey, width: 1.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AluTheme.primaryMaroon),
                      ),
                    ),
                    onFieldSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AluTheme.primaryMaroon,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _send,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
