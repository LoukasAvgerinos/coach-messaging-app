import 'package:flutter/material.dart';
import '/services/chat/chat_services.dart';
import '/services/auth/auth_service.dart';
import '/services/notification_service.dart';

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
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  // ⭐ THIS VARIABLE MUST BE HERE!
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  /// build message list - ULTRA DEBUG VERSION
  Widget _buildMessageList() {
    String senderID = _authService.currentUser!.uid;

    print('═══════════════════════════════════════');
    print('🔍 [STREAM] Building message list...');
    print('👤 [STREAM] My User ID: $senderID');
    print('═══════════════════════════════════════');

    return StreamBuilder(
      stream: _chatService.getMessages(senderID, widget.receiverId),
      builder: (context, snapshot) {
        print('\n--- STREAM BUILDER FIRED ---');
        print('Connection state: ${snapshot.connectionState}');

        if (snapshot.hasError) {
          print('❌ ERROR: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ WAITING for data...');
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;
        print('📊 Total messages: ${messages.length}');
        print('📊 Last message count: $_lastMessageCount');

        // DETECTION LOGIC WITH LOTS OF DEBUG
        if (messages.isNotEmpty) {
          print('\n🔍 DETECTION CHECK:');
          print('   Messages empty? NO (${messages.length} messages)');
          print(
            '   Messages.length (${messages.length}) > _lastMessageCount ($_lastMessageCount)? ${messages.length > _lastMessageCount}',
          );

          if (messages.length > _lastMessageCount) {
            print('\n   ✅ NEW MESSAGE DETECTED!');

            final newestMessage = messages.last.data() as Map<String, dynamic>;
            final messageSenderId = newestMessage['senderId'];
            final messageText = newestMessage['message'];

            print('   📨 Newest message: "$messageText"');
            print('   👤 Message sender ID: $messageSenderId');
            print('   👤 My ID: $senderID');
            print('   🔍 From other user? ${messageSenderId != senderID}');
            print('   🔍 Not first load? ${_lastMessageCount > 0}');

            final isFromOtherUser = messageSenderId != senderID;

            if (isFromOtherUser && _lastMessageCount > 0) {
              print('\n   🔊 PLAYING SOUND NOW!');
              _notificationService.playNotificationSound();
            } else if (!isFromOtherUser) {
              print('\n   ❌ NO SOUND - I sent this message');
            } else {
              print('\n   ❌ NO SOUND - First load');
            }

            _lastMessageCount = messages.length;
          } else {
            print('   ⏸️ No new messages (count same)');
          }
        } else if (_lastMessageCount == 0) {
          print('\n📊 FIRST LOAD: Setting initial count');
          _lastMessageCount = messages.length;
        }

        print('--- END STREAM BUILDER ---\n');

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            final messageData = message.data() as Map<String, dynamic>;
            final isSentByCurrentUser = messageData['senderId'] == senderID;

            return Align(
              alignment: isSentByCurrentUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: isSentByCurrentUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isSentByCurrentUser
                        ? const Radius.circular(16)
                        : const Radius.circular(0),
                    bottomRight: isSentByCurrentUser
                        ? const Radius.circular(0)
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
              onSubmitted: (_) => sendMessage(),
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
