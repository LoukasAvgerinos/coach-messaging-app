import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:andreopoulos_messasing/features/chat/presentation/pages/chat_page.dart';
import 'package:andreopoulos_messasing/shared/widgets/navigation/app_drawer.dart';
import 'package:andreopoulos_messasing/features/chat/presentation/widgets/user_tile.dart';
import 'package:andreopoulos_messasing/features/chat/services/chat_service.dart';
import 'package:andreopoulos_messasing/features/auth/services/auth_service.dart';
import 'package:andreopoulos_messasing/features/profile/services/profile_service.dart';
import 'package:andreopoulos_messasing/features/profile/data/models/athlete_profile_model.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaching Chat'),
        centerTitle: true,
        //  ADD TEST BUTTON IN APP BAR
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Test Sound',
            onPressed: () async {
              print('🔊 Testing notification sound...');
              final player = AudioPlayer();
              try {
                await player.play(AssetSource('sounds/new_message.mp3'));
                print('✅ Sound played successfully!');

                // Show feedback to user
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔊 Sound test - Did you hear it?'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error playing sound: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Payment banner (if athlete has unpaid amount)
          _buildPaymentBanner(),
          // User list
          Expanded(child: _buildUserList()),
        ],
      ),

      // ⭐ ADD FLOATING BUTTON (OPTIONAL - remove if you prefer only app bar button)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('🔊 Testing sound from FAB...');
          final player = AudioPlayer();
          try {
            await player.play(AssetSource('sounds/new_message.mp3'));
            print('✅ Sound played!');
          } catch (e) {
            print('❌ Error: $e');
          }
        },
        child: const Icon(Icons.volume_up),
        tooltip: 'Test Sound',
      ),
    );
  }

  // Build user list except current user
  Widget _buildUserList() {
    final chatService = ChatService();
    final authService = AuthService();

    return StreamBuilder(
      stream: chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Error handling
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>(
                (userData) =>
                    _buildUserListItem(userData, context, authService),
              )
              .toList(),
        );
      },
    );
  }

  // Build individual user tile
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
    AuthService authService,
  ) {
    // Display user except current user
    if (userData["email"] != authService.currentUser?.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          // Navigate to chat page with selected user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData["email"],
                receiverId: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container(); // Return empty widget for current user
    }
  }

  /// Build payment banner for athletes with outstanding balance
  Widget _buildPaymentBanner() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<AthleteProfile?>(
      stream: _profileService.streamAthleteProfile(userId).asyncMap((profile) async {
        // If no profile found by athleteId, try by userId
        if (profile == null) {
          return await _profileService.getAthleteProfileByUserId(userId);
        }
        return profile;
      }),
      builder: (context, snapshot) {
        // Don't show anything while loading or if there's no data
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final athlete = snapshot.data!;
        bool isUnpaid = athlete.financiallyAware == false;
        double amountOwed = athlete.amountOwed ?? 0.0;

        // Only show banner if athlete has outstanding payment
        if (!isUnpaid || amountOwed <= 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Payment Due',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Outstanding balance: €${amountOwed.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}
