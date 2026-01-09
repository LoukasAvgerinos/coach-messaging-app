import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/athlete_profile_model.dart';
import '../services/profile_service.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<AthleteProfile?>(
        stream: _getProfileStream(userId),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
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

          // No profile found
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildNoProfileView(context);
          }

          // Display profile
          final profile = snapshot.data!;
          return _buildProfileContent(context, profile);
        },
      ),
    );
  }

  /// Get profile stream
  Stream<AthleteProfile?> _getProfileStream(String userId) async* {
    final profileService = ProfileService();
    final profile = await profileService.getAthleteProfileByUserId(userId);

    if (profile != null) {
      yield* profileService.streamAthleteProfile(profile.athleteId);
    } else {
      yield null;
    }
  }

  /// Build view when no profile exists
  Widget _buildNoProfileView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Profile Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your athlete profile to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main profile content
  Widget _buildProfileContent(BuildContext context, AthleteProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(context, profile),

          const SizedBox(height: 24),

          // Basic Information
          _buildSection(
            context,
            title: 'Basic Information',
            icon: Icons.person,
            children: [
              _buildInfoRow('Full Name', profile.fullName),
              _buildInfoRow('Email', profile.email),
              _buildInfoRow('Phone', profile.phone ?? 'Not provided'),
              _buildInfoRow('City', profile.city ?? 'Not provided'),
              _buildInfoRow('Age', '${profile.age} years old'),
              _buildInfoRow(
                'Date of Birth',
                '${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year}',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Performance Metrics (Coach-controlled)
          _buildPerformanceMetricsSection(context, profile),

          const SizedBox(height: 16),

          // Physical Metrics
          _buildSection(
            context,
            title: 'Physical Metrics',
            icon: Icons.fitness_center,
            children: [
              _buildInfoRow('Weight', '${profile.weight} kg'),
              _buildInfoRow('Height', '${profile.height} cm'),
              _buildInfoRow('BMI', profile.bmi.toStringAsFixed(1)),
            ],
          ),

          const SizedBox(height: 16),

          // Training Availability
          _buildSection(
            context,
            title: 'Training Availability',
            icon: Icons.calendar_today,
            children: [
              _buildInfoRow(
                'Available Hours/Week',
                '${profile.availableHoursPerWeek} hours',
              ),
              _buildInfoRow(
                'Training Days/Week',
                '${profile.availableTrainingDays} days',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Equipment & Facilities
          _buildSection(
            context,
            title: 'Equipment & Facilities',
            icon: Icons.directions_bike,
            children: [
              _buildInfoRow('Equipment', profile.equipment ?? 'Not specified'),
              _buildInfoRow('Gym Access', profile.hasGymAccess ? 'Yes' : 'No'),
            ],
          ),

          const SizedBox(height: 16),

          // Health Information
          _buildSection(
            context,
            title: 'Health Information',
            icon: Icons.health_and_safety,
            children: [
              _buildInfoRow(
                'Medical Conditions',
                profile.medicalConditions ?? 'None reported',
              ),
              _buildInfoRow('Supplements', profile.supplements ?? 'None'),
            ],
          ),

          const SizedBox(height: 32),

          // Last updated info
          Center(
            child: Text(
              'Last updated: ${_formatDate(profile.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build profile header with avatar
  Widget _buildProfileHeader(BuildContext context, AthleteProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              profile.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Name and age
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.age} years old${profile.city != null ? " • ${profile.city}" : ""}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Performance Metrics section (Coach-controlled)
  Widget _buildPerformanceMetricsSection(
    BuildContext context,
    AthleteProfile profile,
  ) {
    final profileService = ProfileService();

    return StreamBuilder<PerformanceMetrics?>(
      stream: profileService.streamPerformanceMetrics(profile.athleteId),
      builder: (context, snapshot) {
        final metrics = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header with lock icon
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Performance Metrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.lock,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Coach-only note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'These values are set by your coach',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // FTP
              _buildInfoRow(
                'FTP (Functional Threshold Power)',
                metrics?.ftp != null ? '${metrics!.ftp} watts' : 'Not set by coach',
              ),
              // FTHR
              _buildInfoRow(
                'FTHR (Functional Threshold Heart Rate)',
                metrics?.fthr != null ? '${metrics!.fthr} bpm' : 'Not set by coach',
              ),
              // Last updated
              if (metrics?.lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Last updated by coach: ${_formatDate(metrics!.lastUpdated!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build section widget
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Section content
          ...children,
        ],
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
