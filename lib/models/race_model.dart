import 'package:cloud_firestore/cloud_firestore.dart';

/// Race Model - Represents a race that an athlete is planning to participate in
/// or has participated in
class Race {
  final String raceId; // Unique identifier
  final String athleteId; // ID of the athlete who created this race

  // REQUIRED FIELDS
  final String raceName; // Name of the race (e.g., "Tour of Larissa")
  final DateTime raceDate; // Date of the race
  final String raceType; // Type: Road Race, Time Trial, MTB, Track, etc.
  final String priority; // A (goal), B (important), C (training)

  // OPTIONAL FIELDS
  final String? location; // City/venue (e.g., "Larissa, Greece")
  final String? distance; // Distance (e.g., "120km", "Half Marathon")
  final String? notes; // Additional notes/description

  // STATUS & RESULTS
  final String status; // "upcoming", "completed", "cancelled"
  final String? result; // Result after race (e.g., "1st place", "DNF", "Personal best")

  // METADATA
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  Race({
    required this.raceId,
    required this.athleteId,
    required this.raceName,
    required this.raceDate,
    required this.raceType,
    required this.priority,
    this.location,
    this.distance,
    this.notes,
    this.status = 'upcoming',
    this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate days until race
  int get daysUntilRace {
    final now = DateTime.now();
    final raceDay = DateTime(raceDate.year, raceDate.month, raceDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return raceDay.difference(today).inDays;
  }

  /// Check if race is upcoming (in the future)
  bool get isUpcoming => daysUntilRace >= 0 && status == 'upcoming';

  /// Check if race is past (already happened)
  bool get isPast => daysUntilRace < 0;

  /// Get color for priority (for UI)
  /// A = Red (goal race), B = Orange (important), C = Blue (training)
  String get priorityColor {
    switch (priority) {
      case 'A':
        return 'red';
      case 'B':
        return 'orange';
      case 'C':
        return 'blue';
      default:
        return 'grey';
    }
  }

  /// Get priority description
  String get priorityDescription {
    switch (priority) {
      case 'A':
        return 'Goal Race (Peak)';
      case 'B':
        return 'Important Race';
      case 'C':
        return 'Training Race';
      default:
        return 'Unknown';
    }
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'raceId': raceId,
      'athleteId': athleteId,
      'raceName': raceName,
      'raceDate': Timestamp.fromDate(raceDate),
      'raceType': raceType,
      'priority': priority,
      'location': location,
      'distance': distance,
      'notes': notes,
      'status': status,
      'result': result,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory Race.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Race(
      raceId: doc.id,
      athleteId: data['athleteId'] ?? '',
      raceName: data['raceName'] ?? '',
      raceDate: (data['raceDate'] as Timestamp).toDate(),
      raceType: data['raceType'] ?? '',
      priority: data['priority'] ?? 'C',
      location: data['location'],
      distance: data['distance'],
      notes: data['notes'],
      status: data['status'] ?? 'upcoming',
      result: data['result'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create a copy with updated fields
  Race copyWith({
    String? raceName,
    DateTime? raceDate,
    String? raceType,
    String? priority,
    String? location,
    String? distance,
    String? notes,
    String? status,
    String? result,
    DateTime? updatedAt,
  }) {
    return Race(
      raceId: this.raceId,
      athleteId: this.athleteId,
      raceName: raceName ?? this.raceName,
      raceDate: raceDate ?? this.raceDate,
      raceType: raceType ?? this.raceType,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      result: result ?? this.result,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Format race date for display
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${raceDate.day} ${months[raceDate.month - 1]} ${raceDate.year}';
  }
}

/// Constants for Race Types
class RaceTypes {
  static const String roadRace = 'Road Race';
  static const String timeTrial = 'Time Trial';
  static const String mtb = 'Mountain Bike';
  static const String track = 'Track';
  static const String cyclocross = 'Cyclocross';
  static const String gravel = 'Gravel';
  static const String other = 'Other';

  static List<String> get all => [
        roadRace,
        timeTrial,
        mtb,
        track,
        cyclocross,
        gravel,
        other,
      ];
}

/// Constants for Race Priorities
class RacePriorities {
  static const String a = 'A';
  static const String b = 'B';
  static const String c = 'C';

  static List<String> get all => [a, b, c];
}

/// Constants for Race Status
class RaceStatus {
  static const String upcoming = 'upcoming';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static List<String> get all => [upcoming, completed, cancelled];
}
