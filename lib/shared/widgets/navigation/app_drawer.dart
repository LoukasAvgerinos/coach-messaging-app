import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:andreopoulos_messasing/features/auth/services/auth_service.dart';
import 'package:andreopoulos_messasing/features/home/presentation/pages/settings_page.dart';
import 'package:andreopoulos_messasing/features/profile/presentation/pages/profile_page.dart';
import 'package:andreopoulos_messasing/features/race/presentation/pages/races_page.dart';
import 'package:andreopoulos_messasing/features/chat/presentation/pages/athlete_messages_page.dart';
import 'package:andreopoulos_messasing/features/chat/services/chat_service.dart';
import '/main.dart';
import 'package:andreopoulos_messasing/features/auth/services/auth_gate.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // Logout method with confirmation dialog
  // Simply signs out - AuthGate's StreamBuilder will handle navigation automatically
  void logout(BuildContext context) {
    // Show confirmation dialog to prevent accidental logouts
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            // Logout button
            TextButton(
              onPressed: () async {
                // Close confirmation dialog
                Navigator.pop(dialogContext);

                try {
                  // Sign out from Firebase
                  print('🔓 Signing out...');
                  await AuthService().signOut();
                  print('✅ Signed out successfully');

                  // Use global navigator key to replace all routes with fresh AuthGate
                  // This ensures a clean rebuild that detects the logged-out state
                  navigatorKey.currentState?.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                    (route) => false,
                  );
                  print('✅ Replaced all routes with fresh AuthGate - should show login');
                } catch (e) {
                  print('❌ Logout error: $e');

                  // Show error dialog only if sign out fails
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (errorContext) => AlertDialog(
                        title: const Text('Logout Failed'),
                        content: Text('Could not log out: $e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(errorContext),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Logout',
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D2994), // Navy Medium background
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          DrawerHeader(
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/andreo_logo.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Messages list tile - Chat with coach
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: StreamBuilder<int>(
              stream: FirebaseAuth.instance.currentUser?.uid != null
                  ? ChatService().streamTotalUnreadCount(
                      FirebaseAuth.instance.currentUser!.uid)
                  : Stream.value(0),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;

                return ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: const Text(
                    'M E S S A G E S',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Close drawer
                    Navigator.pop(context);
                    // Navigate to athlete messages page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AthleteMessagesPage()),
                    );
                  },
                );
              },
            ),
          ),

          // Profile list tile - Access athlete profile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              title: const Text(
                'P R O F I L E',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                // Close drawer first
                Navigator.pop(context);
                // Navigate to profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ),

          // Races list tile - NEW: Manage races
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: const Icon(
                Icons.emoji_events,
                color: Colors.white,
              ),
              title: const Text(
                'M Y  R A C E S',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                // Close drawer first
                Navigator.pop(context);
                // Navigate to races page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RacesPage()),
                );
              },
            ),
          ),

          // Settings list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              title: const Text(
                'S E T T I N G S',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                // Close drawer first
                Navigator.pop(context);
                // Then navigate to settings
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),

          const Spacer(),

          // Logout list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 55.0),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: const Text(
                'L O G O U T',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              onTap: () {
                // Close drawer first
                Navigator.pop(context);
                // Call logout method which handles confirmation and sign out
                logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
