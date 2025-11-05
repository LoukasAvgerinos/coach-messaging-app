import 'package:flutter/material.dart';
import '/services/chat/chat_services.dart';
import '/services/auth/auth_service.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverId;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverId, // ← FIX 1: Add this required parameter
  });

  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services instances
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // send message method
  void sendMessage(String receiverId) async {
    final String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatService.sendMessage(receiverId, message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverEmail), centerTitle: true),
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
      stream: _chatService.getMessages(senderID, receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final isSentByCurrentUser = messageData['senderId'] == senderID;

            return Align(
              alignment: isSentByCurrentUser
                  ? Alignment
                        .centerRight // ← Sender: RIGHT
                  : Alignment.centerLeft, // ← Receiver: LEFT
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
                      ? Colors
                            .blue // Sender: Blue (like Facebook)
                      : Colors.grey[300], // Receiver: Grey
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
                    color: isSentByCurrentUser ? Colors.white : Colors.black,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => sendMessage(receiverId),
          ),
        ],
      ),
    );
  }
}
