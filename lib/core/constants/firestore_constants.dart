/// Firestore Collection Names
class FirestoreCollections {
  static const String users = 'Users';
  static const String athletes = 'athletes';
  static const String chatRooms = 'chat_rooms';
  static const String messages = 'messages';
  static const String races = 'races';
  static const String performanceMetrics = 'performanceMetrics';
}

/// Firestore Field Names
class FirestoreFields {
  // User fields
  static const String email = 'email';
  static const String uid = 'uid';
  static const String userType = 'userType';
  static const String coachId = 'coachId';
  static const String fcmToken = 'fcmToken';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  // Message fields
  static const String senderId = 'senderId';
  static const String senderEmail = 'senderEmail';
  static const String receiverId = 'receiverId';
  static const String message = 'message';
  static const String timestamp = 'timestamp';

  // Chat room fields
  static const String participants = 'participants';
  static const String lastMessage = 'lastMessage';
  static const String lastMessageTime = 'lastMessageTime';
  static const String lastMessageSenderId = 'lastMessageSenderId';

  // User types
  static const String userTypeAthlete = 'athlete';
  static const String userTypeCoach = 'coach';
}
