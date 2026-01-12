import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:andreopoulos_messasing/features/chat/services/chat_service.dart';
import 'chat_page.dart';

/// Athlete Messages Page
/// Shows the assigned coach for messaging
class AthleteMessagesPage extends StatelessWidget {
  const AthleteMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    final chatService = ChatService();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF010F31),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: chatService.streamAthleteCoachForChat(userId),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          // No coach assigned
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 100,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Coach Assigned',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'You need to be assigned to a coach before you can send messages',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Display coach
          final coachData = snapshot.data!;
          final coachEmail = coachData['email'] as String;
          final coachId = coachData['uid'] as String;
          final athleteId = userId;

          // Stream chat room metadata to get unread count and last message
          return StreamBuilder<Map<String, dynamic>?>(
            stream: chatService.streamChatRoomMetadata(athleteId, coachId),
            builder: (context, metadataSnapshot) {
              // Extract metadata
              final metadata = metadataSnapshot.data;
              final lastMessage = metadata?['lastMessage'] as String?;
              final unreadCount = metadata?['unreadCount_$athleteId'] as int? ?? 0;
              final lastMessageTime = metadata?['lastMessageTime'] as Timestamp?;

              // Format subtitle
              String subtitle = lastMessage ?? 'Tap to start messaging';
              if (lastMessage != null && lastMessage.length > 50) {
                subtitle = '${lastMessage.substring(0, 50)}...';
              }

              // Format time
              String timeString = '';
              if (lastMessageTime != null) {
                timeString = _formatTimestamp(lastMessageTime);
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header with unread indicator
                    Row(
                      children: [
                        Text(
                          'Your Coach',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount new',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Coach card with enhanced UI
                    Card(
                      elevation: unreadCount > 0 ? 4 : 3,
                      color: unreadCount > 0
                          ? Theme.of(context).colorScheme.secondary
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: unreadCount > 0
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Navigate to chat page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiverEmail: coachEmail,
                                receiverId: coachId,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Coach avatar with badge
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        radius: 35,
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (unreadCount > 0)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 24,
                                              minHeight: 24,
                                            ),
                                            child: Text(
                                              unreadCount > 99
                                                  ? '99+'
                                                  : '$unreadCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),

                                  // Coach info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          coachEmail,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: unreadCount > 0
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        if (timeString.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            timeString,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Message icon
                                  Icon(
                                    unreadCount > 0
                                        ? Icons.mark_chat_unread
                                        : Icons.chat_bubble,
                                    size: 32,
                                    color: unreadCount > 0
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                              if (lastMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.message,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          subtitle,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                            fontWeight: unreadCount > 0
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                const SizedBox(height: 24),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can message your coach for training advice, questions about workouts, or race preparation',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            );
          },
        );
      },
    ),
    );
  }
}

/// Format timestamp to readable string
String _formatTimestamp(Timestamp timestamp) {
  final DateTime dateTime = timestamp.toDate();
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
