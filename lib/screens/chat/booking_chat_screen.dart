import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/supabase_service.dart';
import '../../state/supabase_providers.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class BookingChatScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const BookingChatScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingChatScreen> createState() => _BookingChatScreenState();
}

class _BookingChatScreenState extends ConsumerState<BookingChatScreen> {
  final _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      ref.read(supabaseRepoProvider).sendMessage(
        widget.bookingId,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(chatMessagesProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.bookingId.substring(0, 8)}')),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) => ListView.builder(
                padding: const EdgeInsets.all(8),
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[messages.length - 1 - index];
                  final isMe = msg.senderId == ref.read(supabaseClientProvider).auth.currentUser?.id;
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primaryOrange : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.message,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('HH:mm').format(msg.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: AppColors.primaryOrange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
