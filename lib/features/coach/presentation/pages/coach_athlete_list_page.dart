import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:andreopoulos_messasing/features/profile/data/models/athlete_profile_model.dart';
import 'package:andreopoulos_messasing/features/profile/services/profile_service.dart';
import 'coach_athlete_detail_page.dart';

/// Coach Athlete List Page
/// Shows all athletes assigned to the coach with search functionality
class CoachAthleteListPage extends StatefulWidget {
  const CoachAthleteListPage({super.key});

  @override
  State<CoachAthleteListPage> createState() => _CoachAthleteListPageState();
}

class _CoachAthleteListPageState extends State<CoachAthleteListPage> {
  final ProfileService _profileService = ProfileService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coachId = FirebaseAuth.instance.currentUser?.uid;

    if (coachId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Athletes'),
          backgroundColor: const Color(0xFF010F31),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Not logged in'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Athletes'),
        backgroundColor: const Color(0xFF010F31),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search athletes by name...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Athletes list
          Expanded(
            child: StreamBuilder<List<AthleteProfile>>(
              stream: _profileService.getAthletesByCoach(coachId),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading athletes',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // No data
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 100,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
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
                            'Athletes will appear here once they are assigned to you.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter athletes based on search query
                List<AthleteProfile> athletes = snapshot.data!;
                if (_searchQuery.isNotEmpty) {
                  athletes = athletes.where((athlete) {
                    return athlete.fullName.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                // Show filtered results or "no results" message
                if (athletes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Results Found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Display athlete cards
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: athletes.length,
                  itemBuilder: (context, index) {
                    final athlete = athletes[index];
                    return _buildAthleteCard(context, athlete);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteCard(BuildContext context, AthleteProfile athlete) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to athlete detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoachAthleteDetailPage(athlete: athlete),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                child: Text(
                  athlete.name[0].toUpperCase() +
                      athlete.surname[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Athlete info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age: ${athlete.age} • ${athlete.city ?? "No city"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${athlete.availableTrainingDays} days/week • ${athlete.availableHoursPerWeek}h/week',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Delete icon button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                iconSize: 24,
                onPressed: () => _showDeleteConfirmationDialog(context, athlete),
                tooltip: 'Delete athlete',
              ),

              const SizedBox(width: 8),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show confirmation dialog before deleting athlete
  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, AthleteProfile athlete) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Athlete?'),
          content: Text(
            'Are you sure you want to delete ${athlete.fullName}?\n\nThis action cannot be undone and will permanently remove all athlete data including performance metrics and race records.',
            style: const TextStyle(height: 1.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteAthlete(context, athlete);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Delete athlete and show feedback
  Future<void> _deleteAthlete(
      BuildContext context, AthleteProfile athlete) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleting ${athlete.fullName}...'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Delete the athlete profile
      await _profileService.deleteAthleteProfile(athlete.athleteId);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${athlete.fullName} has been deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete athlete: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
