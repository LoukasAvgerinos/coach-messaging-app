import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/race_model.dart';
import '../models/athlete_profile_model.dart';
import '../services/profile_service.dart';

/// Coach Races Page
/// Shows all upcoming races for athletes assigned to the coach
class CoachRacesPage extends StatefulWidget {
  const CoachRacesPage({super.key});

  @override
  State<CoachRacesPage> createState() => _CoachRacesPageState();
}

class _CoachRacesPageState extends State<CoachRacesPage> {
  final ProfileService _profileService = ProfileService();

  // Cache for athlete profiles
  final Map<String, AthleteProfile> _athleteCache = {};

  @override
  Widget build(BuildContext context) {
    final coachId = FirebaseAuth.instance.currentUser?.uid;

    if (coachId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Athlete Races')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Athlete Races'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: StreamBuilder<List<Race>>(
        stream: _profileService.getRacesByCoach(coachId),
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

          // No races
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 100,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Upcoming Races',
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
                      'Your athletes haven\'t added any races yet',
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

          // Display races grouped by upcoming/past
          final races = snapshot.data!;
          final upcomingRaces = races.where((r) => r.isUpcoming).toList();
          final pastRaces = races.where((r) => r.isPast).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Upcoming races section
              if (upcomingRaces.isNotEmpty) ...[
                Text(
                  'Upcoming Races (${upcomingRaces.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ...upcomingRaces.map((race) => _buildRaceCard(context, race)),
                const SizedBox(height: 24),
              ],

              // Past races section
              if (pastRaces.isNotEmpty) ...[
                Text(
                  'Past Races (${pastRaces.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ...pastRaces.map((race) => _buildRaceCard(context, race)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildRaceCard(BuildContext context, Race race) {
    Color priorityColor;
    switch (race.priority) {
      case 'A':
        priorityColor = Colors.red;
        break;
      case 'B':
        priorityColor = Colors.orange;
        break;
      case 'C':
        priorityColor = Colors.blue;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return FutureBuilder<AthleteProfile?>(
      future: _getAthleteProfile(race.athleteId),
      builder: (context, athleteSnapshot) {
        String athleteName = 'Loading...';
        if (athleteSnapshot.hasData && athleteSnapshot.data != null) {
          athleteName = athleteSnapshot.data!.fullName;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: priorityColor, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Athlete name
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      athleteName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Race name and priority
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        race.raceName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Priority ${race.priority}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Date and countdown
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      race.formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    if (race.isUpcoming) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: race.daysUntilRace <= 3
                              ? Colors.red.withOpacity(0.2)
                              : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                          border: race.daysUntilRace <= 3
                              ? Border.all(color: Colors.red, width: 2)
                              : null,
                        ),
                        child: Text(
                          '${race.daysUntilRace} days left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: race.daysUntilRace <= 3
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: race.daysUntilRace <= 3
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Race type and location
                Row(
                  children: [
                    Icon(
                      Icons.directions_bike,
                      size: 16,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      race.raceType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    if (race.location != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          race.location!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                if (race.distance != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 16,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        race.distance!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<AthleteProfile?> _getAthleteProfile(String athleteId) async {
    // Check cache first
    if (_athleteCache.containsKey(athleteId)) {
      return _athleteCache[athleteId];
    }

    // Fetch from Firestore
    final profile = await _profileService.getAthleteProfile(athleteId);
    if (profile != null) {
      _athleteCache[athleteId] = profile;
    }
    return profile;
  }
}
