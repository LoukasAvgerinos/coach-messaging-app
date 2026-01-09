import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // Get instance of Firestore & Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user stream (for displaying list of users)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // Send message
  Future<void> sendMessage(String receiverId, String message) async {
    // Get current user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'senderEmail': currentUserEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };

    // Construct chat room ID (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // Sort the ids to ensure chat room ID is the same for both users
    String chatRoomId = ids.join('_');

    // Add message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage);
  }

  // Get messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // Construct chat room ID
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Get athletes assigned to a coach for messaging
  /// Returns list of user data (userId, email) for athletes assigned to this coach
  Future<List<Map<String, dynamic>>> getCoachAthletesForChat(
      String coachId) async {
    try {
      // Get all users from Users collection
      final usersSnapshot = await _firestore.collection("Users").get();

      // Filter users who are athletes with this coachId
      final athletes = usersSnapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['userType'] == 'athlete' && data['coachId'] == coachId;
          })
          .map((doc) => doc.data())
          .toList();

      return athletes;
    } catch (e) {
      print('Error getting coach athletes for chat: $e');
      return [];
    }
  }

  /// Get coach assigned to an athlete for messaging
  /// Returns coach user data (userId, email) or null if no coach assigned
  Future<Map<String, dynamic>?> getAthleteCoachForChat(String userId) async {
    try {
      // Get athlete's user document
      final userDoc = await _firestore.collection("Users").doc(userId).get();

      if (!userDoc.exists) {
        print('User document not found for userId: $userId');
        return null;
      }

      final userData = userDoc.data();
      final coachId = userData?['coachId'];

      if (coachId == null) {
        print('No coach assigned to athlete: $userId');
        return null;
      }

      // Get coach's user document
      final coachDoc = await _firestore.collection("Users").doc(coachId).get();

      if (!coachDoc.exists) {
        print('Coach document not found for coachId: $coachId');
        return null;
      }

      return coachDoc.data();
    } catch (e) {
      print('Error getting athlete coach for chat: $e');
      return null;
    }
  }

  /// Stream version: Get athletes assigned to a coach for messaging (real-time)
  Stream<List<Map<String, dynamic>>> streamCoachAthletesForChat(
      String coachId) {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['userType'] == 'athlete' && data['coachId'] == coachId;
          })
          .map((doc) => doc.data())
          .toList();
    });
  }

  /// Stream version: Get coach assigned to an athlete for messaging (real-time)
  Stream<Map<String, dynamic>?> streamAthleteCoachForChat(String userId) {
    return _firestore.collection("Users").doc(userId).snapshots().asyncMap(
      (userDoc) async {
        if (!userDoc.exists) return null;

        final userData = userDoc.data();
        final coachId = userData?['coachId'];

        if (coachId == null) return null;

        final coachDoc =
            await _firestore.collection("Users").doc(coachId).get();

        if (!coachDoc.exists) return null;

        return coachDoc.data();
      },
    );
  }
}
