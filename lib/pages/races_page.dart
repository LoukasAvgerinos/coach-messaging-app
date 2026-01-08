import 'package:flutter/material.dart';
import '../models/race_model.dart';
import '../services/race_service.dart';
import 'race_edit_page.dart';

/// Races Page - Shows all races for the current athlete
/// Displays upcoming and past races with options to add, edit, delete
class RacesPage extends StatefulWidget {
  const RacesPage({super.key});

  @override
  State<RacesPage> createState() => _RacesPageState();
}

class _RacesPageState extends State<RacesPage> {
  final RaceService _raceService = RaceService();
  String _selectedTab = 'all'; // 'all', 'upcoming', 'completed'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Races'),
        centerTitle: true,
        actions: [
          // Statistics button
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Race Statistics',
            onPressed: _showStatistics,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selector
          _buildTabSelector(),

          // Race list
          Expanded(
            child: _buildRaceList(),
          ),
        ],
      ),
      // Floating action button to add new race
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add race page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RaceEditPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Race'),
      ),
    );
  }

  /// Build tab selector for filtering races
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton('All Races', 'all'),
          _buildTabButton('Upcoming', 'upcoming'),
          _buildTabButton('Completed', 'completed'),
        ],
      ),
    );
  }

  /// Build individual tab button
  Widget _buildTabButton(String label, String tabValue) {
    final isSelected = _selectedTab == tabValue;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTab = tabValue;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
      ),
      child: Text(label),
    );
  }

  /// Build race list based on selected tab
  Widget _buildRaceList() {
    Stream<List<Race>> raceStream;

    switch (_selectedTab) {
      case 'upcoming':
        raceStream = _raceService.getUpcomingRacesStream();
        break;
      case 'completed':
        raceStream = _raceService.getCompletedRacesStream();
        break;
      case 'all':
      default:
        raceStream = _raceService.getAthleteRacesStream();
        break;
    }

    return StreamBuilder<List<Race>>(
      stream: raceStream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading races: ${snapshot.error}'),
          );
        }

        // No races
        final races = snapshot.data ?? [];
        if (races.isEmpty) {
          return _buildEmptyState();
        }

        // Display races
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: races.length,
          itemBuilder: (context, index) {
            return _buildRaceCard(races[index]);
          },
        );
      },
    );
  }

  /// Build empty state when no races
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          const SizedBox(height: 16),
          Text(
            'No races found',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first race!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual race card
  Widget _buildRaceCard(Race race) {
    // Determine priority color
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: InkWell(
        onTap: () => _showRaceDetails(race),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with priority badge
              Row(
                children: [
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      race.priority,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Race name
                  Expanded(
                    child: Text(
                      race.raceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Status badge
                  if (race.status != 'upcoming')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: race.status == 'completed'
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        race.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    race.formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Days until race (only for upcoming)
                  if (race.isUpcoming)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${race.daysUntilRace} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                      fontSize: 13,
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
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              // Distance (if provided)
              if (race.distance != null) ...[
                const SizedBox(height: 4),
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
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
              ],

              // Action buttons
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit button
                  TextButton.icon(
                    onPressed: () => _editRace(race),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  // Mark as completed (only for upcoming races)
                  if (race.status == 'upcoming')
                    TextButton.icon(
                      onPressed: () => _markAsCompleted(race),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Complete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Delete button
                  TextButton.icon(
                    onPressed: () => _deleteRace(race),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show race details dialog
  void _showRaceDetails(Race race) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(race.raceName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Date', race.formattedDate),
                _buildDetailRow('Type', race.raceType),
                _buildDetailRow('Priority', race.priorityDescription),
                if (race.location != null)
                  _buildDetailRow('Location', race.location!),
                if (race.distance != null)
                  _buildDetailRow('Distance', race.distance!),
                if (race.notes != null && race.notes!.isNotEmpty)
                  _buildDetailRow('Notes', race.notes!),
                _buildDetailRow('Status', race.status.toUpperCase()),
                if (race.result != null)
                  _buildDetailRow('Result', race.result!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Build detail row for race details dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Edit race
  void _editRace(Race race) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RaceEditPage(race: race),
      ),
    );
  }

  /// Mark race as completed
  void _markAsCompleted(Race race) {
    showDialog(
      context: context,
      builder: (context) {
        final resultController = TextEditingController();

        return AlertDialog(
          title: const Text('Mark as Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mark "${race.raceName}" as completed?'),
              const SizedBox(height: 16),
              TextField(
                controller: resultController,
                decoration: const InputDecoration(
                  labelText: 'Result (optional)',
                  hintText: 'e.g., 1st place, Personal best',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _raceService.markRaceAsCompleted(
                    race.raceId,
                    result: resultController.text.isNotEmpty
                        ? resultController.text
                        : null,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Race marked as completed!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Mark Complete'),
            ),
          ],
        );
      },
    );
  }

  /// Delete race
  void _deleteRace(Race race) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Race'),
          content: Text('Are you sure you want to delete "${race.raceName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _raceService.deleteRace(race.raceId);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Race deleted successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Show statistics dialog
  void _showStatistics() async {
    final stats = await _raceService.getRaceStatistics();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Race Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total Races', stats.totalRaces.toString()),
              _buildStatRow('Upcoming', stats.upcomingRaces.toString()),
              _buildStatRow('Completed', stats.completedRaces.toString()),
              const Divider(),
              _buildStatRow('A Races', stats.aRaces.toString(), Colors.red),
              _buildStatRow('B Races', stats.bRaces.toString(), Colors.orange),
              _buildStatRow('C Races', stats.cRaces.toString(), Colors.blue),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Build stat row for statistics dialog
  Widget _buildStatRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
