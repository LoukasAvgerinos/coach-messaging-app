import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:andreopoulos_messasing/features/notifications/services/notification_service.dart';

/// Message Listener Service
/// Listens for new messages in Firestore and triggers local notifications
/// This works when app is in foreground or background (but not terminated)
class MessageListenerService {
  static final MessageListenerService _instance =
      MessageListenerService._internal();
  factory MessageListenerService() => _instance;
  MessageListenerService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  StreamSubscription<QuerySnapshot>? _messageSubscription;
  final Set<String> _processedMessageIds = {};

  /// Start listening for new messages
  Future<void> startListening() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('⚠️ [MessageListener] No user logged in, cannot start listening');
      return;
    }

    print('🎧 [MessageListener] Starting to listen for user: $currentUserId');

    // Listen to all chat rooms where user is a participant
    _messageSubscription = _firestore
        .collection("chat_rooms")
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((chatRoomsSnapshot) {
      _handleChatRoomsUpdate(chatRoomsSnapshot, currentUserId);
    });
  }

  /// Handle updates to chat rooms
  void _handleChatRoomsUpdate(
      QuerySnapshot chatRoomsSnapshot, String currentUserId) {
    for (var chatRoomDoc in chatRoomsSnapshot.docs) {
      final chatRoomId = chatRoomDoc.id;

      // Listen to messages in this chat room
      _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .limit(1) // Only get the latest message
          .snapshots()
          .listen((messagesSnapshot) {
        if (messagesSnapshot.docs.isNotEmpty) {
          final latestMessageDoc = messagesSnapshot.docs.first;
          final messageData = latestMessageDoc.data();
          final messageId = latestMessageDoc.id;

          // Check if this message is new and not sent by current user
          final senderId = messageData['senderId'];
          final isFromOtherUser = senderId != currentUserId;
          final isNewMessage = !_processedMessageIds.contains(messageId);

          if (isFromOtherUser && isNewMessage) {
            print(
                '📩 [MessageListener] New message detected from: $senderId');

            // Mark as processed
            _processedMessageIds.add(messageId);

            // Clean up old message IDs (keep only last 100)
            if (_processedMessageIds.length > 100) {
              final firstId = _processedMessageIds.first;
              _processedMessageIds.remove(firstId);
            }

            // Trigger notification
            _triggerNewMessageNotification(messageData);
          }
        }
      });
    }
  }

  /// Trigger a local notification for new message
  void _triggerNewMessageNotification(Map<String, dynamic> messageData) {
    final senderEmail = messageData['senderEmail'] ?? 'Someone';
    final message = messageData['message'] ?? 'New message';

    print('🔔 [MessageListener] Triggering notification...');
    print('   From: $senderEmail');
    print('   Message: $message');

    // Play notification sound
    _notificationService.playNotificationSound();

    // Show local notification
    _notificationService.showLocalNotification(
      title: 'New message from $senderEmail',
      body: message,
    );
  }

  /// Stop listening for messages
  void stopListening() {
    print('🛑 [MessageListener] Stopping message listener');
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _processedMessageIds.clear();
  }
}
