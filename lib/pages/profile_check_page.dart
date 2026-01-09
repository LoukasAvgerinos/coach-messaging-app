import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/profile_service.dart';
import 'home_page.dart';
import 'profile_edit_page.dart';
import 'coach_dashboard_page.dart';

/// ProfileCheckPage - Checks if user has a profile and redirects accordingly
/// This page is shown right after login to ensure user has completed their profile
class ProfileCheckPage extends StatefulWidget {
  const ProfileCheckPage({super.key});

  @override
  State<ProfileCheckPage> createState() => _ProfileCheckPageState();
}

class _ProfileCheckPageState extends State<ProfileCheckPage> {
  final ProfileService _profileService = ProfileService();
  bool _isChecking = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  /// Check if the current user has an athlete profile or is a coach
  Future<void> _checkProfile() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        // No user logged in, shouldn't happen but handle it
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
        return;
      }

      // First, check user role from Firestore Users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        // User document doesn't exist, go to home page
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
        return;
      }

      final userType = userDoc.data()?['userType'] as String?;

      // If user is a coach, go directly to coach dashboard
      if (userType == 'coach') {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CoachDashboardPage()),
          );
        }
        return;
      }

      // If user is an athlete, check if profile exists
      final profileExists = await _profileService.athleteProfileExists(userId);

      setState(() {
        _hasProfile = profileExists;
        _isChecking = false;
      });

      // If profile exists, go to home page
      if (profileExists && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
      // If no profile, show the prompt to create one (stays on this page)
    } catch (e) {
      print('Error checking profile: $e');
      // On error, just go to home page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking
    if (_isChecking) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show profile creation prompt if no profile exists
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome icon
              Icon(
                Icons.sports_gymnastics,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 32),

              // Welcome message
              Text(
                'Welcome to\nChat for Athletes!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              // Instructions
              Text(
                'To get started, please create your athlete profile. This helps your coach understand your training availability, equipment, and health information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // Create Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to profile edit page
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileEditPage(),
                      ),
                    );

                    // After creating profile, go to home page
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  label: const Text(
                    'Create My Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip button (optional - user can create profile later)
              TextButton(
                onPressed: () {
                  // Skip for now, go to home page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can always update your profile later from the menu.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
