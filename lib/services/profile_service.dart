import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/athlete_profile_model.dart';

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
}
