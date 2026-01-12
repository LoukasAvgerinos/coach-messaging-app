import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:andreopoulos_messasing/features/profile/data/models/athlete_profile_model.dart';
import 'package:andreopoulos_messasing/features/race/data/models/race_model.dart';

/// Service για διαχείριση Athlete Profiles στο Firestore
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  final String _athletesCollection = 'athletes';
  final String _performanceCollection = 'performanceMetrics';

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==========================================
  // ATHLETE PROFILE OPERATIONS
  // ==========================================

  /// Create new athlete profile
  Future<void> createAthleteProfile(AthleteProfile profile) async {
    try {
      await _firestore
          .collection(_athletesCollection)
          .doc(profile.athleteId)
          .set(profile.toMap());

      print('✅ Athlete profile created: ${profile.athleteId}');
    } catch (e) {
      print('❌ Error creating athlete profile: $e');
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Get athlete profile by ID
  Future<AthleteProfile?> getAthleteProfile(String athleteId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_athletesCollection)
          .doc(athleteId)
          .get();

      if (doc.exists) {
        return AthleteProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting athlete profile: $e');
      return null;
    }
  }

  /// Get athlete profile by user ID
  Future<AthleteProfile?> getAthleteProfileByUserId(String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(_athletesCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return AthleteProfile.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting athlete profile by userId: $e');
      return null;
    }
  }

  /// Update athlete profile
  Future<void> updateAthleteProfile(AthleteProfile profile) async {
    try {
      // Update the updatedAt timestamp
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(_athletesCollection)
          .doc(profile.athleteId)
          .update(updatedProfile.toMap());

      print('✅ Athlete profile updated: ${profile.athleteId}');
    } catch (e) {
      print('❌ Error updating athlete profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Stream athlete profile (real-time updates)
  Stream<AthleteProfile?> streamAthleteProfile(String athleteId) {
    return _firestore
        .collection(_athletesCollection)
        .doc(athleteId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return AthleteProfile.fromFirestore(doc);
          }
          return null;
        });
  }

  /// Check if athlete profile exists
  Future<bool> athleteProfileExists(String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(_athletesCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking if profile exists: $e');
      return false;
    }
  }

  // ==========================================
  // PERFORMANCE METRICS OPERATIONS (Coach only)
  // ==========================================

  /// Create or update performance metrics
  Future<void> updatePerformanceMetrics(PerformanceMetrics metrics) async {
    try {
      await _firestore
          .collection(_performanceCollection)
          .doc(metrics.athleteId)
          .set(metrics.toMap(), SetOptions(merge: true));

      print('✅ Performance metrics updated for: ${metrics.athleteId}');
    } catch (e) {
      print('❌ Error updating performance metrics: $e');
      throw Exception('Failed to update performance metrics: $e');
    }
  }

  /// Get performance metrics
  Future<PerformanceMetrics?> getPerformanceMetrics(String athleteId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_performanceCollection)
          .doc(athleteId)
          .get();

      if (doc.exists) {
        return PerformanceMetrics.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting performance metrics: $e');
      return null;
    }
  }

  /// Stream performance metrics (real-time updates)
  Stream<PerformanceMetrics?> streamPerformanceMetrics(String athleteId) {
    return _firestore
        .collection(_performanceCollection)
        .doc(athleteId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return PerformanceMetrics.fromFirestore(doc);
          }
          return null;
        });
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Get all athletes (for coach view)
  Stream<List<AthleteProfile>> getAllAthletes() {
    return _firestore
        .collection(_athletesCollection)
        .orderBy('surname')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AthleteProfile.fromFirestore(doc))
              .toList();
        });
  }

  /// Get athletes assigned to a specific coach
  Stream<List<AthleteProfile>> getAthletesByCoach(String coachId) {
    return _firestore
        .collection(_athletesCollection)
        .orderBy('surname')
        .snapshots()
        .asyncMap((snapshot) async {
      // Get all athletes
      List<AthleteProfile> allAthletes = snapshot.docs
          .map((doc) => AthleteProfile.fromFirestore(doc))
          .toList();

      // Filter by coachId from Users collection
      List<AthleteProfile> coachAthletes = [];

      for (var athlete in allAthletes) {
        // Check if this athlete's coachId matches
        DocumentSnapshot userDoc = await _firestore
            .collection('Users')
            .doc(athlete.userId)
            .get();

        if (userDoc.exists) {
          String? athleteCoachId = userDoc.data() != null
              ? (userDoc.data() as Map<String, dynamic>)['coachId']
              : null;

          if (athleteCoachId == coachId) {
            coachAthletes.add(athlete);
          }
        }
      }

      return coachAthletes;
    });
  }

  /// Search athletes by name
  Future<List<AthleteProfile>> searchAthletes(String searchTerm) async {
    try {
      String searchLower = searchTerm.toLowerCase();

      QuerySnapshot query = await _firestore
          .collection(_athletesCollection)
          .get();

      // Filter results (Firestore doesn't support case-insensitive search natively)
      List<AthleteProfile> athletes = query.docs
          .map((doc) => AthleteProfile.fromFirestore(doc))
          .where((athlete) {
            String fullName = '${athlete.name} ${athlete.surname}'
                .toLowerCase();
            return fullName.contains(searchLower);
          })
          .toList();

      return athletes;
    } catch (e) {
      print('❌ Error searching athletes: $e');
      return [];
    }
  }

  /// Delete athlete profile (admin only - use with caution)
  Future<void> deleteAthleteProfile(String athleteId) async {
    try {
      // Delete profile
      await _firestore.collection(_athletesCollection).doc(athleteId).delete();

      // Delete associated performance metrics
      await _firestore
          .collection(_performanceCollection)
          .doc(athleteId)
          .delete();

      print('✅ Athlete profile deleted: $athleteId');
    } catch (e) {
      print('❌ Error deleting athlete profile: $e');
      throw Exception('Failed to delete profile: $e');
    }
  }

  // ==========================================
  // RACE OPERATIONS
  // ==========================================

  /// Create a new race
  Future<void> createRace(Race race) async {
    try {
      await _firestore.collection('races').doc(race.raceId).set(race.toMap());
      print('✅ Race created: ${race.raceId}');
    } catch (e) {
      print('❌ Error creating race: $e');
      throw Exception('Failed to create race: $e');
    }
  }

  /// Update an existing race
  Future<void> updateRace(Race race) async {
    try {
      await _firestore
          .collection('races')
          .doc(race.raceId)
          .update(race.toMap());
      print('✅ Race updated: ${race.raceId}');
    } catch (e) {
      print('❌ Error updating race: $e');
      throw Exception('Failed to update race: $e');
    }
  }

  /// Delete a race
  Future<void> deleteRace(String raceId) async {
    try {
      await _firestore.collection('races').doc(raceId).delete();
      print('✅ Race deleted: $raceId');
    } catch (e) {
      print('❌ Error deleting race: $e');
      throw Exception('Failed to delete race: $e');
    }
  }

  /// Get races for a specific athlete
  Stream<List<Race>> getRacesByAthlete(String athleteId) {
    return _firestore
        .collection('races')
        .where('athleteId', isEqualTo: athleteId)
        .orderBy('raceDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Race.fromFirestore(doc)).toList();
    });
  }

  /// Get upcoming races for a specific athlete
  Stream<List<Race>> getUpcomingRacesByAthlete(String athleteId) {
    return _firestore
        .collection('races')
        .where('athleteId', isEqualTo: athleteId)
        .where('status', isEqualTo: 'upcoming')
        .orderBy('raceDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Race.fromFirestore(doc)).toList();
    });
  }

  /// Get all races for athletes assigned to a coach
  Stream<List<Race>> getRacesByCoach(String coachId) {
    return _firestore
        .collection('races')
        .orderBy('raceDate', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Race> allRaces =
          snapshot.docs.map((doc) => Race.fromFirestore(doc)).toList();

      // Filter races for athletes assigned to this coach
      List<Race> coachRaces = [];

      for (var race in allRaces) {
        // Get athlete's profile to get userId
        DocumentSnapshot athleteDoc = await _firestore
            .collection(_athletesCollection)
            .doc(race.athleteId)
            .get();

        if (athleteDoc.exists) {
          String userId = (athleteDoc.data() as Map<String, dynamic>)['userId'];

          // Check if this athlete's coachId matches
          DocumentSnapshot userDoc =
              await _firestore.collection('Users').doc(userId).get();

          if (userDoc.exists) {
            String? athleteCoachId = userDoc.data() != null
                ? (userDoc.data() as Map<String, dynamic>)['coachId']
                : null;

            if (athleteCoachId == coachId) {
              coachRaces.add(race);
            }
          }
        }
      }

      return coachRaces;
    });
  }

  /// Get a single race by ID
  Future<Race?> getRace(String raceId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('races').doc(raceId).get();

      if (doc.exists) {
        return Race.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting race: $e');
      return null;
    }
  }
}
