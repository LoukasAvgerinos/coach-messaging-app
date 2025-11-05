/*
import 'package:flutter/material.dart';
import '/pages/chat_page.dart';
import '/components/drawer.dart';
import '/components/user_tile.dart';
import '/services/chat/chat_services.dart';
import '/services/auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coaching Chat'), centerTitle: true),
      drawer: const CustomDrawer(),
      body: _buildUserList(),
    );
  }

  // Build user list except current user
  Widget _buildUserList() {
    final chatService = ChatService(); // ← FIX 1: Remove the 's'
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
                receiverId: userData["uid"], // ← FIX 2: Add receiverId
              ),
            ),
          );
        },
      );
    } else {
      return Container(); // Return empty widget for current user
    }
  }
}
*/
import 'package:flutter/material.dart';
import '/pages/chat_page.dart';
import '/components/drawer.dart';
import '/components/user_tile.dart';
import '/services/chat/chat_services.dart';
import '/services/auth/auth_service.dart';
import 'package:audioplayers/audioplayers.dart'; // ⭐ ADD THIS

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaching Chat'),
        centerTitle: true,
        // ⭐ ADD TEST BUTTON IN APP BAR
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
      body: _buildUserList(),

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
}
