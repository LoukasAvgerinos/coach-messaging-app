import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:andreopoulos_messasing/features/chat/services/chat_service.dart';
import 'package:andreopoulos_messasing/features/profile/services/profile_service.dart';
import 'package:andreopoulos_messasing/features/profile/data/models/athlete_profile_model.dart';
import 'chat_page.dart';

/// Coach Messages Page
/// Shows filtered list of assigned athletes for messaging
class CoachMessagesPage extends StatefulWidget {
  const CoachMessagesPage({super.key});

  @override
  State<CoachMessagesPage> createState() => _CoachMessagesPageState();
}

class _CoachMessagesPageState extends State<CoachMessagesPage> {
  final ChatService _chatService = ChatService();
  final ProfileService _profileService = ProfileService();

  // Cache for athlete profiles to show names instead of emails
  final Map<String, AthleteProfile> _athleteCache = {};

  @override
  Widget build(BuildContext context) {
    final coachId = FirebaseAuth.instance.currentUser?.uid;

    if (coachId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF010F31),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.streamCoachAthletesForChat(coachId),
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

          // No athletes
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    'No Athletes Yet',
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
                      'Once athletes are assigned to you, you can message them here',
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

          // Display list of athletes
          final athletes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: athletes.length,
            itemBuilder: (context, index) {
              final athleteUser = athletes[index];
              return _buildAthleteCard(context, athleteUser);
            },
          );
        },
      ),
    );
  }

  Widget _buildAthleteCard(
      BuildContext context, Map<String, dynamic> athleteUser) {
    final athleteUserId = athleteUser['uid'] as String;
    final athleteEmail = athleteUser['email'] as String;
    final coachId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<AthleteProfile?>(
      future: _getAthleteProfile(athleteUserId),
      builder: (context, profileSnapshot) {
        // Default to email if profile not loaded
        String displayName = athleteEmail;

        if (profileSnapshot.hasData && profileSnapshot.data != null) {
          final profile = profileSnapshot.data!;
          displayName = profile.fullName;
        }

        // Stream chat room metadata for this athlete
        return StreamBuilder<Map<String, dynamic>?>(
          stream: _chatService.streamChatRoomMetadata(coachId, athleteUserId),
          builder: (context, metadataSnapshot) {
            // Extract metadata
            final metadata = metadataSnapshot.data;
            final lastMessage = metadata?['lastMessage'] as String?;
            final unreadCount = metadata?['unreadCount_$coachId'] as int? ?? 0;
            final lastMessageTime = metadata?['lastMessageTime'] as Timestamp?;

            // Format subtitle
            String subtitle = lastMessage ?? 'No messages yet';
            if (lastMessage != null && lastMessage.length > 40) {
              subtitle = '${lastMessage.substring(0, 40)}...';
            }

            // Format time
            String timeString = '';
            if (lastMessageTime != null) {
              timeString = _formatTimestamp(lastMessageTime);
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: unreadCount > 0 ? 4 : 2,
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
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 28,
                      child: Text(
                        _getInitials(displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // Unread badge
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    if (timeString.isNotEmpty)
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  unreadCount > 0 ? Icons.mark_chat_unread : Icons.chat_bubble_outline,
                  color: unreadCount > 0 ? Colors.red : Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  // Navigate to chat page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverEmail: athleteEmail,
                        receiverId: athleteUserId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Get athlete profile from cache or fetch from Firestore
  Future<AthleteProfile?> _getAthleteProfile(String userId) async {
    // Check cache first
    if (_athleteCache.containsKey(userId)) {
      return _athleteCache[userId];
    }

    // Fetch athlete profile by userId
    final profile = await _profileService.getAthleteProfileByUserId(userId);
    if (profile != null) {
      _athleteCache[userId] = profile;
    }
    return profile;
  }

  /// Get initials from full name for avatar
  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
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
}
