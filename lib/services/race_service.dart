import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/race_model.dart';

/// Race Service - Handles all race-related Firestore operations
class RaceService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  final String _racesCollection = 'races';

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== CREATE ====================

  /// Create a new race for the current athlete
  Future<String> createRace({
    required String raceName,
    required DateTime raceDate,
    required String raceType,
    required String priority,
    String? location,
    String? distance,
    String? notes,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Create new race document
      final docRef = _firestore.collection(_racesCollection).doc();

      final race = Race(
        raceId: docRef.id,
        athleteId: userId,
        raceName: raceName,
        raceDate: raceDate,
        raceType: raceType,
        priority: priority,
        location: location,
        distance: distance,
        notes: notes,
        status: RaceStatus.upcoming,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(race.toMap());

      print('✅ Race created: ${race.raceName}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating race: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get all races for the current athlete as a stream (real-time updates)
  Stream<List<Race>> getAthleteRacesStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    // Filter and sort in memory to avoid composite index requirement
    return _firestore
        .collection(_racesCollection)
        .where('athleteId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final races = snapshot.docs.map((doc) => Race.fromFirestore(doc)).toList();
      // Sort by date (earliest first)
      races.sort((a, b) => a.raceDate.compareTo(b.raceDate));
      return races;
    });
  }

  /// Get all upcoming races for the current athlete
  Stream<List<Race>> getUpcomingRacesStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    // Filter in memory to avoid composite index requirement
    return _firestore
        .collection(_racesCollection)
        .where('athleteId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final allRaces = snapshot.docs.map((doc) => Race.fromFirestore(doc)).toList();
      // Filter for upcoming races
      final upcomingRaces = allRaces
          .where((race) => race.status == RaceStatus.upcoming)
          .toList();
      // Sort by date
      upcomingRaces.sort((a, b) => a.raceDate.compareTo(b.raceDate));
      return upcomingRaces;
    });
  }

  /// Get completed races for the current athlete
  Stream<List<Race>> getCompletedRacesStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    // Filter in memory to avoid composite index requirement
    return _firestore
        .collection(_racesCollection)
        .where('athleteId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final allRaces = snapshot.docs.map((doc) => Race.fromFirestore(doc)).toList();
      // Filter for completed races
      final completedRaces = allRaces
          .where((race) => race.status == RaceStatus.completed)
          .toList();
      // Sort by date (most recent first)
      completedRaces.sort((a, b) => b.raceDate.compareTo(a.raceDate));
      return completedRaces;
    });
  }

  /// Get a single race by ID
  Future<Race?> getRaceById(String raceId) async {
    try {
      final doc = await _firestore.collection(_racesCollection).doc(raceId).get();

      if (!doc.exists) {
        return null;
      }

      return Race.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting race: $e');
      return null;
    }
  }

  /// Get races for a specific athlete (for coach view - future feature)
  Stream<List<Race>> getRacesByAthleteId(String athleteId) {
    return _firestore
        .collection(_racesCollection)
        .where('athleteId', isEqualTo: athleteId)
        .orderBy('raceDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Race.fromFirestore(doc)).toList();
    });
  }

  // ==================== UPDATE ====================

  /// Update an existing race
  Future<void> updateRace({
    required String raceId,
    String? raceName,
    DateTime? raceDate,
    String? raceType,
    String? priority,
    String? location,
    String? distance,
    String? notes,
    String? status,
    String? result,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (raceName != null) updateData['raceName'] = raceName;
      if (raceDate != null) updateData['raceDate'] = Timestamp.fromDate(raceDate);
      if (raceType != null) updateData['raceType'] = raceType;
      if (priority != null) updateData['priority'] = priority;
      if (location != null) updateData['location'] = location;
      if (distance != null) updateData['distance'] = distance;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status;
      if (result != null) updateData['result'] = result;

      await _firestore.collection(_racesCollection).doc(raceId).update(updateData);

      print('✅ Race updated: $raceId');
    } catch (e) {
      print('❌ Error updating race: $e');
      rethrow;
    }
  }

  /// Mark race as completed
  Future<void> markRaceAsCompleted(String raceId, {String? result}) async {
    try {
      await updateRace(
        raceId: raceId,
        status: RaceStatus.completed,
        result: result,
      );
      print('✅ Race marked as completed');
    } catch (e) {
      print('❌ Error marking race as completed: $e');
      rethrow;
    }
  }

  /// Mark race as cancelled
  Future<void> markRaceAsCancelled(String raceId) async {
    try {
      await updateRace(
        raceId: raceId,
        status: RaceStatus.cancelled,
      );
      print('✅ Race marked as cancelled');
    } catch (e) {
      print('❌ Error marking race as cancelled: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete a race
  Future<void> deleteRace(String raceId) async {
    try {
      await _firestore.collection(_racesCollection).doc(raceId).delete();
      print('✅ Race deleted: $raceId');
    } catch (e) {
      print('❌ Error deleting race: $e');
      rethrow;
    }
  }

  // ==================== STATISTICS ====================

  /// Get race statistics for the current athlete
  Future<RaceStatistics> getRaceStatistics() async {
    final userId = currentUserId;
    if (userId == null) {
      return RaceStatistics(
        totalRaces: 0,
        upcomingRaces: 0,
        completedRaces: 0,
        aRaces: 0,
        bRaces: 0,
        cRaces: 0,
      );
    }

    try {
      final snapshot = await _firestore
          .collection(_racesCollection)
          .where('athleteId', isEqualTo: userId)
          .get();

      final races = snapshot.docs.map((doc) => Race.fromFirestore(doc)).toList();

      return RaceStatistics(
        totalRaces: races.length,
        upcomingRaces: races.where((r) => r.status == RaceStatus.upcoming).length,
        completedRaces: races.where((r) => r.status == RaceStatus.completed).length,
        aRaces: races.where((r) => r.priority == 'A').length,
        bRaces: races.where((r) => r.priority == 'B').length,
        cRaces: races.where((r) => r.priority == 'C').length,
      );
    } catch (e) {
      print('❌ Error getting race statistics: $e');
      return RaceStatistics(
        totalRaces: 0,
        upcomingRaces: 0,
        completedRaces: 0,
        aRaces: 0,
        bRaces: 0,
        cRaces: 0,
      );
    }
  }

  /// Get next upcoming race (closest to today)
  Future<Race?> getNextRace() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final now = Timestamp.fromDate(DateTime.now());

      final snapshot = await _firestore
          .collection(_racesCollection)
          .where('athleteId', isEqualTo: userId)
          .where('status', isEqualTo: RaceStatus.upcoming)
          .where('raceDate', isGreaterThanOrEqualTo: now)
          .orderBy('raceDate', descending: false)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Race.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('❌ Error getting next race: $e');
      return null;
    }
  }
}

/// Race Statistics Model
class RaceStatistics {
  final int totalRaces;
  final int upcomingRaces;
  final int completedRaces;
  final int aRaces;
  final int bRaces;
  final int cRaces;

  RaceStatistics({
    required this.totalRaces,
    required this.upcomingRaces,
    required this.completedRaces,
    required this.aRaces,
    required this.bRaces,
    required this.cRaces,
  });
}
