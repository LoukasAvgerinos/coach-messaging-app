import 'package:cloud_firestore/cloud_firestore.dart';

/// Athlete Profile Model
/// Contains all athlete information that can be edited by the athlete
class AthleteProfile {
  final String athleteId;
  final String userId; // Link to Firebase Auth user

  // SECTION 1: Basic Info (Editable by Athlete)
  final String name;
  final String surname;
  final String email;
  final String? phone; // Optional
  final String? city; // Optional - Πόλη
  final DateTime dateOfBirth;

  // SECTION 2: Physical Metrics (Editable by Athlete)
  final double weight; // kg
  final double height; // cm

  // SECTION 3: Training Availability (Editable by Athlete)
  final int availableHoursPerWeek; // Διαθέσιμες ώρες εβδομαδιαίως
  final int availableTrainingDays; // Μέρες διαθέσιμες για προπόνηση

  // SECTION 4: Equipment & Facilities (Editable by Athlete)
  final String?
  equipment; // Εξοπλισμός αθλητή (π.χ. "Road bike, Power meter, Heart rate monitor")
  final bool hasGymAccess; // Χρήση γυμναστηρίου

  // SECTION 5: Health Info (Editable by Athlete)
  final String? medicalConditions; // Ιατρικά προβλήματα
  final String? supplements; // Συμπληρώματα διατροφής

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  AthleteProfile({
    required this.athleteId,
    required this.userId,
    required this.name,
    required this.surname,
    required this.email,
    this.phone,
    this.city,
    required this.dateOfBirth,
    required this.weight,
    required this.height,
    required this.availableHoursPerWeek,
    required this.availableTrainingDays,
    this.equipment,
    required this.hasGymAccess,
    this.medicalConditions,
    this.supplements,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate age from date of birth
  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;

    // Check if birthday hasn't occurred yet this year
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'athleteId': athleteId,
      'userId': userId,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'city': city,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'weight': weight,
      'height': height,
      'availableHoursPerWeek': availableHoursPerWeek,
      'availableTrainingDays': availableTrainingDays,
      'equipment': equipment,
      'hasGymAccess': hasGymAccess,
      'medicalConditions': medicalConditions,
      'supplements': supplements,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory AthleteProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AthleteProfile(
      athleteId: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      city: data['city'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      availableHoursPerWeek: data['availableHoursPerWeek'] ?? 0,
      availableTrainingDays: data['availableTrainingDays'] ?? 0,
      equipment: data['equipment'],
      hasGymAccess: data['hasGymAccess'] ?? false,
      medicalConditions: data['medicalConditions'],
      supplements: data['supplements'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create a copy with updated fields
  AthleteProfile copyWith({
    String? name,
    String? surname,
    String? email,
    String? phone,
    String? city,
    DateTime? dateOfBirth,
    double? weight,
    double? height,
    int? availableHoursPerWeek,
    int? availableTrainingDays,
    String? equipment,
    bool? hasGymAccess,
    String? medicalConditions,
    String? supplements,
    DateTime? updatedAt,
  }) {
    return AthleteProfile(
      athleteId: this.athleteId,
      userId: this.userId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      availableHoursPerWeek:
          availableHoursPerWeek ?? this.availableHoursPerWeek,
      availableTrainingDays:
          availableTrainingDays ?? this.availableTrainingDays,
      equipment: equipment ?? this.equipment,
      hasGymAccess: hasGymAccess ?? this.hasGymAccess,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      supplements: supplements ?? this.supplements,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get full name
  String get fullName => '$name $surname';

  /// Calculate BMI
  double get bmi {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
}

/// Performance Metrics Model
/// Contains FTP, FTHR - managed by Coach only
class PerformanceMetrics {
  final String metricsId;
  final String athleteId;

  // Performance Data (Coach only)
  final int? ftp; // Functional Threshold Power (watts)
  final int? fthr; // Functional Threshold Heart Rate (bpm)

  // Metadata
  final DateTime? lastUpdated;
  final String? updatedByCoachId;

  PerformanceMetrics({
    required this.metricsId,
    required this.athleteId,
    this.ftp,
    this.fthr,
    this.lastUpdated,
    this.updatedByCoachId,
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'metricsId': metricsId,
      'athleteId': athleteId,
      'ftp': ftp,
      'fthr': fthr,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
      'updatedByCoachId': updatedByCoachId,
    };
  }

  /// Create from Firestore document
  factory PerformanceMetrics.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PerformanceMetrics(
      metricsId: doc.id,
      athleteId: data['athleteId'] ?? '',
      ftp: data['ftp'],
      fthr: data['fthr'],
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
      updatedByCoachId: data['updatedByCoachId'],
    );
  }

  /// Create a copy with updated fields
  PerformanceMetrics copyWith({
    int? ftp,
    int? fthr,
    DateTime? lastUpdated,
    String? updatedByCoachId,
  }) {
    return PerformanceMetrics(
      metricsId: this.metricsId,
      athleteId: this.athleteId,
      ftp: ftp ?? this.ftp,
      fthr: fthr ?? this.fthr,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedByCoachId: updatedByCoachId ?? this.updatedByCoachId,
    );
  }
}
