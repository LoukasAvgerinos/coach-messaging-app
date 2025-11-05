import 'package:flutter/material.dart';
import '/services/chat/chat_services.dart';
import '/services/auth/auth_service.dart';
import '/services/notification_service.dart'; //  Import notification service
import 'package:audioplayers/audioplayers.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services instances
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  // Track last message count to detect new messages
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // send message method
  void sendMessage() async {
    final String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId, message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Display messages
            Expanded(child: _buildMessageList()),

            // User input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  /// build message list
  Widget _buildMessageList() {
    String senderID = _authService.currentUser!.uid;

    return StreamBuilder(
      stream: _chatService.getMessages(senderID, widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        // Detect new messages and play sound
        /* if (messages.isNotEmpty) {
          // Check if we got a new message
          if (messages.length > _lastMessageCount) {
            // Get the newest message (first in list since we likely reverse it)
            final newestMessage = messages.first.data() as Map<String, dynamic>;
            final isFromOtherUser = newestMessage['senderId'] != senderID;

            // Only play sound if message is from the other user (not from me)
            if (isFromOtherUser && _lastMessageCount > 0) {
              _notificationService.playNotificationSound();
            }
          }
          _lastMessageCount = messages.length;
        }*/

        // Only play sound for NEW messages from OTHER user
        if (messages.isNotEmpty && messages.length > _lastMessageCount) {
          // Get the newest message
          final newestMessage = messages.first.data() as Map<String, dynamic>;
          final isFromOtherUser = newestMessage['senderId'] != senderID;

          // Only play sound if:
          // 1. Message is from OTHER user (not me)
          // 2. This isn't the first load (_lastMessageCount > 0)
          if (isFromOtherUser && _lastMessageCount > 0) {
            print('🔊 Playing sound for received message');
            AudioPlayer().play(AssetSource('sounds/new_message.mp3'));
          } else if (!isFromOtherUser) {
            print('✉️ Message sent by me - no sound');
          }

          // Update message count
          _lastMessageCount = messages.length;
        } else if (messages.isNotEmpty && _lastMessageCount == 0) {
          // First load - just set the count, don't play sound
          _lastMessageCount = messages.length;
          print('📊 Initial load: ${messages.length} messages');
        }

        return ListView.builder(
          reverse: true, //  NEW: Show newest messages at bottom
          padding: const EdgeInsets.all(10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // Since reverse: true, we need to reverse the index
            final message = messages[messages.length - 1 - index];
            final messageData = message.data() as Map<String, dynamic>;
            final isSentByCurrentUser = messageData['senderId'] == senderID;

            return Align(
              alignment: isSentByCurrentUser
                  ? Alignment
                        .centerRight // Sender: RIGHT
                  : Alignment.centerLeft, // Receiver: LEFT
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.7, // Max 70% width
                ),
                decoration: BoxDecoration(
                  color: isSentByCurrentUser
                      ? Theme.of(context)
                            .colorScheme
                            .primary //  Use theme color
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isSentByCurrentUser
                        ? const Radius.circular(16)
                        : const Radius.circular(0), // Tail on left for receiver
                    bottomRight: isSentByCurrentUser
                        ? const Radius.circular(0) // Tail on right for sender
                        : const Radius.circular(16),
                  ),
                ),
                child: Text(
                  messageData['message'] ?? '',
                  style: TextStyle(
                    color: isSentByCurrentUser
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // build message input
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => sendMessage(), // Send on Enter key
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
